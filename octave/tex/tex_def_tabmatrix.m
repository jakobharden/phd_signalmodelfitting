## Serialize matrix value to TeX code (tabulated)
##
## FUNCTION SYNOPSIS:
##
## Usage 1: [[r_tc] = tex_def_tabmatrix(p_ss, p_vn, p_vt, p_vv, p_tc)
##                     non-interactive mode
##                     update existing TeX code listing
##
## Usage 2: [r_tc] = tex_def_tabmatrix(p_ss, p_vn, p_vt, p_vv, [])
##          [r_tc] = tex_def_tabmatrix(p_ss, p_vn, p_vt, p_vv)
##                     non-interactive mode
##                     return TeX code for variable only
##
## Usage 3: [[r_tc] = tex_def_tabmatrix([], p_vn, p_vt, p_vv, p_tc)
##                     non-interactive mode
##                     load default TeX serialization settings (see tex_settings.m)
##
## p_ss ... serialization settings data structure, <struct_tex_settings>
## p_vn ... variable name, <str>
## p_vt ... variable type enumerator, <str>
## p_vv ... variable value, [<number>] or {<string>}
## p_tc ... TeX code listing to be updated, optional, {<str>}
## r_tc ... return: TeX code listing (usage 1) or TeX code for variable (usage 2), {<str>} or <str>
##
## see also: tex_settings.m, tex_serialize.m
##
## Output format:
## \begin{filecontents}{<variable-name>}
##    idx ; c1    ; ... ; cj    ; ... ; cm
##    1   ; x_1,1 ; ... ; x_1,j ; ... ; x_1,m
##    ... ; ...   ; ... ; ...   ; ... ; ...
##    i   ; x_i,1 ; ... ; x_i,j ; ... ; x_i,m
##    ... ; ...   ; ... ; ...   ; ... ; ...
##    n   ; x_n,1 ; ... ; x_n,j ; ... ; x_n,m
## \end{filecontents}
##
## x_i,j can be a number or a string (strings must not contain semicolon!)
## i = 1,n ... row index
## j = 1,m ... column index
##
## Copyright 2023 Jakob Harden (jakob.harden@tugraz.at, Graz University of Technology, Graz, Austria)
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
function [r_tc] = tex_def_tabmatrix(p_ss, p_vn, p_vt, p_vv, p_tc)
  
  ## check arguments
  if (nargin < 4)
    help tex_def_tabmatrix;
    error('Less arguments given!');
  endif
  if (nargin < 5)
    append_list = false;
  else
    append_list = true;
  endif
  
  ## set default values
  if isempty(p_ss)
    p_ss = tex_settings();
  endif
  
  ## render TeX code
  if isempty(p_vv)
    if append_list
      r_tc = p_tc;
    else
      r_tc = '';
    endif
  else
    ## number of rows
    row_sz = size(p_vv, 1);
    ## number of columns
    col_sz = size(p_vv, 2);
    ## limit exported matrix rows (see also tex_settings.m)
    nrow = min([row_sz, p_ss.ser.array_maxelems]);
    if (nrow < row_sz)
      printf('INFO:\n  The number of exported matrix rows is reduced from %d to %d!\n  Export limit exceeded (ser.array_maxelems). See also: tex_settings.m\n', row_sz, nrow);
    endif
    ## limit exported columns (see also tex_settings.m)
    ncol = min([col_sz, p_ss.ser.matrix_maxcols]);
    if (ncol < col_sz)
      printf('INFO:\n  The number of exported matrix columns is reduced from %d to %d!\n  Export limit exceeded (ser.matrix_maxcols). See also: tex_settings.m\n', col_sz, ncol);
    endif
    ## created TeX environment header
    str_head = [p_ss.ser.env_fc_begin, '{', p_vn, '}'];
    ## create TeX environment footer
    str_foot = p_ss.ser.env_fc_end;
    ## add column header
    str_rows = {hlp_colhead(ncol)};
    ## add matrix rows
    for i = 1 : nrow
      str_rows = [str_rows; hlp_row(p_ss, i, p_vt, p_vv(i, 1 : ncol))];
    endfor
    if append_list
      ## append to given list: environment header, matrix rows, environment footer
      r_tc = [p_tc; str_head; str_rows; str_foot];
    else
      ## return list: environment header, matrix rows, environment footer
      r_tc = [str_head; str_rows; str_foot];
    endif
  endif
  
endfunction

############################################################################################################################################
function [r_str] = hlp_colhead(p_ncol)
  ## Render column heads
  
  ## index column
  idx = 'idx';
  
  ## value columns
  valarr = sprintf(' ; c%d', 1 : p_ncol);
  
  ## return table header
  r_str = [idx, valarr];
  
endfunction

############################################################################################################################################
function [r_str] = hlp_row(p_s, p_i, p_t, p_v)
  ## Render table row
  ##
  ## p_s ... serialization settings data structure, <struct_tex_settings>
  ## p_i ... row index, <uint>
  ## p_t ... value type, <str>
  ## p_v ... value, <any>
  
  ## number of array elements
  ne = numel(p_v);
  
  ## serialize array
  strarr = cell(ne, 1);
  if iscellstr(p_v)
    for i = 1 : ne
      strarr(i) = tex_serialize(p_s, p_t, p_v{i});
    endfor
  else
    for i = 1 : ne
      strarr(i) = tex_serialize(p_s, p_t, p_v(i));
    endfor
  endif
  
  ## index column
  idx = sprintf('%d', p_i);
  
  ## value columns
  valarr = strjoin(strarr, ' ; ');
  
  # return row
  r_str = [idx, ' ; ', valarr];
  
endfunction
