## Create figure and axes and return figure and axes handle
##
## Usage: [r_fh, r_ah] = tool_plot_create_figure(p_en, p_ft, p_gm)
##
## p_en ... algorithm part enumerator, <uint>
## p_ft ... figure title, <str>
## p_gm  .. grid mode (true = show, false = hide), optional, default = false, <bool>
## r_fh ... return: figure handle, <uint>
## r_ah ... return: axes handle, <dbl>
##     
## see also: figure, axes, grid
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
function [r_fh, r_ah] = tool_plot_create_figure(p_en, p_ft, p_gm = false)
  
  ## create figure
  r_fh = figure('name', sprintf('Algorithm part %d, %s', p_en, p_ft), 'position', [100, 100, 800, 800*0.62]);
  
  ## create axes
  r_ah = axes(r_fh, 'tickdir', 'out');
  
  ## show/hide grid
  if (p_gm)
    grid(r_ah, 'on');
  else
    grid(r_ah, 'off');
  endif
  
  ## add copyright information
  annotation(r_fh, 'textbox', [0.01, 0.01, 0.9, 0.05], 'string', 'CC BY 4.0 (2025) Jakob Harden (Graz University of Technology)', ...
    'linestyle', 'none', 'fontsize', 8);
  
endfunction
