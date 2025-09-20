## Serialize array value to TeX code (tabulated)
##
## FUNCTION SYNOPSIS:
##
## Usage 1: [r_tc] = tex_def_tabarray(p_ss, p_vn, p_vt, p_vv, p_tc)
##                     non-interactive mode
##                     update existing TeX code listing
##
## Usage 2: [r_tc] = tex_def_tabarray(p_ss, p_vn, p_vt, p_vv, [])
##          [r_tc] = tex_def_tabarray(p_ss, p_vn, p_vt, p_vv)
##                     non-interactive mode
##                     return TeX code for variable only
##
## Usage 3: [r_tc] = tex_def_tabarray([], p_vn, p_vt, p_vv, p_tc)
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
##    idx ; val
##    1   ; x_1
##    ... ; ...
##    i   ; x_i
##    ... ; ...
##    n   ; x_n
## \end{filecontents}
##
## x_i can be a number or a string (strings must not contain semicolon!)
## i = 1,n ... row index
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
function [r_tc] = tex_def_tabarray(p_ss, p_vn, p_vt, p_vv, p_tc)
  
  ## check arguments
  if (nargin < 4)
    help tex_def_tabarray;
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
    ## created TeX environment header
    str_head = [p_ss.ser.env_fc_begin, '{', p_vn, '}'];
    ## create TeX environment footer
    str_foot = p_ss.ser.env_fc_end;
    ## number of array elements
    elem_sz = numel(p_vv);
    ## limit exported array elements (see also tex_settings.m)
    nelem = min([elem_sz, p_ss.ser.array_maxelems]);
    if (nelem < elem_sz)
      printf('INFO:\n  The number of exported array elements is reduced from %d to %d!\n  Export limit exceeded (ser.array_maxelems). See also: tex_settings.m\n', elem_sz, nelem);
    endif
    ## add column header, row 1, semicolon separated
    str_rows = {'idx ; val'};
    ## add row for each array item
    if iscellstr(p_vv)
      for i = 1 : nelem
        idx = sprintf('%d', i);
        val = tex_serialize(p_ss, p_vt, p_vv{i});
        str_rows = [str_rows; [idx, ' ; ', val]];
      endfor
    else
      for i = 1 : nelem
        idx = sprintf('%d', i);
        val = tex_serialize(p_ss, p_vt, p_vv(i));
        str_rows = [str_rows; [idx, ' ; ', val]];
      endfor
    endif
    if append_list
      ## append to given list: environment header, rows, environment footer
      r_tc = [p_tc; str_head; str_rows; str_foot];
    else
      ## return list: environment header, rows, environment footer
      r_tc = [str_head; str_rows; str_foot];
    endif
  endif
  
endfunction
