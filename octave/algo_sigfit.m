## Visual signal inspection and semi-automated signal model fitting
##
## Usage: algo_sigfit(p_rm, p_dtp, p_did, p_cid)
##
## p_rm  ... run mode, optional, default = 'pick', see below, <str>
## p_dtp ... dataset type (1 = cement paste, 2 = ambient air, 3 = tap water, 4 = aluminium cylinder), optional, default = 2, <uint>
## p_did ... data set identifier, see algo_dsdefs.m, optional, default = 1, <uint>
## p_cid ... channel identifier (1 = P-wave, 2 = S-wave), optional, default = 1, <uint>
##
## Run modes:
##   p_rm = 'pick': pick detection start points and save results (point directly behind the first local maximum of the incoming wave)
##   p_rm = 'fit': fit signal model to the first ascending/descending flank of the natural signal
##   p_rm = 'plot': plot existing picking results
##   p_rm = 'stats': compile detection statistics
##   p_rm = 'plotstats': automated execution of 'plot', 'stats'
##   p_rm = 'fitplotstats': automated execution of 'fit', 'plot', 'stats'
##   The options 'fit', 'plot' and 'stats' operate on all available picking results. Therefore, p_dtp and p_did are silently ignored.
##
## see also: algo_param.m, algo_dsdefs.m
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
function algo_sigfit(p_rm = 'pick', p_dtp = 2, p_did = 1, p_cid = 1)
  
  ## load analysis parameters structure
  ap = algo_param();
  
  ## load data set definitions
  dsdefs = algo_dsdefs(p_dtp); # data set definitions of selected test series
  dscode = dsdefs.dsc{p_did}; # data set code
  
  ## switch run mode
  switch (lower(p_rm))
    case 'pick'
      ## pick detection start points and save results
      ads = sf_pick(ap, dsdefs, p_did, p_cid);
      ## save analysis results
      ofp = fullfile(ap.rpath_algo_sigfit, 'oct', sprintf('%s_%d_pick.oct', dscode, p_cid));
      save('-binary', ofp, 'ads');
   case 'fit'
      ## load picking results
      for p_dtp = 1 : 4
        dsdefs = algo_dsdefs(p_dtp); # data set definitions of selected test series
        for p_did = getfield(ap.sf, sprintf('dsids%d', p_dtp));
          dscode = dsdefs.dsc{p_did}; # data set code
          ifp = fullfile(ap.rpath_algo_sigfit, 'oct', sprintf('%s_%d_pick.oct', dscode, p_cid));
          if not(exist(ifp, 'file') == 3)
            warning('Picking result file %s_%d_pick.oct yet not available.', dscode, p_cid);
            continue;
          endif
          ads = load('-binary', ifp, 'ads').ads;
          ## fit signal model to the first ascending/descending flank of the natural signal
          ads = sf_fit(ap, ads);
          ## save analysis results
          ofp = fullfile(ap.rpath_algo_sigfit, 'oct', sprintf('%s_%d_fit.oct', dscode, p_cid));
          save('-binary', ofp, 'ads');
        endfor
      endfor
    case 'plot'
      for p_dtp = 1 : 4
        dsdefs = algo_dsdefs(p_dtp); # data set definitions of selected test series
        for p_did = getfield(ap.sf, sprintf('dsids%d', p_dtp));
          dscode = dsdefs.dsc{p_did}; # data set code
          ## load fitting results
          ifp = fullfile(ap.rpath_algo_sigfit, 'oct', sprintf('%s_%d_fit.oct', dscode, p_cid));
          if not(exist(ifp, 'file') == 3)
            warning('Fitting result file %s_%d_fit.oct yet not available.', dscode, p_cid);
            continue;
          endif
          ads = load('-binary', ifp, 'ads').ads;
          ## plot existing picking results
          sf_plot(ap, ads);
        endfor
      endfor
    case 'stats'
      ## statistics
      coll = [];
      for p_dtp = 1 : 4
        dsdefs = algo_dsdefs(p_dtp); # data set definitions of selected test series
        for p_did = getfield(ap.sf, sprintf('dsids%d', p_dtp))
          dscode = dsdefs.dsc{p_did}; # data set code
          ## load fitting results
          ifp = fullfile(ap.rpath_algo_sigfit, 'oct', sprintf('%s_%d_fit.oct', dscode, p_cid));
          if not(exist(ifp, 'file') == 3)
            warning('Fitting result file %s_%d_fit.oct yet not available.', dscode, p_cid);
            continue;
          endif
          ads = load('-binary', ifp, 'ads').ads;
          ## collect data
          if (ads.dlima.v <= ads.nsig.v)
            ds0 = [];
            ds0.sidarr = ads.dlima.v : ads.nsig.v;
            ds0.pmat = ads.pmat.v(ds0.sidarr, :);
            ds0.emat = ads.emat.v(ds0.sidarr, :);
            ds0.dlima = ads.dlima.v;
            ds0.dscode = ads.dscode.v;
            ds0.dstype = ads.dstype.v;
            ds0.umd = dsdefs.umd(p_did);
            coll = [coll; ds0];
          endif
        endfor
      endfor
      ## compile stats
      [stats_ds, stats_fh] = sf_stats(ap, coll);
      ## export results
      tool_export(stats_ds, stats_fh, ap.rpath_algo_sigfit, 'stats', ap.sf.fnpfx_out, 'stats');
    case 'plotstats'
      algo_sigfit('plot');
      algo_sigfit('stats');
    case 'fitplotstats'
      algo_sigfit('fit');
      algo_sigfit('plot');
      algo_sigfit('stats');
    otherwise
      error('Option %s not implemented yet!', lower(p_rm));
  endswitch
  
endfunction


function [r_ds] = sf_pick(p_ap, p_dsd, p_did, p_cid)
  ## Pick detection start points (a point directly behind the first local maximum)
  ##
  ## p_ap  ... analysis parameter structure, <struct_param>
  ## p_dsd ... data set definition structure, <struct_dsdef>
  ## p_did ... data set identifier, <uint>
  ## p_cid ... channel identifier, <uint>
  ## r_ds  ... return: analysis result data structure, <struct_sigfit>
  
  ## data set code
  dscode = p_dsd.dsc{p_did};
  
  ## print status message
  printf('algo_sigfit: visualising dataset %s\n', dscode);
  
  ## load dataset
  dsfp = p_dsd.dsl{p_did}; # data set file path
  ds = load(dsfp, 'dataset').dataset; # entire data structure
  
  ## select channel
  switch (p_cid)
    case 1
      ## P-wave
      ds = ds.tst.s06; 
    case 2
      ## S-wave
      ds = ds.tst.s07; 
  endswitch
  [Nsmp, Nsig] = size(ds.d13.v);
  
  ## initialise analysis data structure
  r_ds = struct_initcollection('struct_sigfit', 'Semi-automated onset point picking results', uint16([1, 0]), 'algo_sigfit', uint16([1, 0]));
  r_ds.tsname = struct_objattrib('tsname', p_dsd.tsname, 'test series name');
  r_ds.tslong = struct_objattrib('tslong', p_dsd.tslong, 'test series name, long version');
  r_ds.tspfx = struct_objattrib('tspfx', p_dsd.tspfx, 'test series prefix');
  r_ds.tsid = struct_objdata('tsid', 'uint', p_dsd.tsid, '1', 'test series identifier');
  r_ds.tsdoi = struct_objattrib('tsdoi', p_dsd.tsdoi, 'test series, digital object identifier');
  r_ds.dsfp = struct_objattrib('dsfp', dsfp, 'data set file path');
  r_ds.dscode = struct_objattrib('dscode', dscode, 'data set code');
  r_ds.dstype = struct_objdata('dtp', 'uint', p_dsd.dstype, '1', 'data set type');
  r_ds.did = struct_objdata('did', 'uint', p_did, '1', 'data set identifier');
  r_ds.cid = struct_objdata('cid', 'uint', p_cid, '1', 'channel identifier');
  r_ds.fs = struct_objdata('fs', 'uint', ds.d07.v, 'Hz', 'sampling frequency, Hz');
  r_ds.fsmhz = struct_objdata('fsmhz', 'uint', r_ds.fs.v / 1e6, 'MHz', 'sampling frequency, MHz');
  r_ds.nsmp = struct_objdata('nsmp', 'uint', Nsmp, '1', 'number of samples');
  r_ds.nsig = struct_objdata('nsig', 'uint', Nsig, '1', 'number of signals');
  r_ds.nt = struct_objdata('nt', 'uint', ds.d09.v, '1', 'trigger point index');
  r_ds.sparr = struct_objdata('sparr', 'dbl_arr', zeros(Nsig, 1), '1', 'detection start point array, c1=npick');
  r_ds.dlimp = struct_objdata('dlimp', 'uint', 0, '1', 'picking detection limit, lowest signal index with proper detection results');
  
  ## loop over signals (from highest to lowest signal index)
  for j = Nsig : -1 : 1
    ## step 1: prepare signal
    Lers = p_ap.nat.ers_len(r_ds.dstype.v);
    xx = ds.d13.v(:, j); # signal
    xx(1 : r_ds.nt.v + Lers) = 0; # remove eletromagnetic response amplitudes and noise floor
    xx = xx - meansq(xx(1 : r_ds.nt.v)); # remove constant bias
    if (p_cid == 2)
      xx = -xx; # reverse amplitudes for S-wave signals
    endif
    ## step 2: select index directly behind first local maximum
    if (j == Nsig)
      w1 = [r_ds.nt.v, r_ds.nt.v + floor((Nsmp - r_ds.nt.v) * 0.25)];
    else
      dL = max([r_ds.sparr.v(j+1) - r_ds.nt.v + 1, 10]);
      w1n1 = max([r_ds.nt.v, r_ds.sparr.v(j+1) - floor(dL * 0.5)]);
      w1n2 = r_ds.sparr.v(j+1) + floor(dL * 0.25);
      w1 = [w1n1, w1n2];
    endif
    [nsel, v1, e1] = sf_select_index(xx, w1, 'Select point directly behind the first local maximum');
    if (e1)
      ## update detection limit
      if (j < Nsig)
        r_ds.dlimp.v = j + 1;
      else
        r_ds.dlimp.v = 0;
      endif
      printf('algo_sigfit: Detection limit: %s, CID = %d, SID = %d\n', dscode, p_cid, r_ds.dlimp.v);
      break;
    endif
    ## step 3: save picking result
    printf('algo_sigfit: Detection start point: %s, CID = %d, SID = %d, n = %d\n', dscode, p_cid, j, nsel);
    r_ds.sparr.v(j) = nsel;
    r_ds.dlimp.v = j;
  endfor
  
endfunction


function [r_ds] = sf_fit(p_ap, p_ads)
  ## Fit signal model to the first ascending flanks of a natural signals
  ##
  ## p_ap  ... analysis parameter structure, <struct_param>
  ## p_ads ... analysis result data structure, <struct_sigfit>
  ## r_ds  ... return: updated analysis result data structure, <struct_sigfit>
  
  ## copy structure
  r_ds = p_ads;
  
  ## data set code
  dscode = r_ds.dscode.v;
  
  ## load dataset
  dsfp = r_ds.dsfp.v; # data set file path
  ds = load(dsfp, 'dataset').dataset; # entire data structure
  
  ## select channel
  switch (r_ds.cid.v)
    case 1
      ## P-wave
      ds = ds.tst.s06; 
    case 2
      ## S-wave
      ds = ds.tst.s07; 
  endswitch
  
  ## update analysis data structure
  r_ds.dlima = struct_objdata('dlima', 'uint', 0, '1', 'analysis limit, lowest signal index with proper analysis results');
  r_ds.nmat = struct_objdata('nmat', 'dbl_mat', zeros(r_ds.nsig.v, 5), '1', 'index matrix, c1=nt, c2=n0, c3=nmax, c4=nx, c5=nx_intp');
  r_ds.pmat = struct_objdata('pmat', 'dbl_mat', zeros(r_ds.nsig.v, 5), '1', 'parameter matrix, c1=A, c2=F1, c3=alpha, c4=beta, c5=gamma');
  r_ds.emat = struct_objdata('emat', 'dbl_mat', zeros(r_ds.nsig.v, 1), '1', 'error matrix, c1=error');
  r_ds.optss = [];
  
  ## print status message
  printf('algo_sigfit: analysing dataset %s\n', dscode);
  
  ## loop over signals (from highest signal index to the picking detection limit)
  for j = r_ds.nsig.v : -1 : r_ds.dlimp.v
    ## print status
    printf('.');
    ##
    ## step 1: prepare signal
    Lers = p_ap.nat.ers_len(p_ads.dstype.v);
    xx = ds.d13.v(:, j); # signal
    xx = xx - meansq(xx(1 : r_ds.nt.v)); # remove constant bias
    xx(1 : r_ds.nt.v + Lers) = 0; # remove eletromagnetic response amplitudes and noise floor
    if (r_ds.cid.v == 2)
      xx = -xx; # invert amplitudes for S-wave signals
    endif
    ##
    ## step 2: read detection start point from picking results
    nsel = r_ds.sparr.v(j); # manually selected detection start point
    v1 = xx(nsel); # signal amplitude of detection start point
    ##
    ## step 3: locate first x-axis crossing
    if (v1 >= 0)
      ## forward search
      nx = find(xx(nsel : end) <= 0, 1, 'first');
      nx = nx + nsel - 2;
    else
      ## backwards search
      nx = find(xx(1 : nsel) >= 0, 1, 'last');
    endif
    nx_intp = interp1(xx(nx : nx + 1), [nx, nx + 1], 0);
    if (isnan(nx_intp))
      nx_intp = nx;
    endif
    ## remove amplitudes behind selected point (avoid false detections concerning the maximum point location)
    xx1 = xx; xx1(nx : end) = 0;
    ##
    ## step 4: locate first local maximum
    [v_max, nmax] = max(xx1(r_ds.nt.v + Lers : nsel));
    nmax = nmax + r_ds.nt.v + Lers - 1;
    ##
    ## step 5: polynomial regression to reduce the impact of noise
    L_fit = max([ceil((nx_intp - nmax + 1) / 2), 3]);
    ## check size of regression basis
    if (L_fit >= p_ap.sf.prlmin)
      ## enough sampes for a proper approximation available
      [v_max, nmax, is_err] = tool_max_polyreg(xx, nmax - L_fit, nmax + L_fit - 1, p_ap.sf.prord);
      if (is_err)
        printf('\nalgo_sigfit: Regression error! Reached detection limit! SID = %d\n', j + 1);
        r_ds.dlima.v = j + 1;
        break;
      endif
    endif
    ##
    ## step 6: normalise signal amplitudes
    xxs = xx / v_max;
    ##
    ## step 7: approximate center value for F1
    cyrat_max = tool_cyrat_sigmod(p_ap.sig.mpar);
    L_nmax_nx = max([nx_intp - nmax + 1, 3]); # avoid extremly high initial frequency estimates
    mp_F1 = r_ds.fs.v * cyrat_max / L_nmax_nx * 0.75; # rough estimate for the frequency variation's center frequency
    mpar0 = p_ap.sig.mpar;  mpar0(2) = mp_F1; # update signal model parameter array, initial settings for the optimisation
    ##
    ## step 8: check wave length
    Lwave = r_ds.fs.v / mp_F1; # estimate wave length, one full cycle
    if ((nmax - Lwave * cyrat_max) <= r_ds.nt.v)
      printf('\nalgo_sigfit: n0 <= nt! Reached detection limit! SID = %d\n', j + 1);
      r_ds.dlima.v = j + 1;
      break;
    endif
    ##
    ## step 9: parametrise signal model and estimate onset point
    [opt_mpar, opt_nn, opt_ss, opt_err, opt_es] = tool_fit_sigmod(xxs, nmax, r_ds.fs.v, mpar0, p_ap.sf.nvar, p_ap.sf.rfmat, p_ap.sf.phi, p_ap.sf.intf);
    if (opt_es)
      printf('\nalgo_sigfit: Index range error (n0 < 1)! Reached detection limit. SID = %d\n', j + 1);
      r_ds.dlima.v = j + 1;
      break;
    endif
    if (opt_err >= p_ap.sf.errmax(r_ds.dstype.v))
      printf('\nalgo_sigfit: error = %.4f >= %.4f! Reached detection limit. SID = %d\n', opt_err, p_ap.sf.errmax(r_ds.dstype.v), j + 1);
      r_ds.dlima.v = j + 1;
      break;
    endif
    ##
    ## step 10: save results
    ## update parameter matrix
    r_ds.pmat.v(j, 1:5) = opt_mpar;
    ## update index matrix
    r_ds.nmat.v(j, 1) = r_ds.nt.v; # trigger point
    r_ds.nmat.v(j, 2) = opt_nn(1); # onset point
    r_ds.nmat.v(j, 3) = opt_nn(end); # maximum point
    r_ds.nmat.v(j, 4) = nx; # x-axis crossing
    r_ds.nmat.v(j, 5) = nx_intp; # x-axis crossing, linear interpolation
    ## update error matrix
    r_ds.emat.v(j, 1) = opt_err; # error, weighted metric score
    ## update detection limit
    r_ds.dlima.v = j;
    ## save optimised signal
    ds_sig = [];
    ds_sig.sid = j;
    ds_sig.mpar = opt_mpar;
    ds_sig.nn_ss = opt_nn; # double precision due to the interpolation
    ds_sig.ss = opt_ss;
    ## save related signal data
    ds_sig.nn_xx = r_ds.nmat.v(j, 1) : ceil(r_ds.nmat.v(j, 4));
    ds_sig.xx = xxs(ds_sig.nn_xx);
    ## collect analysis results
    r_ds.optss = [r_ds.optss; ds_sig];
  endfor
  
  ## invert order of signal structures
  r_ds.optss = flipud(r_ds.optss);
  
  ## print status message
  printf('\n');
  printf('algo_sigfit: analysed data set %s, N_sig = %d, Err_min = %.6f, Err_max = %.6f\n', dscode, r_ds.nsig.v, min(r_ds.emat.v), max(r_ds.emat.v));
  
endfunction


function sf_plot(p_ap, p_ads)
  ## Plot onset point picking results
  ##
  ## p_ap  ... analysis parameter structure, <struct_param>
  ## p_ads ... analysis result data structure, <struct_sigfit>
  
  ## detection limit
  dl = p_ads.dlima.v;
  if (dl == 0)
    return;
  endif
  idx = dl : size(p_ads.nmat.v, 1);
  
  ## analysis result matrices
  nmat = p_ads.nmat.v(idx, :);
  pmat = p_ads.pmat.v(idx, :);
  emat = p_ads.emat.v(idx, :);
  
  [fh, ah] = tool_plot_create_figure(6, p_ads.dscode.v, false);
  set(fh, 'position', [100, 100, 1500, 0.5*1500]);
  spcnt = 0; # subplot counter
  ##
  ymin = min(nmat(:, 2));
  ymax = max(nmat(:, 5));
  yrng = ymax - ymin;
  ah = subplot(2, 3, spcnt+=1);
  set(ah, 'tickdir', 'out');
  title(ah, 'Signal indices');
  hold(ah, 'on');
  plot(ah, idx, nmat(:, 2), '-', 'displayname', 'n_0', 'linewidth', 1);
  plot(ah, idx, nmat(:, 3), '-', 'displayname', 'n_{max,1}', 'linewidth', 1);
  plot(ah, idx, nmat(:, 5), '-', 'displayname', 'n_{xc}', 'linewidth', 1);
  hold(ah, 'off');
  xlim(ah, [idx(1), idx(end)]);
  ylim(ah, [ymin - 0.1 * yrng, ymax + 0.25 * yrng]);
  ylabel(ah, 'Sample index [1]');
  legend(ah, 'numcolumns', 3, 'box', 'off', 'color', 'none', 'location', 'northwest');
  ##
  F1_arr = pmat(:, 2) / 1000;
  F2_arr = (pmat(:, 2) / 1000) .* pmat(:, 3);
  ah = subplot(2, 3, spcnt+=1);
  set(ah, 'tickdir', 'out');
  title(ah, 'Signal model frequencies');
  hold(ah, 'on');
  plot(ah, idx, F1_arr, '-', 'linewidth', 1, 'displayname', 'F_1');
  plot(ah, idx, F2_arr, '-', 'linewidth', 1, 'displayname', 'F_2');
  text(ah, idx(end), F1_arr(end), 'F_1', 'horizontalalignment', 'right', 'verticalalignment', 'bottom');
  text(ah, idx(end), F2_arr(end), 'F_2', 'horizontalalignment', 'right', 'verticalalignment', 'top');
  hold(ah, 'off');
  xlim(ah, [idx(1), idx(end)]);
  xlabel(ah, 'Signal ID [1]');
  ylabel(ah, 'Frequency [kHz]');
  ##
  ymax = max(pmat(:, 3));
  ymin = min(pmat(:, 3));
  ah = subplot(2, 3, spcnt+=1);
  set(ah, 'tickdir', 'out');
  title(ah, 'Frequency ratio alpha');
  hold(ah, 'on');
  if (p_ap.sig.mpar(3) > ymin) && (p_ap.sig.mpar(3) < ymax)
    plot(ah, idx([1, end]), [1, 1] * p_ap.sig.mpar(3), '-r', 'handlevisibility', 'off');
    text(ah, idx(end), p_ap.sig.mpar(3), sprintf('init. value = %.2f ', p_ap.sig.mpar(3)), ...
      'horizontalalignment', 'right', 'verticalalignment', 'bottom', 'fontweight', 'bold');
  endif
  plot(ah, idx, pmat(:, 3), '-', 'displayname', 'opt', 'linewidth', 1);
  hold(ah, 'off');
  xlim(ah, [idx(1), idx(end)]);
  ylabel(ah, 'alpha [1]');
  ##
  ymax = max(pmat(:, 4));
  ymin = min(pmat(:, 4));
  ah = subplot(2, 3, spcnt+=1);
  set(ah, 'tickdir', 'out');
  title(ah, 'Prim. damping constant beta');
  hold(ah, 'on');
  if (p_ap.sig.mpar(4) > ymin) && (p_ap.sig.mpar(4) < ymax)
    plot(ah, idx([1, end]), [1, 1] * p_ap.sig.mpar(4), '-r', 'handlevisibility', 'off');
    text(ah, idx(end), p_ap.sig.mpar(4), sprintf('init. value = %.2f ', p_ap.sig.mpar(4)), ...
      'horizontalalignment', 'right', 'verticalalignment', 'bottom', 'fontweight', 'bold');
  endif
  plot(ah, idx, pmat(:, 4), '-', 'displayname', 'opt', 'linewidth', 1);
  hold(ah, 'off');
  xlim(ah, [idx(1), idx(end)]);
  ylabel(ah, 'beta [1]');
  ##
  ymax = max(pmat(:, 5));
  ymin = min(pmat(:, 5));
  ah = subplot(2, 3, spcnt+=1);
  set(ah, 'tickdir', 'out');
  title(ah, 'Sec. damping constant gamma');
  hold(ah, 'on');
  if (p_ap.sig.mpar(5) > ymin) && (p_ap.sig.mpar(5) < ymax)
    plot(ah, idx([1, end]), [1, 1] * p_ap.sig.mpar(5), '-r', 'handlevisibility', 'off');
    text(ah, idx(end), p_ap.sig.mpar(5), sprintf('init. value = %.2f ', p_ap.sig.mpar(5)), ...
      'horizontalalignment', 'right', 'verticalalignment', 'bottom', 'fontweight', 'bold');
  endif
  plot(ah, idx, pmat(:, 5), '-', 'displayname', 'opt', 'linewidth', 1);
  hold(ah, 'off');
  xlim(ah, [idx(1), idx(end)]);
  ylabel(ah, 'gamma [1]');
  ##
  ah = subplot(2, 3, spcnt+=1);
  set(ah, 'tickdir', 'out');
  title(ah, 'Fitting error (weighted metric score)');
  hold(ah, 'on');
  plot(ah, idx, emat(:, 1), '-', 'displayname', 'S', 'linewidth', 1);
  hold(ah, 'off');
  xlim(ah, [idx(1), idx(end)]);
  ylabel(ah, 'Error score S [V^2]');
  ##
  annotation(fh, 'textbox', [0.25, 0.95, 1, 0.1], ...
    'string', sprintf('Signal model fitting results, data set: %s', strrep(p_ads.dscode.v, '_', '\_')), ...
    'horizontalalignment', 'center', 'verticalalignment', 'middle', 'fontsize', 14, 'fontweight', 'bold', 'linestyle', 'none');
  
  hgsave(fh, fullfile(p_ap.rpath_algo_sigfit, 'fig', sprintf('%s_%d.ofig', p_ads.dscode.v, p_ads.cid.v)));
  saveas(fh, fullfile(p_ap.rpath_algo_sigfit, 'png', sprintf('%s_%d.png', p_ads.dscode.v, p_ads.cid.v)), 'png');
  close(fh);
  
endfunction


function [r_ds, r_fh] = sf_stats(p_ap, p_cds)
  ## Compile curve fitting statistics
  ##
  ## p_ap  ... analysis parameter structure, <struct_param>
  ## p_cds ... data structure array, collection, [<struct>]
  ## r_ds  ... return: statistics data structure, <struct>
  ## r_fh  ... return figure handles, [<uint>]
  
  ## initialise return values
  r_ds = [];
  r_fh = [];
  
  ## collect and label data
  Ncoll = numel(p_cds);
  at = [];  a_p2 = [];  a_p3 = []; a_err = [];
  for k = 1 : Ncoll
    ds = p_cds(k);
    id1 = aggr_idgen('t', ds.dstype, 'd', ds.umd, 'r', 1);
    id2 = aggr_idgen('t', ds.dstype, 'd', ds.umd, 'r', 2);
    id3 = aggr_idgen('t', ds.dstype, 'd', ds.umd, 'r', 3);
    id4 = aggr_idgen('t', ds.dstype, 'd', ds.umd, 'r', 4);
    a1 = aggr_atom(id1, ds.pmat(:, 3), '1', '1', 'alpha');
    a2 = aggr_atom(id2, ds.pmat(:, 4), '1', '1', 'beta');
    a3 = aggr_atom(id3, ds.pmat(:, 5), '1', '1', 'gamma');
    a4 = aggr_atom(id4, ds.emat(:, 1), 'V^2', '!$V^2$', 'Error');
    at = [at; a1; a2; a3; a4];
  endfor
  
  ## set up data structure for TeX export
  r_ds = struct_initcollection('struct_mpstats', ...
    'Parameter and error statistics to the semi-automated signal model fitting results', ...
    uint16([1, 0]), '', uint16([1, 0]));
  
  ## c1 = data set type enmerator
  ## c2 = distance enumerator
  ## c3 = result type enumerator
  ## c4 = sample size N = |x|
  ## c5 = q_0.05(x)
  ## c6 = q_0.25(x)
  ## c7 = median(x)
  ## c8 = q_0.75(x)
  ## c9 = q_0.95(x)
  ## c10 = mean(x)
  ## c11 = empirical standard deviation estd(x)
  ## c12 = min(x)
  ## c13 = max(x)
  ## stats columns: 4 to 13
  
  ## stats for each distance
  rmat = [];
  for dstp = 1 : 4
    for d = 1 : 4
      umd = [25, 50, 70, 90](d);
      for res = 1 : 4
        a = aggr_join(at, 'x', aggr_idgen('t', dstp, 'd', umd, 'r', res));
        if not(isempty(a.x))
          s = sf_stats_cal(a.x, p_ap.sf.qlim);
          rmat = [rmat; [dstp, d, res, a.N, s]];
        endif
      endfor
    endfor
  endfor
  
  ## combine distances
  for dstp = 1 : 4
    for res = 1 : 4
      a = aggr_join(at, 'x', aggr_idgen('t', dstp, 'd', [25, 50, 70, 90], 'r', res));
      if not(isempty(a.x))
        s = sf_stats_cal(a.x, p_ap.sf.qlim);
        rmat = [rmat; [dstp, 0, res, a.N, s]];
      endif
    endfor
  endfor
  
  ## combine data set types
  for res = 1 : 4
    a = aggr_join(at, 'x', aggr_idgen('t', [1, 2, 3, 4], 'd', [25, 50, 70, 90], 'r', res));
    if not(isempty(a.x))
      s = sf_stats_cal(a.x, p_ap.sf.qlim);
      rmat = [rmat; [0, 0, res, a.N, s]];
    endif
  endfor
  
  ## combine distances
  ## excluded data sets: tap water, ultrasonic measuring distance 25 and 50 mm
  rmat1 = [];
  for dstp = 1 : 4
    if (dstp == 3)
      darr = [70, 90];
    else
      darr = [25, 50, 70, 90];
    endif
    for res = 1 : 4
      a = aggr_join(at, 'x', aggr_idgen('t', dstp, 'd', darr, 'r', res));
      if not(isempty(a.x))
        s = sf_stats_cal(a.x, p_ap.sf.qlim);
        rmat1 = [rmat1; [dstp, 0, res, a.N, s]];
      endif
    endfor
  endfor
  
  ## combine data set types
  ## excluded data sets: tap water, ultrasonic measuring distance 25 and 50 mm
  for res = 1 : 4
    id1 = aggr_idgen('t', 1, 'd', [25, 50, 70], 'r', res);
    id2 = aggr_idgen('t', 2, 'd', [25, 50, 70, 90], 'r', res);
    id3 = aggr_idgen('t', 3, 'd', [70, 90], 'r', res);
    id4 = aggr_idgen('t', 4, 'd', [50], 'r', res);
    id = [id1, id2, id3, id4];
    a = aggr_join(at, 'x', id);
    if not(isempty(a.x))
      s = sf_stats_cal(a.x, p_ap.sf.qlim);
      rmat1 = [rmat1; [0, 0, res, a.N, s]];
    endif
  endfor
  
  ## labels
  lbl_r = {'alpha', 'beta', 'gamma', 'Error, wght.'};
  lbl_u = {'1', '1', '1', 'V^2'};
  lbl_d = {'25', '50', '70', '90'};
  lbl_t = {'cement paste', 'ambient air', 'tap water', 'aluminium cylinder'};
  lbl_yl = {'!$\alpha$', '!$\beta$', '!$\gamma$', 'Error'};
  lbl_yu = {'1', '1', '1', '!V\textsuperscript{2}'};
  lbl_ti = {'Frequency ratio', 'Primary damping constant', 'Secondary damping constant', 'Optimisation error'};
  descr = 'c1 = N, c2=min, c3=q1, c4=median, c5=q3, c6=max, c7=mean, c8=estd';
  init_val = [p_ap.sig.mpar(3), p_ap.sig.mpar(4), p_ap.sig.mpar(5), 0]; # initial values for all results
  colblue = [45,104,196] / 255; # true-blues
  colgray = [1, 1, 1] * 0.5;
  colgreen = [32,178,170] / 255; # light sea-green
  colorange = [1, 0.75, 0]; # orange
  cm1 = [brighten(colblue, 0); brighten(colblue, 0.2); brighten(colblue, 0.4); brighten(colblue, 0.6)]; # colour map, distances
  cm2 = [colgray * 1.5; brighten(colblue, 0.5); colgreen; colorange]; # colour map materials
  scolidx = [4 : 13]; # stats column indices
  
  ## detailed results, all data sets
  fcnt = 0;
  for r = 1 : 4
    m1 = rmat(rmat(:, 3) == r, :); # select result type
    for t = 1 : 4
      m2 = m1(m1(:, 1) == t, :); # select data set type
      ## update data structure
      xtl_idx = m2(:, 2);
      xtl = {};
      cmap = [];
      for k = 1 : numel(xtl_idx)
        if (xtl_idx(k) < 1)
          xtl(k) = 'all';
          cmap = [cmap; colgray];
        else
          xtl(k) = lbl_d{xtl_idx(k)};
          cmap = [cmap; cm1(xtl_idx(k), :)];
        endif
      endfor
      fn = sprintf('tabr%dt%dall', r, t);
      fn1 = sprintf('ylur%dt%dall', r, t);
      fn2 = sprintf('xtlr%dt%dall', r, t);
      obj = struct_objdata(fn, 'dbl_mat', m2(:, scolidx), '1', sprintf('%s, %s, %s', lbl_r{r}, lbl_t{t}, descr));
      obj1 = struct_objdata(fn1, 'str', lbl_yl{r}, lbl_yu{r}, sprintf('%s, %s, %s', lbl_r{r}, lbl_t{t}, 'y axis label and unit'));
      obj2 = struct_objattrib(fn1, xtl, sprintf('%s, %s, %s', lbl_r{r}, lbl_t{t}, 'x tick labels'));
      r_ds = setfield(r_ds, fn, obj);
      r_ds = setfield(r_ds, fn1, obj1);
      r_ds = setfield(r_ds, fn2, obj2);
      ## plot results
      plt_ti = sprintf('%s, %s', lbl_ti{r}, lbl_t{t}); # title
      r_fh(fcnt+=1) = sf_stats_plot(m2(:, scolidx), plt_ti, {'Distance', 'mm'}, {lbl_r{r}, lbl_u{r}}, xtl, init_val(r), cmap, p_ap.sf.qlim);
    endfor
  endfor
  
  ## overall results for each data set type, all data sets
  for r = 1 : 4
    m1 = rmat(rmat(:, 3) == r, :); # select result type
    m2 = m1(m1(:, 2) == 0, :); # select combined results
    ## update data structure
    xtl_idx = m2(:, 1);
    xtl = {};
    cmap = [];
    for k = 1 : numel(xtl_idx)
      if (xtl_idx(k) < 1)
        xtl(k) = 'all';
        cmap = [cmap; colgray];
      else
        xtl(k) = lbl_t{xtl_idx(k)};
        cmap = [cmap; cm2(xtl_idx(k), :)];
      endif
    endfor
    fn = sprintf('tabr%dall', r);
    obj = struct_objdata(fn, 'dbl_mat', m2(:, scolidx), '1', sprintf('%s, %s', lbl_r{r}, descr));
    r_ds = setfield(r_ds, fn, obj);
    ## plot results
    plt_ti = sprintf('%s', lbl_ti{r}); # title
    r_fh(fcnt+=1) = sf_stats_plot(m2(:, scolidx), plt_ti, {'Testing material', 'mm'}, {lbl_r{r}, lbl_u{r}}, xtl, init_val(r), cmap, p_ap.sf.qlim);
  endfor
  
  ## overall results for each data set type
  ## excluded data sets: tap water, ultrasonic measuring distance 25 and 50 mm
  for r = 1 : 4
    m1 = rmat1(rmat1(:, 3) == r, :); # select result type
    m2 = m1(m1(:, 2) == 0, :); # select combined results
    ## update data structure
    xtl_idx = m2(:, 1);
    xtl = {};
    cmap = [];
    for k = 1 : numel(xtl_idx)
      if (xtl_idx(k) < 1)
        xtl(k) = 'all';
        cmap = [cmap; colgray];
      else
        xtl(k) = lbl_t{xtl_idx(k)};
        cmap = [cmap; cm2(xtl_idx(k), :)];
      endif
    endfor
    fn = sprintf('tabr%dexds', r);
    obj = struct_objdata(fn, 'dbl_mat', m2(:, scolidx), '1', sprintf('%s, %s', lbl_r{r}, descr));
    r_ds = setfield(r_ds, fn, obj);
    ## plot results
    plt_ti = sprintf('%s (excluded data sets: tap water, UMD = 25, 50 mm)', lbl_ti{r}); # title
    r_fh(fcnt+=1) = sf_stats_plot(m2(:, scolidx), plt_ti, {'Testing material', 'mm'}, {lbl_r{r}, lbl_u{r}}, xtl, init_val(r), cmap, p_ap.sf.qlim);
  endfor
  
endfunction


function [r_st] = sf_stats_cal(p_mm, p_ql = [0.05, 0.25, 0.75, 0.95], p_ci = 1)
  ## Compile stats for selected columns of a matrix
  ##
  ## p_mm ... value matrix, [[<dbl>]]
  ## p_ci ... column index, <uint>
  ## r_st ... return column stats [q_low, q1, median, q3, q_high, mean, estd, min, max]
  
  x = p_mm(:, p_ci); # sample
  
  qv = quantile(x, p_ql);
  r_st = [qv(1), qv(2), median(x), qv(3), qv(4), mean(x), std(x), min(x), max(x)];
  
endfunction


function [r_fh] = sf_stats_plot(p_mm, p_ti, p_xlu, p_ylu, p_xtl, p_iv = 0, p_cm, p_ql)
  ## Plot stats for selected columns of a matrix
  ##
  ## p_mm  ... value matrix, last row = overall stats, [[<dbl>]]
  ## p_ti  ... figure title, <str>
  ## p_xlu ... x axis label and unit, {<str>}
  ## p_ylu ... y axis label and unit, {<str>}
  ## p_iv  ... initial value or the optimisation, <dbl>
  ## p_cm  ... colour map [N x 3], [<dbl>]
  ## p_ql  ... quantile limits [1 x 4], [<dbl>]
  ## r_fh  ... return: figure handle, <uint>
  
  ## matrix p_mm
  ## c1 = sample size N = |x|
  ## c2 = q_0.05(x)
  ## c3 = q_0.25(x)
  ## c4 = median(x)
  ## c5 = q_0.75(x)
  ## c6 = q_0.95(x)
  ## c7 = mean(x)
  ## c8 = empirical standard deviation estd(x)
  ## c9 = min(x)
  ## c10 = max(x)
  
  ## select colours
  bw = [0.6, 0.3, 0.25]; # box width settings
  
  ## prepare data
  Nrow = size(p_mm, 1) - 1;
  xx = [1 : Nrow, Nrow + 1.4];
  yy = p_mm(:, [4, 3, 5, 2, 6]); # [median/mean, quartile_1/low_1, quartile_3/high_1, min/low_2, max/high_2]
  
  ## prepare plot range
  ymin = p_mm(end, 9);
  ymax = p_mm(end, 10);
  yrng = ymax - ymin;
  xl = [xx(1) - 0.5, xx(end) + 0.5]; # x axis limits
  yl = [ymin - 0.1 * yrng, ymax + 0.25 * yrng]; # y axis limits
  
  ## create figure
  [r_fh, ah] = tool_plot_create_figure(6, p_ti, false);
  set(r_fh, 'position', [100, 100, 640, 0.62*640]);
  
  ## plot results
  hold(ah, 'on');
  have_leg = false;
  for k = 1 : Nrow + 1
    ## plot dots, min/max
    plot(ah, [1, 1] * xx(k), p_mm(k, 9:10), 'color', [1, 1, 1] * 0.75, 'handlevisibility', 'off'); # connection line between min and max
    if (k == 1)
      have_leg = true;
      plot(ah, xx(k), p_mm(k, 9), 'ob', 'markersize', 5, 'markerfacecolor', 'b', 'displayname', 'min'); # min
      plot(ah, xx(k), p_mm(k, 10), 'or', 'markersize', 5, 'markerfacecolor', 'r', 'displayname', 'max'); # max
    else
      plot(ah, xx(k), p_mm(k, 9), 'ob', 'markersize', 5, 'markerfacecolor', 'b', 'handlevisibility', 'off'); # min
      plot(ah, xx(k), p_mm(k, 10), 'or', 'markersize', 5, 'markerfacecolor', 'r', 'handlevisibility', 'off'); # max
    endif
    ## plot boxes with whiskers
    ph = tool_plot_errorbar_extended(ah, xx(k), yy(k, :), sh = 'box', lw = [2, 1], lc = 'k', p_cm(k, :), bw, '', false);
    for j = 1 : numel(ph)
      if not(isnan(ph(j)))
        set(ph(j), 'handlevisibility', 'off');
      endif
    endfor
    ## annotation
    text(ah, xx(k), ymin - 0.08 * yrng, sprintf('n = %d', p_mm(k, 1)), 'horizontalalignment', 'center', 'verticalalignment', 'bottom'); # N
    if (k == Nrow + 1)
      text(ah, xx(k) + bw(2) * 0.5, p_mm(k, 2), sprintf(' q_{%.2f}', p_ql(1)), ...
        'horizontalalignment', 'left', 'verticalalignment', 'top'); # q_0.05
      text(ah, xx(k) + bw(1) * 0.5, p_mm(k, 3), sprintf(' q_{%.2f}', p_ql(2)), ...
        'horizontalalignment', 'left', 'verticalalignment', 'top'); # q_0.25
      text(ah, xx(k) + bw(1) * 0.5, p_mm(k, 4), ' median', ...
        'horizontalalignment', 'left', 'verticalalignment', 'middle'); # median
      text(ah, xx(k) + bw(1) * 0.5, p_mm(k, 5), sprintf(' q_{%.2f}', p_ql(3)), ...
        'horizontalalignment', 'left', 'verticalalignment', 'bottom'); # q_0.75
      text(ah, xx(k) + bw(2) * 0.5, p_mm(k, 6), sprintf(' q_{%.2f}', p_ql(4)), ...
        'horizontalalignment', 'left', 'verticalalignment', 'bottom'); # q_0.95
    endif
  endfor
  ## initial value
  if (p_iv > 0)
    plot(ah, xl, [1, 1] * p_iv, '-r', 'displayname', sprintf('init. value = %.2f', p_iv));
    have_leg = true;
  endif
  hold(ah, 'off');
  
  ## add annotation
  xticks(ah, xx);
  xticklabels(ah, p_xtl);
  tool_plot_axes_annotate(ah, p_xlu, p_ylu, p_ti, []);
  xlim(ah, xl);
  ylim(ah, yl);
  if (have_leg)
    legend(ah, 'location', 'northwest', 'box', 'off', 'numcolumns', 3);
  endif
  
endfunction


function [r_n, r_v, r_e] = sf_select_index(p_xx, p_ww, p_ti)
  ## Visualise signal and select signal sample index
  ##
  ## p_xx ... signal amplitude array, [<dbl>]
  ## p_ww ... x axis limits, window limits, [<uint>, <uint>]
  ## p_ti ... figure title, <str>
  ## r_n  ... return: selected signal sample index , <uint>
  ## r_v  ... return: signal amplitude at selected sample index, <dbl>
  ## r_e  ... return: error state, false = success, true = failure, <bool>
  
  ## y range
  ymin = min(p_xx(p_ww(1) : p_ww(2)));
  ymax = max(p_xx(p_ww(1) : p_ww(2)));
  yrng = ymax - ymin;
  
  ## plot signal
  fh = figure();
  ah = axes(fh, 'tickdir', 'out');
  grid on;
  hold(ah, 'on');
  plot(ah, p_xx, '-k;signal;')
  xlim(ah, p_ww);
  ylim(ah, [ymin - yrng * 0.15, ymax + yrng * 0.15]);
  xlabel(ah, 'Sample index [1]');
  ylabel(ah, 'Amplitude [V]');
  title(ah, sprintf('%s', sprintf('%s\nleft mouse button = select', p_ti)));
  
  ## select index
  [r_n, r_v, r_e] = sf_sel(ah, p_xx, p_ti);
  hold(ah, 'off');
  
  ## close window
  close(fh);
  
endfunction


function [r_x, r_y, r_e] = sf_sel(p_ah, p_xx, p_ti)
  ## Select signal sample index
  ##
  ## p_ah ... axes handle, <dbl>
  ## p_xx ... signal amplitude array, [<dbl>]
  ## p_ti ... figure title, <str>
  ## r_x  ... return: selected sample index, <uint>
  ## r_y  ... return: signal amplitude at selected sample index, <dbl>
  ## r_e  ... return: error state, false = success, true = failure, <bool>
  
  ## init return values
  r_e = true;
  r_x = 0;
  r_y = 0;
  
  ## select index
  c = false;
  cnt = 0;
  while ((c == false) && (cnt <= 5))
    cnt += 1;
    [xcrd, ycrd, ~] = ginput(1);
    r_e = isempty(xcrd);
    if (r_e)
      continue;
    endif
    r_x = round(xcrd);
    r_y = p_xx(r_x);
    ph = plot(p_ah, r_x, r_y, 'or', 'linewidth', 2, 'handlevisibility', 'off'); # plot selected point on signal
    title(p_ah, sprintf('%s\nmiddle/right mouse button and space = confirm, ESC = abort selection', p_ti));
    drawnow;
    [t1, t2, but] = ginput(1);
    switch (but)
      case {2, 3, 32}
        ## selection confirmed, right/middle mouse button or space bar
        c = true;
        r_e = false;
      case {27}
        ## aborted by escape button
        r_e = true;
        break;
      otherwise
        ## continue selecting a point
        delete(ph);
        continue;
    endswitch
  endwhile
  
endfunction
