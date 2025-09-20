## Serialize matrix value to TeX code (tabulated)
##
## FUNCTION SYNOPSIS:
##
## Usage 1: [r_tc] = tex_def_tabmesh(p_ss, p_vn, p_x, p_y, p_z, p_tc) ... append output to TeX code listing p_tc
##
## Usage 2: [r_tc] = tex_def_tabmesh(p_ss, p_vn, p_x, p_y, p_z) .. create TeX code listing
##
## p_ss ... serialization settings data structure, <struct_tex_settings>
## p_vn ... variable name, <str>
## p_x  ... x coordinate matrix (e.g. output of meshgrid), optional, default = [], [[<dbl>]]
## p_y  ... y coordinate matrix (e.g. output of meshgrid), optional, default = [], [[<dbl>]]
## p_z  ... z coordinate/value matrix, [[<dbl>]]
## p_tc ... TeX code listing to be updated, optional, {<str>}
## r_tc ... return: TeX code listing (usage 1) or TeX code for variable (usage 2), {<str>} or <str>
##
## see also: tex_settings.m, tex_serialize.m
##
## Output format (table with blocks of 4 patch points separated by an empty line):
## \begin{filecontents}{<variable-name>}
##    1 1 3.1
##    1 2 4.2
##    2 2 2.1
##    2 1 1.1
##    
##    2 1 1.1
##    2 2 2.1
##    3 2 5.4
##    3 1 3.3
##    
##    ...
## \end{filecontents}
##
## Copyright 2025 Jakob Harden (jakob.harden@tugraz.at, Graz University of Technology, Graz, Austria)
## License: MIT
## This file is part of the PhD thesis of Jakob Harden.
## 
## Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
## documentation files (the “Software”), to deal in the Software without restriction, including without 
## limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of 
## the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
## 
## THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO 
## THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
## TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
##
function [r_tc] = tex_def_tabmesh(p_ss, p_vn, p_x, p_y, p_z, p_tc)
  
  ## check arguments
  if (nargin < 5)
    help tex_def_tabmesh;
    error('Less arguments given!');
  endif
  if (nargin < 6)
    append_list = false;
  else
    append_list = true;
  endif
  
  ## set default values
  if isempty(p_ss)
    p_ss = tex_settings();
  endif
  
  ## render TeX code
  if (isempty(p_z) || isempty(p_x) || isempty(p_y))
    if append_list
      r_tc = p_tc;
    else
      r_tc = '';
    endif
  else
    ## create TeX environment header
    str_head = [p_ss.ser.env_fc_begin, '{', p_vn, '}'];
    ## create TeX environment footer
    str_foot = p_ss.ser.env_fc_end;
    ## add coordinate list for all patches
    str_crdlst = hlp_crdlst(p_x, p_y, p_z);
    if append_list
      ## append to given list: environment header, patch coordinate list, environment footer
      r_tc = [p_tc; str_head; str_crdlst; str_foot];
    else
      ## return list: environment header, patch coordinate list, environment footer
      r_tc = [str_head; str_crdlst; str_foot];
    endif
  endif
  
endfunction

############################################################################################################################################
function [r_str] = hlp_crdlst(p_x, p_y, p_z)
  ## Render coordinate list
  ##
  ## p_x ... x coordinate matrix, [[<dbl>]]
  ## p_y ... y coordinate matrix, [[<dbl>]]
  ## p_z ... z coordinate matrix, [[<dbl>]]
  
  ## example matrices
  ##
  ##     1  2  3  4       1  1  1  1       0.1  0.7  0.2  0.4
  ## x = 1  2  3  4 ; y = 2  2  2  2 ; z = 0.5  0.3  0.4  0.8
  ##     1  2  3  4       3  3  3  3       0.8  0.1  0.6  0.9
  
  [Nr, Nc] = size(p_z);
  r_str = {};
  lempty = '    ';
  for r = 1 : Nr
    for c = 1 : Nc
      crd = sprintf('    %.8f %.8f %.8f', p_x(r, c), p_y(r, c), p_z(r, c));
      r_str = [r_str; crd];
    endfor
    if not((r == Nr) && (c == Nc))
      r_str = [r_str; lempty];
    endif
  endfor
  
endfunction
