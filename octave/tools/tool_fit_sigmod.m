## Fit signal model to a natural signal
##
## Usage: [r_mp, r_nn, r_ss, r_eo] = tool_fit_sigmod(p_xx, p_nm, p_fs, p_mp, p_nv, p_rf, p_wf, p_if)
##
## p_xx ... (preconditioned) natural signal amplitude array, [<dbl>]
## p_nm ... first local maximum index, <uint>
## p_fs ... sampling frequency of the natural signal, Hz, <dbl>
## p_mp ... signal model parameters [1 x 5], initial state, <dbl>
## p_nv ... number of vaiation steps, interval subdivision, <uint>
## p_rf ... range factor matrix [4 x 2], multipliers of the parameter's initial value, [[<dbl>]]
## p_wf ... weight factors used to weigh the error in the first and the second half of the error measuring interval [1 x 2], [<dbl>, <dbl>]
## p_if ... interpolation factor used to interpolate p_xx, p_if >= 1, <uint>
## r_mp ... return: optimised signal model parameters [1 x 5], [<dbl>]
## r_nn ... return: sample index array, optimised synthetic signal, [<uint>]
## r_ss ... return: signal amplitude array, optimised synthetic signal, [<dbl>]
## r_eo ... return: residual optimisation (fitting) error (weighted metric score), <dbl>
## r_es ... return: error state (true = failure, false = success), <bool>
##
## see also: tool_gen_signal.m
##
#######################################################################################################################
## LICENSE
##
##    Copyright (C) 2025 Jakob Harden (jakob.harden@tugraz.at, Graz University of Technology, Graz, Austria)
##    This file is part of the PhD thesis of Jakob Harden.
##
##    This program is free software: you can redistribute it and/or modify
##    it under the terms of the GNU Affero General Public License as
##    published by the Free Software Foundation, either version 3 of the
##    License, or (at your option) any later version.
##
##    This program is distributed in the hope that it will be useful,
##    but WITHOUT ANY WARRANTY; without even the implied warranty of
##    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##    GNU Affero General Public License for more details.
##
##    You should have received a copy of the GNU Affero General Public License
##    along with this program.  If not, see <https://www.gnu.org/licenses/>.
##
#######################################################################################################################
##
function [r_mp, r_nn, r_ss, r_eo, r_es] = tool_fit_sigmod(p_xx, p_nm, p_fs, p_mp, p_nv, p_rf, p_wf = [2/3, 1/3], p_if = 1)
  
  ## initialise return values
  r_mp = p_mp;
  r_nn = [];
  r_ss = [];
  r_eo = 1e6;
  r_es = true;
  
  ## reduce signal data to investigated area
  p_if = max([round(p_if), 1]); # enforce integer number >= 1
  xx_n = p_xx(1 : p_nm + p_if);
  
  ## interpolate signal data
  N0 = numel(xx_n);
  nn0 = 1 : N0;
  Nk = N0 * p_if - 1;
  kk0 = linspace(1, N0, Nk);
  kmax = p_nm * p_if;
  fs_k = p_fs * Nk / N0;
  xx_k = interp1(nn0, xx_n, kk0)(:);

  ## outer loop: shift maximum point location
  kmax_arr = [kmax - p_if : 1 : kmax + p_if - 1];
  Nmaxvar = numel(kmax_arr); # number of variation steps
  err_arr = zeros(1, Nmaxvar); # initialise error array
  mp = p_mp; # initialise parameter array
  rds = [];
  for j = 1 : Nmaxvar
    ## inner loop: optimise parameters
    [mp, ~, ~, ~   , es] = tool_fit_sigmod_optparam(xx_k, kmax_arr(j), tp = 1, fs_k, p_nv, mp, p_rf, p_wf); # F1
    if (es)
      return;
    endif
    [mp, ~, ~, ~   , es] = tool_fit_sigmod_optparam(xx_k, kmax_arr(j), tp = 2, fs_k, p_nv, mp, p_rf, p_wf); # alpha
    if (es)
      return;
    endif
    [mp, ~, ~, ~   , es] = tool_fit_sigmod_optparam(xx_k, kmax_arr(j), tp = 3, fs_k, p_nv, mp, p_rf, p_wf); # beta
    if (es)
      return;
    endif
    [mp, kk, ss, eo, es] = tool_fit_sigmod_optparam(xx_k, kmax_arr(j), tp = 4, fs_k, p_nv, mp, p_rf, p_wf); # gamma
    if (es)
      return;
    endif
    ## optimisation error (weighted metric score)
    err_arr(j) = eo;
    ## collect signal data
    ds0 = [];
    ds0.mp = mp;
    ds0.kk = kk;
    ds0.ss = ss;
    ds0.eo = eo;
    rds = [rds; ds0];
  endfor
  
  ## index of optimal solution
  [eo, jmin] = min(err_arr);
  
  ## optimal solution
  dsopt = rds(jmin);
  
  ## return results
  r_mp = dsopt.mp;
  r_nn = kk0(dsopt.kk); # map interpolated sample index to original sample index
  r_ss = dsopt.ss;
  r_eo = dsopt.eo;
  
  ## update error state
  r_es = false;
  
endfunction


function [r_mp, r_nn, r_ss, r_eo, r_es] = tool_fit_sigmod_optparam(p_xx, p_nm, p_tp, p_fs, p_nv, p_mp, p_rf, p_wf)
  ## Optimise signal model parameters
  ##
  ## p_xx ... (preconditioned) natural signal amplitude array, [<dbl>]
  ## p_nm ... first local maximum index, <uint>
  ## p_tp ... parameter type (1 = F1, 2 = alpha, 3 = beta, 4 = gamma), <uint>
  ## p_fs ... sampling frequency of the natural signal, Hz, <dbl>
  ## p_nv ... number of vaiation steps, interval subdivision, <uint>
  ## p_mp ... signal model parameters [1 x 5], initial state, <dbl>
  ## p_rf ... range factor matrix [4 x 2], multipliers of the parameter's initial value, [[<dbl>]]
  ## p_wf ... weight factors used to weigh the error in the first and the second half of the error measuring interval [1 x 2], [<dbl>, <dbl>]
  ## r_mp ... return: optimised signal model parameters [1 x 5], [<dbl>]
  ## r_nn ... return: sample index array, optimised synthetic signal, [<uint>]
  ## r_ss ... return: signal amplitude array, optimised synthetic signal, [<dbl>]
  ## r_eo ... return: residual optimisation (fitting) error (weighted metric score), <dbl>
  ## r_es ... return: error state (true = failure, false = success), <bool>
  
  ## initialise return values
  r_mp = p_mp;
  r_nn = [];
  r_ss = [];
  r_eo = 0;
  r_es = true;
  
  ## number of cycles, maximum point location
  cyrat_max = tool_cyrat_sigmod(r_mp);
  
  ## range factor
  rf = p_rf(p_tp, 1:2);
  
  ## optimise parameter
  vp0 = r_mp(p_tp + 1);
  varr = linspace(vp0 * rf(1), vp0 * rf(2), p_nv);
  sigds = [];
  ## loop over maximum location variation
  for it = 1 : 5
    ## initialise result arrays
    err_arr = zeros(p_nv, 1);
    ## loop over frequency array
    for k = 1 : p_nv
      ## update signal model parameter array
      r_mp(p_tp + 1) = varr(k);
      cyrat_max = tool_cyrat_sigmod(r_mp);
      ## generate signal
      [css, ~, ~] = tool_gen_signal(p_fs, cyrat_max, r_mp);
      cn0 = p_nm - numel(css) + 1; # onset point location
      ## check index
      if (cn0 < 1)
        return;
      endif
      cnn = cn0 : p_nm; # error measuring window
      err_arr(k) = tool_fit_sigmod_errorscore(p_xx(cnn), css(:), p_wf); # error score
      ## save signal data
      if (nargout > 1)
        ds0 = [];
        ds0.nn = cnn;
        ds0.ss = css;
        sigds = [sigds; ds0];
      endif
    endfor
    ## check index location of absolute minimum
    [~, kmin] = min(err_arr);
    #itcontext = '';
    if (kmin  == 1)
      ## parameter range above minimum point, shift down range
      #itcontext = 'above'; 
      sf = 1 - (0.1 * it);
      varr = linspace(vp0 * rf(1) * sf, vp0 * rf(2) * sf, p_nv);
    elseif (kmin == p_nv)
      ## parameter range below minimum point, shift up range
      #itcontext = 'below'; 
      sf = 1 + (0.1 * it);
      varr = linspace(vp0 * rf(1) * sf, vp0 * rf(2) * sf, p_nv);
    else
      break;
    endif
##    if (it == 5)
##      printf('param %d. After %d iterations, the parameter range is still %s minimum point\n', p_tp, it, itcontext);
##    endif
  endfor
  
  ## return signal model parameters
  [eopt, kmin] = min(err_arr);
  r_mp(p_tp + 1) = varr(kmin);
  
  ## return signal data
  if (nargout > 1)
    r_nn = sigds(kmin).nn;
    r_ss = sigds(kmin).ss;
    r_eo = eopt;
  endif
  
  ## update error state
  r_es = false;
  
endfunction


function [r_esc] = tool_fit_sigmod_errorscore(p_xx, p_ss, p_phi = [2/3, 1/3]);
  ## Compile error concerning the error measuring window (weighted metric score)
  ##
  ## p_xx  ... natural signal partition (error measuring window), [<dbl>]
  ## p_ss  ... synthetic signal partition (error measuring window), [<dbl>]
  ## p_phi ... weights related to the first and the second half of the error measuring window, [<dbl>, <dbl>]
  ## r_esc ... return: weighted metric score of the optimisation error
  
  ## difference
  dd = p_xx - p_ss;
  
  ## partition indices
  N = numel(p_xx); # error measuring window length
  if (N < 3)
    ## window too small
    r_esc = meansq(dd);
    return;
  endif
  nmid = ceil(N / 2); # estimate mid of error measuring window
  
  ## error, first half of error measuring window
  e1 = meansq(dd(1 : nmid));
  
  ## error, second half of error measuring window
  e2 = meansq(dd(nmid + 1 : end));
  
  ## weighted metric score
  r_esc = e1 * p_phi(1) + e2 * p_phi(2);
  
endfunction
