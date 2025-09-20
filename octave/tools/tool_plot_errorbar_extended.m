## Tool: Plot extended version of errorbars
##
## Usage: [r_ph] = tool_plot_errorbar_extended(p_ah, p_x, p_y, p_sh, p_lw, p_lc, p_fc, p_bw, p_le, p_cs)
##
## p_ah ... axes handle, <dbl>
## p_x  ... x coordinate array, [<dbl>]
## p_y  ... value matrix, see below, [[<dbl>]]
## p_sh ... errorbar shape enumerator, see below, <str>
## p_lw ... line width array, see below, [<dbl>]
## p_lc ... line color array, see below, {<str>} or [[<dbl>]]
## p_fc ... fill color array, see below, [[<dbl>]]
## p_bw ... x distance array, see below, [<dbl>]
## p_le ... legend entry, optional, default = "", <str>
## p_cs ... connect symbols with a line, true/false, <bool>
## r_ph ... return: plot handle array, [<dbl>]
##
## Errorbar shape enumerators:
##   p_sh = []: use default, p_sh = "phi"
##   p_sh = "phi": errorbar looks like the uppercase greek letter 'Phi' with whiskers
##   p_sh = "hex": errorbar is plotted as a hexagon with whiskers
##   p_sh = "dia": errorbar is plotted as a diamond symbol with whiskers
##   p_sh = "box": errorbar is plotted as a box symbol with whiskers
##
## Line width:
##   p_lw = []: use default, p_lw = [2, 1]
##   p_lw = [lw]: symbol line width lw, whiskers line width lw
##   p_lw = [lw1, lw2]: symbol line width lw1, whiskers line width lw2
##
## Line color:
##   p_lc = []: use default, p_lc = {"k"}, black
##   p_lc = {"lc"}: color given as string or cell string with one item, all symbols have the same line color lc
##   p_lc = {"lc_1", ..., "lc_N"}: color given as cell string, each symbol has a different line color lc_n
##   p_lc = [lc_r, lc_g, lc_b]: color given as RGB triple, all symbols have the same line color lc
##   p_lc = [lc_r_1, lc_g_1, lc_b_1; ...; lc_r_N, lc_g_N, lc_b_N]: color given as RGB matrix, each symbol has a different line color lc_n
##
## Fill color (symbol fill color, applies to p_sh = "hex" and p_sh = "dia"):
##   p_fc = []: use default, p_fc = [], no fill
##   p_fc = [fc_r, fc_g, fc_b]: all symbols have the same fill color fc
##   p_fc = [fc_r_1, fc_g_1, fc_b_1; ...; fc_r_N, fc_g_N, fc_b_N]: fill color given as RGB matrix, each symbol has a different fill color fc_n
##
## Box width array:
##   p_bw = []: use default, [bw1, bw2, bw3] = [0.5, 0.25, 0.125]
##   p_bw = [bw1]: symbol width bw1, first error bar width bw2 = bw1 / 2, second error bar width bw3 = dx2 / 2
##   p_bw = [bw1, bw2]: symbol width bw1, first error bar width bw2, second error bar width bw3 = bw2 / 2
##   p_bw = [bw1, bw2, bw3]: symbol width bw1, first error bar width bw2, second error bar width bw3
##
## Y data matrix, value matrix:
##   p_y = [N x 3]: row vector [median/mean, quartile_1/low_1, quartile_3/high_1], do not plot whiskers for min and max
##   p_y = [N x 5]: row vector [median/mean, quartile_1/low_1, quartile_3/high_1, min/low_2, max/high_2], plot whiskers to min and max
##
## Plot handles r_ph:
##   This function returns a list of 9 plot handles for all symbol components. Non-existing components are represented by NaN.
##
## Note:
##   This command should only be used inside a hold-environment.
##   Example usage:
##   ...
##   hold on;
##   [r_ph] = tool_plot_errorbar_extended(p_ah, p_x, p_y, p_sh, p_lw, p_lc, p_fc, p_bw, p_le);
##   hold off;
##
## Symbol shapes:
##   Phi-symbol         Diamond-symbol   Hexagon symbol   Box symbol
##     ---  max/high_2       ---             ---             ---
##      |                     |               |               |
##    ----- q3/high_1        / \             ---            +---+
##      |                   /   \           /   \           |   |
##      o   median/mean    +-----+         +-----+          +---+
##      |                   \   /           \   /           |   |
##    ----- q1/low_1         \ /             ---            +---+
##      |                     |               |               |
##     ---  min/low_2        ---             ---             ---
##
## see also: plot
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
function [r_ph] = tool_plot_errorbar_extended(p_ah, p_x, p_y, p_sh = 'box', p_lw = [2, 1], p_lc = 'k', p_fc = [], ...
  p_bw = [0.5, 0.25, 0.125], p_le = '', p_cs = false)
  
  ## check arguments
  if (nargin < 10)
    p_cs = [];
  endif
  if (nargin < 9)
    p_le = [];
  endif
  if (nargin < 8)
    p_bw = [];
  endif
  if (nargin < 7)
    p_fc = [];
  endif
  if (nargin < 6)
    p_lc = {};
  endif
  if (nargin < 5)
    p_lw = [];
  endif
  if (nargin < 4)
    p_sh = [];
  endif
  if (nargin < 3)
    help tool_plot_errbar_extended;
    error('Less arguments given!');
  endif
  
  ## x coordinate array
  if isempty(p_x)
    p_x = 1 : size(p_y, 1);
  endif
  N = length(p_x);
  
  ## y data matrix
  plt_whiskers = false;
  if (size(p_y, 2) < 3)
    error('Y data matrix must have at least 3 columns!');
  elseif (size(p_y, 1) < N)
    error('Number of Y data matrix rows and x coordinate array length does not match! %d != %d', size(p_y, 1), N);
  elseif (size(p_y, 2) <= 4)
    p_y = p_y(:, 1 : 3);
    plt_whiskers = false;
  elseif (size(p_y, 2) >= 5)
    p_y = p_y(:, 1 : 5);
    plt_whiskers = true;
  endif
  
  ## symbol shape
  if isempty(p_sh)
    p_sh = 'phi';
  endif
  p_sh = lower(p_sh);
  switch (p_sh)
    case {'p', 'phi'}
      p_sh = 'phi';
    case {'d', 'dia', 'diamond'}
      p_sh = 'dia';
    case {'h', 'hex', 'hexa', 'hexagon'}
      p_sh = 'hex';
    case {'b', 'box'}
      p_sh = 'box';
    otherwise
      error('Symbol shape %s not implemented yet!', p_sh);
  endswitch
  
  ## line width
  if isempty(p_lw)
    p_lw = [2, 1];
  elseif (length(p_lw) == 1)
    p_lw = [p_lw, p_lw];
  endif
  lw1 = p_lw(1);
  lw2 = p_lw(2);
  
  ## line color
  if isempty(p_lc)
    p_lc = {'b', 'k'};
  endif
  if iscell(p_lc)
    if (length(p_lc) == 1)
      p_lc = repmat(p_lc{1}, N, 1);
    elseif (length(p_lc) != N)
      error('Length of line color cell array and xcoordinate array does not match! %d != %d', length(p_lc), N);
    endif
  elseif isalpha(p_lc(1))
    p_lc = repmat(p_lc(1), N, 1);
  else
    if (size(p_lc, 2) != 3)
      error('Line color is not a RGB triple!');
    endif
    if (size(p_lc, 1) == 1)
      p_lc = repmat(p_lc(1:3), N, 1);
    elseif (size(p_lc, 1) != N)
      error('Row number of line color RGB matrix and xcoordinate array length do not match! %d != %d', size(p_lc, 1), N);
    else
      p_lc = p_lc(:, 1:3);
    endif
  endif
  
  ## fill color
  plt_fill = false;
  if not(isempty(p_fc))
    if (size(p_fc, 2) != 3)
      error('Fill color is not a RGB triple!');
    endif
    if (size(p_fc, 1) == 1)
      p_fc = repmat(p_fc(1:3), N, 1);
    elseif (size(p_fc, 1) != N)
      error('Row number of fill color RGB matrix and x coordinate array length do not match! %d != %d', size(p_fc, 1), N);
    else
      p_fc = p_fc(:, 1:3);
    endif
    plt_fill = true;
  endif
  
  ## box width array
  if isempty(p_bw)
    p_bw = [0.5, 0.25, 0.125];
  endif
  if (length(p_bw) == 1)
    p_bw = [p_bw, p_bw / 2, p_bw / 4];
  elseif (length(p_bw) == 2)
    p_bw = [p_bw(1), p_bw(2), p_bw(2) / 2];
  endif
  dx1 = p_bw(1) / 2;
  dx2 = p_bw(2) / 2;
  dx3 = p_bw(3) / 2;
  
  ## legend entry
  plt_legend = true;
  if isempty(p_le)
    plt_legend = false;
  endif
  
  ## symbol connection lines
  if isempty(p_cs)
    plt_connect = true;
  else
    plt_connect = p_cs;
  endif
  
  ## iterate over data points
  r_ph = zeros(N, 10);
  for j = 1 : N
    x = p_x(j);
    ## horizontal position
    xl1 = x - dx1;
    xr1 = x + dx1;
    xl2 = x - dx2;
    xr2 = x + dx2;
    ## vertical position
    y1 = p_y(j, 1); # median/mean
    y2 = p_y(j, 2); # q1/low_1
    y3 = p_y(j, 3); # q3/high_1
    ## line color
    if iscellstr(p_lc)
      lc_j = p_lc{j};
      lc_0 = p_lc{1};
    else
      lc_j = p_lc(j, :);
      lc_0 = p_lc(1, :);
    endif
    ## plot fill
    if (plt_fill)
      ## fill color
      fc_j = p_fc(j, :);
      ## fill symbol
      switch (p_sh)
        case 'dia'
          r_ph(j, 5) = fill(p_ah, [x, xr1, x, xl1, x], [y2, y1, y3, y1, y2], fc_j);
        case 'hex'
          r_ph(j, 5) = fill(p_ah, [xl2, xr2, xr1, xr2, xl2, xl1, xl2], [y2, y2, y1, y3, y3, y1, y2], fc_j);
        case 'box'
          r_ph(j, 5) = fill(p_ah, [xl1, xr1, xr1, xl1, xl1], [y2, y2, y3, y3, y2], fc_j);
        otherwise
          r_ph(j, 5) = NaN;
      endswitch
    endif
    ## plot whiskers
    if (plt_whiskers)
      ## horizontal position
      xl3 = x - dx3;
      xr3 = x + dx3;
      ## vertical position
      y4 = p_y(j, 4); # min/low_2
      y5 = p_y(j, 5); # max/high_2
      ## plot lines
      r_ph(j, 1) = plot(p_ah, [xl3, xr3], [1, 1] * y4, 'linewidth', lw2, 'color', lc_j, 'HandleVisibility', 'off'); # hor. line, min
      r_ph(j, 2) = plot(p_ah, [xl3, xr3], [1, 1] * y5, 'linewidth', lw2, 'color', lc_j, 'HandleVisibility', 'off'); # hor. line, max
      r_ph(j, 3) = plot(p_ah, [1, 1] * x, [y4, y2], 'linewidth', lw2, 'color', lc_j, 'HandleVisibility', 'off'); # vert. line, min-q1
      r_ph(j, 4) = plot(p_ah, [1, 1] * x, [y3, y5], 'linewidth', lw2, 'color', lc_j, 'HandleVisibility', 'off'); # vert. line q3-max
    else
      r_ph(j, 1) = NaN;
      r_ph(j, 2) = NaN;
      r_ph(j, 3) = NaN;
      r_ph(j, 4) = NaN;
    endif
    ## handle visibility
    hvis = 'off';
    if ((j == 1) && plt_legend)
      hvis = 'on';
    endif
    ## plot symbol
    switch (p_sh)
      case 'phi'
        r_ph(j, 6) = plot(p_ah, [xl2, xr2], [1, 1] * y2, 'linewidth', lw1, 'color', lc_j, 'HandleVisibility', 'off'); # hor. line, q1
        r_ph(j, 7) = plot(p_ah, [xl2, xr2], [1, 1] * y3, 'linewidth', lw1, 'color', lc_j, 'HandleVisibility', 'off'); # hor. line, q3
        r_ph(j, 8) = plot(p_ah, [1, 1] * x, [y2, y3], 'linewidth', lw1, 'color', lc_j, 'HandleVisibility', 'off'); # vert. line, q1-q3
        if (plt_legend)
          r_ph(j, 9) = plot(p_ah, x, y1, 'o', 'linewidth', lw1, 'color', lc_j, 'HandleVisibility', hvis, 'displayname', p_le); # circle, median
        else
          r_ph(j, 9) = plot(p_ah, x, y1, 'o', 'linewidth', lw1, 'color', lc_j, 'HandleVisibility', hvis); # circle, median
        endif
      case 'dia'
        if (plt_legend)
          r_ph(j, 6) = plot(p_ah, [xl1, xr1], [1, 1] * y1, ...
            'linewidth', lw1, 'color', lc_j, 'HandleVisibility', hvis), 'displayname', p_le; # hor. line, median
        else
          r_ph(j, 6) = plot(p_ah, [xl1, xr1], [1, 1] * y1, ...
            'linewidth', lw1, 'color', lc_j, 'HandleVisibility', hvis); # hor. line, median
        endif
        r_ph(j, 7) = plot(p_ah, [x, xr1, x, xl1, x], [y2, y1, y3, y1, y2], ...
          'linewidth', lw1, 'color', lc_j, 'HandleVisibility', 'off'); # diamond, q1-q3
        r_ph(j, 8) = NaN;
        r_ph(j, 9) = NaN;
      case 'hex'
        if (plt_legend)
          r_ph(j, 6) = plot(p_ah, [xl1, xr1], [1, 1] * y1, ...
            'linewidth', lw1, 'color', lc_j, 'HandleVisibility', hvis, 'displayname', p_le); # hor. line, median
        else
          r_ph(j, 6) = plot(p_ah, [xl1, xr1], [1, 1] * y1, ...
            'linewidth', lw1, 'color', lc_j, 'HandleVisibility', hvis); # hor. line, median
        endif
        r_ph(j, 7) = plot(p_ah, [xl2, xr2, xr1, xr2, xl2, xl1, xl2], [y2, y2, y1, y3, y3, y1, y2], ...
          'linewidth', lw1, 'color', lc_j, 'HandleVisibility', 'off'); # hexagon, q1-q3
        r_ph(j, 8) = NaN;
        r_ph(j, 9) = NaN;
      case 'box'
        if (plt_legend)
          r_ph(j, 6) = plot(p_ah, [xl1, xr1], [1, 1] * y1, ...
            'linewidth', lw1, 'color', lc_j, 'HandleVisibility', hvis, 'displayname', p_le); # hor. line, median
        else
          r_ph(j, 6) = plot(p_ah, [xl1, xr1], [1, 1] * y1, ...
            'linewidth', lw1, 'color', lc_j, 'HandleVisibility', hvis); # hor. line, median
        endif
        r_ph(j, 7) = plot(p_ah, [xl1, xr1, xr1, xl1, xl1], [y2, y2, y3, y3, y2], ...
          'linewidth', lw1, 'color', lc_j, 'HandleVisibility', 'off'); # box, q1-q3
        r_ph(j, 8) = NaN;
        r_ph(j, 9) = NaN;
    endswitch
  endfor
  
  ## plot connection lines (connect median points)
  if (plt_connect)
    ## line color
    if iscellstr(p_lc)
      lccon = p_lc{1};
    else
      lccon = p_lc(1, :);
    endif
    r_ph(j, 10) = plot(p_ah, p_x, p_y(:, 1), 'color', lccon, 'linewidth', lw1, 'HandleVisibility', 'off');
  else
    r_ph(j, 10) = NaN;
  endif
  
endfunction
