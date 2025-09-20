## Find maximum value and position based on a polynomial regression
##
## Usage: [r_mv, r_mi] = tool_max_polyreg(p_xx, p_i0, p_i1)
##
## p_xx ... signal magnitude series, [<dbl>]
## p_i0 ... detection interval, start index, <uint>
## p_i1 ... detection interval, end index, <uint>
## p_ro ... regression order, optional, default = 2, <uint>
## r_mv ... return: maximum value, <dbl>
## r_mi ... return: maximum index, <uint>
## r_es ... return: error state, true = failure, false = success, <bool>
##
## Note: this function can be used to find a smooth maximum on noisy signal data
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
function [r_mv, r_mi, r_es] = tool_max_polyreg(p_xx, p_i0, p_i1, p_ro)
  
  ## initialise return values
  r_mv = 0;
  r_mi = 0;
  r_es = true;
  
  ## select data
  nn = p_i0 : p_i1;
  xx = p_xx(nn);
  
  ## first guess for the maximum location and value
  [v1, i1] = max(xx);
  
  ## select data for the regression analysis
  nr = fix((p_i1 - p_i0) / 4); # use data of 1/4 of the detection interval
  nr = max([10, nr]); # use at least 10 samples
  nr1 = fix(nr / 2);
  nr2 = nr - nr1;
  i0reg = i1 - nr1 + 1; # lower limit of regression interval
  i1reg = i1 + nr2 - 1; # upper limit of regression interval
  
  ## determine regression interval
  Nxx = numel(xx);
  if ((i0reg < 1) || (i0reg > Nxx))
    return;
  endif
  if ((i1reg < 1) || (i1reg > Nxx))
    return;
  endif
  nnreg = i0reg : i1reg; # regression interval
  
  ## polynomial regression of nth order
  [p, s, mu] = polyfit(nnreg(:), xx(nnreg)(:), p_ro);
  yy = s.yf;
  
  ## maximum of regression polynome
  [mv, mi] = max(yy);
  r_mv = mv;
  r_mi = p_i0 + i0reg + mi - 2;
  
  ## update error state
  r_es = false;
  
  ## plot results
##  figure();
##  hold on;
##  plot(nn, xx, '-k;signal;');
##  plot(p_i0 + nnreg - 1, yy, '-r;polynome;', 'linewidth', 2);
##  plot(r_mi, r_mv, 'ob;max;');
##  hold off;
  
endfunction
