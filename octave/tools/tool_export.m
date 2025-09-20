## Export analysis results and figures to files
##
## Usage: tool_export(p_ds, p_fh, p_odp, p_dsn, p_apfx, p_rpfx)
##
## p_ds   ... analysis result data structure, <struct>
## p_fh   ... figure handles, <uint> or [<uint>]
## p_odp  ... output directory path, <str>
## p_dsn  ... dataset name (used for TeX export), <str>
## p_apfx ... algorithm type prefix, <str>
## p_rpfx ... result type prefix, <str>
##
## see also: save, saveas, hgsave, tex_struct_export
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
function tool_export(p_ds, p_fh, p_odp, p_dsn, p_apfx, p_rpfx)
  
  ## check arguments
  if (nargin < 6)
    p_rpfx = [];
  endif
  if (nargin < 5)
    help tool_export;
    error('Less arguments given!');
  endif
  
  ## file name prefix
  fnpfx = p_apfx;
  if not(isempty(p_rpfx))
    fnpfx = sprintf('%s_%s', fnpfx, p_rpfx);
  endif
  
  ## dataset name
  dsn_tex = strrep(sprintf('%s.%s', p_apfx, p_dsn), '_', '');
  
  ## create directories
  if (exist(p_odp, 'dir') != 7)
    mkdir(p_odp);
  endif
  if (exist(fullfile(p_odp, 'oct'), 'dir') != 7)
    mkdir(fullfile(p_odp, 'oct'));
  endif
  if (exist(fullfile(p_odp, 'fig'), 'dir') != 7)
    mkdir(fullfile(p_odp, 'fig'));
  endif
  if (exist(fullfile(p_odp, 'png'), 'dir') != 7)
    mkdir(fullfile(p_odp, 'png'));
  endif
  if (exist(fullfile(p_odp, 'tex'), 'dir') != 7)
    mkdir(fullfile(p_odp, 'tex'));
  endif
  
  ## export binary data file
  ads = p_ds;
  save('-binary', fullfile(p_odp, 'oct', sprintf('%s.oct', fnpfx)), 'ads');
  
  ## export TeX file
  tex_struct_export(ads, dsn_tex, fullfile(p_odp, 'tex', fnpfx));
  
  ## export figures
  for j = 1 : length(p_fh)
    if (length(p_fh) == 1)
      idxstr = '';
    else
      idxstr = sprintf('_%d', j);
    endif
    ## save figure
    hgsave(p_fh(j), fullfile(p_odp, 'fig', sprintf('%s%s.ofig', fnpfx, idxstr)));
    ## save bitmap
    saveas(p_fh(j), fullfile(p_odp, 'png', sprintf('%s%s.png', fnpfx, idxstr)), 'png');
    ## close figure
    close(p_fh(j));
  endfor
  
endfunction

