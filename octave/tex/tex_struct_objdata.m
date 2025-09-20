## Serialize atomic data element to TeX code
##
## FUNCTION SYNOPSIS:
##
## Usage 1: [r_tc] = tex_struct_objdata(p_ss, p_ds, p_sp, p_px)
##                     non-interactive mode
##
## Usage 2: [r_tc] = tex_struct_objdata(p_ss, p_ds, p_sp, [])
##          [r_tc] = tex_struct_objdata(p_ss, p_ds, p_sp)
##                     non-interactive mode
##                     use structure path without prefix
##
## Usage 3: [r_tc] = tex_struct_objdata([], p_ds, p_sp, p_px)
##                     non-interactive mode
##                     load default TeX serialization settings (see tex_settings.m)
##
## p_ss ... serialization settings data structure, <struct_tex_settings>
## p_ds ... atomic data element, data structure, <ADE/struct>
## p_sp ... structure path, <str>
## p_tc ... TeX code listing, optional, default = {}, {<str>}
## r_tc ... return: updated TeX code listing, {<str>}
##
## see also: struct_objdata.m, tex_def_csvarray.m, tex_def_dotarray.m, tex_def_scalar.m, tex_def_tabarray.m, tex_def_tabmatrix.m,
##           tex_settings.m
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
function [r_tc] = tex_struct_objdata(p_ss, p_ds, p_sp, p_tc)
  
  ## check arguments
  if (nargin < 3)
    help tex_struct_objdata;
    error('Less arguments given!');
  endif
  if (nargin < 4)
    p_tc = {};
  endif
  if isempty(p_tc)
    p_tc = {};
  endif
  
  ## init return value
  r_tc = p_tc;
  
  ## check type of data structure
  if (not(isfield(p_ds, 'obj')))
    warning('Data structure is not of type DATA! name = %s', p_sp);
    return;
  else
    if (not(p_ds.obj == 'ADE'))
      warning('Data structure is not of type DATA! name = %s', p_sp);
      return;
    endif
  endif
  
  ## set default values
  if isempty(p_ss)
    p_ss = tex_settings();
  endif
  
  ## render data structure to TeX code
  r_tc = [r_tc; '%% Atomic Data Element (ADE)'];
  r_tc = [r_tc; ['%%   ', p_ds.d]]; # add description as comment line
  #r_tc = tex_def_scalar(p_ss, [p_sp, '.obj'], 'str', p_ds.obj, r_tc);
  #r_tc = tex_def_csvarray(p_ss, [p_sp, '.ver'], 'uint', p_ds.ver, r_tc);
  r_tc = tex_def_scalar(p_ss, [p_sp, '.t'], 'str', p_ds.t, r_tc);
  #r_tc = tex_def_scalar(p_ss, [p_sp, '.d'], 'str', p_ds.d, r_tc);
##  switch (p_ds.u)
##    case {' ', '/', '#', ''}
##      ## remove unit for scalar numbers
##      r_tc = tex_def_scalar(p_ss, [p_sp, '.u'], 'unitstr', '1', r_tc);
##    otherwise
##      r_tc = tex_def_scalar(p_ss, [p_sp, '.u'], 'unitstr', p_ds.u, r_tc);
##  endswitch
  r_tc = tex_def_scalar(p_ss, [p_sp, '.u'], 'unitstr', p_ds.u, r_tc);
  #r_tc = tex_def_scalar(p_ss, [p_sp, '.vt'], 'str', p_ds.vt, r_tc);
  r_tc = sub_value(p_ss, [p_sp, '.v'], p_ds.vt, p_ds.v, r_tc);
  
endfunction

function [r_tc] = sub_value(p_ss, p_sp, p_vt, p_vv, p_tc)
  ## Append TeX code representation of value to TeX code listing
  ##
  ## p_sp ... structure path, <str>
  ## p_vt ... variable type enumerator, <str>
  ## p_vv ... variable value, <any>
  ## p_tc ... TeX code listing, {<str>}
  ## r_tc ... return: updated TeX code listing, {<str>}
  
  ## init return value
  r_tc = p_tc;
  
  ## switch value type
  switch (p_vt)
    case 'str'
      ## string
      r_tc = tex_def_scalar(p_ss, p_sp, p_vt, p_vv, r_tc);
    case 'str_arr'
      ## string array (cell array 1D)
      r_tc = tex_def_tabarray(p_ss, p_sp, p_vt, p_vv, r_tc);
    case 'str_mat'
      ## string array (cell array 2D)
      r_tc = tex_def_tabmatrix(p_ss, p_sp, p_vt, p_vv, r_tc);
    case 'bool'
      ## boolean
      r_tc = tex_def_scalar(p_ss, p_sp, p_vt, p_vv, r_tc);
    case 'bool_arr'
      ## boolean array
      r_tc = tex_def_tabarray(p_ss, p_sp, p_vt, p_vv, r_tc);
    case 'bool_mat'
      ## boolean matrix
      r_tc = tex_def_tabmatrix(p_ss, p_sp, p_vt, p_vv, r_tc);
    case 'uint'
      ## unsigned integer
      r_tc = tex_def_scalar(p_ss, p_sp, p_vt, p_vv, r_tc);
    case 'uint_arr'
      ## unsigned integer array
      r_tc = tex_def_tabarray(p_ss, p_sp, p_vt, p_vv, r_tc);
    case 'uint_mat'
      ## unsigned integer matrix
      r_tc = tex_def_tabmatrix(p_ss, p_sp, p_vt, p_vv, r_tc);
    case 'int'
      ## integer
      r_tc = tex_def_scalar(p_ss, p_sp, p_vt, p_vv, r_tc);
    case 'int_arr'
      ## integer array
      r_tc = tex_def_tabarray(p_ss, p_sp, p_vt, p_vv, r_tc);
    case 'int_mat'
      ## integer matrix
      r_tc = tex_def_tabmatrix(p_ss, p_sp, p_vt, p_vv, r_tc);
    case 'float'
      ## single precision
      r_tc = tex_def_scalar(p_ss, p_sp, p_vt, p_vv, r_tc);
    case 'float_arr'
      ## single precision array
      r_tc = tex_def_tabarray(p_ss, p_sp, p_vt, p_vv, r_tc);
    case 'float_mat'
      ## single precision matrix
      r_tc = tex_def_tabmatrix(p_ss, p_sp, p_vt, p_vv, r_tc);
    case 'dbl'
      ## double precision
      r_tc = tex_def_scalar(p_ss, p_sp, p_vt, p_vv, r_tc);
    case 'dbl_arr'
      ## double precision array
      r_tc = tex_def_tabarray(p_ss, p_sp, p_vt, p_vv, r_tc);
    case 'dbl_mat'
      ## double precision matrix
      r_tc = tex_def_tabmatrix(p_ss, p_sp, p_vt, p_vv, r_tc);
    otherwise
      warning('Unknown value type name: %s', p_vt);
  endswitch
  
endfunction
