## Estimate the cycle ratio of the signal model's maximum point
##
## Usage: [r_cr] = tool_cyrat_sigmod(p_mp)
##
## p_mp ... signal model parameter array [1 x 5], [<dbl>]
## r_cr ... return: estimate cycle ratio, <dbl>
##
## see also: tool_gen_signal.m
##
## Note:
##   The cycle ratio cr is the ratio of the maximum point sample index and the number of samples for one full cycle:
##   cr = N / n_max
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
function [r_cr] = tool_cyrat_sigmod(p_mp)
  
  ## generate signal
  mp = p_mp; # copy signal model parameter array
  mp(2) = 1; # set frequency to 1
  [ss, nn, N] = tool_gen_signal(Fs = 1e8, Nc = 1, p_mp);
  
  ## locate maximum point
  [vmax, nmax] = max(ss);
  
  ## calculate the maximum point's cycle ratio
  r_cr = nmax / N;

endfunction
