## Annotate axes
##
## Usage: tool_plot_axes_annotate(p_ah, p_xl, p_yl, p_at, p_ll)
##
## p_ah ... axes handle, <dbl>
## p_xl ... x axis label, <str> or {<str>}
## p_yl ... y axis label, <str> or {<str>}
## p_ti ... title, <str> or {<str>}
## p_ll ... legend location, optional, default = [], <str>
##     
## see also: xlabel, ylabel, title, legend
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
function tool_plot_axes_annotate(p_ah, p_xl = '', p_yl = '', p_at = '', p_ll = [])
  
  ## check arguments
  if (nargin < 5)
    p_ll = [];
  endif
  
  ## x axis label
  if iscellstr(p_xl)
    xlabel(p_ah, sprintf('%s [%s]', p_xl{1}, p_xl{2}));
  else
    if not(isempty(p_xl))
      xlabel(p_ah, p_xl);
    endif
  endif
  
  ## y axis label
  if iscellstr(p_yl)
    ylabel(p_ah, sprintf('%s [%s]', p_yl{1}, p_yl{2}));
  else
    if not(isempty(p_yl))
      ylabel(p_ah, p_yl);
    endif
  endif
  
  ## axes title
  if iscellstr(p_at)
    title(p_ah, sprintf('%s\n%s', p_at{1}, p_at{2}));
  else
    if not(isempty(p_at))
      title(p_ah, p_at);
    endif
  endif
  
  ## default legend format
  if not(isempty(p_ll))
    if not(strcmpi(p_ll, 'none'))
      legend(p_ah, 'box', 'off', 'location', p_ll);
    else
      legend(p_ah, 'box', 'off');
    endif
  endif
  
endfunction
