## Create data object (atomic data element, ADE)
##
## FUNCTION SYNOPSIS:
##
## Usage 1: [r_ds] = struct_objdata(p_t, p_vt, p_v, p_u, p_d)
##                     non-interactive
##
## Usage 2: [r_ds] = struct_objdata(p_t, p_vt, p_v, p_u, [])
##          [r_ds] = struct_objdata(p_t, p_vt, p_v, p_u)
##                     non-interactive
##                     set description field to empty string, raise warning
##
## Usage 3: [r_ds] = struct_objdata(p_t, p_vt, p_v, [], p_d)
##                     non-interactive
##                     set unit to "1"
##
## Usage 4: [r_ds] = struct_objdata(p_t, p_vt, [], p_u, p_d)
##                     non-interactive
##                     set value field to empty value "[]"
##
## p_t  ... tag, <str>
## p_vt ... value type, <str>
## p_v  ... value of given type, optional, default = [], <any_GNU_ovtave_value>
## p_u  ... unit, SI unit identifier, optional, default = "1", <str>
## p_d  ... description, optional, default = "", <str>
## r_ds ... return: data structure, <ADE/struct>
##   .obj ... object type, "ADE"
##   .ver ... version numbers [main_ver, sub_ver], [<uint>]
##   .t   ... tag, <str>
##   .vt  ... value type, <str>
##   .v   ... value, <any_GNU_ovtave_value>
##   .u   ... unit, <str>
##   .d   ... description, <str>
##
## Value types:
##   type 1:  'string', 'str', 's': character array, character = 8 bit
##   type 2:  'string_arr', 'str_arr', 'str1', 's1': 1D cell array (vector) of strings
##   type 3:  'string_mat', 'str_mat', 'str2', 's2': 2D cell array (matrix) of strings
##   type 4:  'boolean', 'bool', 'b': 8 bit, unsigned
##   type 5:  'boolean_arr', 'bool_arr', 'bool1', 'b1': 1D array (vector) of type boolean
##   type 6:  'boolean_mat', 'bool_mat', 'bool2', 'b2': 2D array (matrix) of type boolean
##   type 7:  'uint', 'u': 32 bit, unsigned integer
##   type 8:  'uint_arr', 'uint1', 'u1': 1D array (vector) of type uint
##   type 9:  'uint_mat', 'uint2', 'u2': 2D array (matrix) of type uint
##   type 10: 'int', 'i': 32 bit, signed integer
##   type 11: 'int_arr', 'int1', 'i1': 1D array (vector) of type int
##   type 12: 'int_mat', 'int2', 'i2': 2D array (matrix) of type int
##   type 13: 'single', 'sng', 'float', 'f': 32 bit, floating point value
##   type 14: 'single_arr', 'sng_arr', 'sng1', 'float_arr', 'float1', 'f1': 1D array (vector) of type single
##   type 15: 'single_mat', 'sng_mat', 'sng2', 'float_mat', 'float2', 'f2': 2D array (matrix) of type single
##   type 16: 'double', 'dbl', 'd': 64 bit, floating point value
##   type 17: 'double_arr', 'double1', 'dbl_arr', 'dbl1', 'd1': 1D array (vector) of type double
##   type 18: 'double_mat', 'double2', 'dbl_mat', 'dbl2', 'd2': 2D array (matrix) of type double
##
## see also: struct_objref, struct_objattr
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
function [r_ds] = struct_objdata(p_t, p_vt, p_v = [], p_u = '1', p_d = '')
  
  if (nargin < 2)
    help struct_objdata;
    error('Less arguments given!');
  endif
  if isempty(p_t)
    help struct_objdata;
    error('Data tag/name is empty!');
  endif
  if isempty(p_vt)
    help struct_objdata;
    error('Data value type is empty!');
  endif
  if isempty(p_u)
    p_u = '1';
    warning('Unit of atomic data element is empty!');
  endif
  if isempty(p_d)
    p_d = '';
    warning('Description of atomic data element is empty!');
  endif
  
  ## check data type
  [r_vt, r_dv] = hlp_value_type(p_vt);
  
  ## set default value
  if isempty(p_v)
    p_v = r_dv;
  endif
  
  ## create structure
  r_ds.obj = 'ADE';
  r_ds.ver = uint16([1, 0]);
  r_ds.t = p_t;
  r_ds.vt = r_vt;
  r_ds.v = p_v;
  r_ds.u = p_u;
  r_ds.d = p_d;
  
endfunction

############################################################################################################################################
## Helper function: check data type
## p_vt ... value type id or string, <int> or <str>
## r_md ... return: meta data, <struct>
## r_dv ... return: default value of given value type, <any_GNU_octve_value>
function [r_vt, r_dv] = hlp_value_type(p_vt)
  
  ## switch value type
  switch (p_vt)
    case {'string', 'str', 's'}
      ## string
      r_vt = 'str';
      r_dv = '';
    case {'string_arr', 'str_arr', 'str1', 's1'}
      ## string array (cell array 1D)
      r_vt = 'str_arr';
      r_dv = {};
    case {'string_mat', 'str_mat', 'str2', 's2'}
      ## string array (cell array 2D)
      r_vt = 'str_mat';
      r_dv = {};
    case {'boolean', 'bool', 'b'}
      ## boolean
      r_vt = 'bool';
      r_dv = [];
    case {'boolean_arr', 'bool_arr', 'bool1', 'b1'}
      ## boolean array
      r_vt = 'bool_arr';
      r_dv = [];
    case {'boolean_mat', 'bool_mat', 'bool2', 'b2'}
      ## boolean matrix
      r_vt = 'bool_mat';
      r_dv = [];
    case {'uint', 'u'}
      ## unsigned integer
      r_vt = 'uint';
      r_dv = [];
    case {'uint_arr', 'uint1', 'u1'}
      ## unsigned integer array
      r_vt = 'uint_arr';
      r_dv = [];
    case {'uint_mat', 'uint2', 'u2'}
      ## unsigned integer matrix
      r_vt = 'uint_mat';
      r_dv = [];
    case {'int', 'i'}
      ## integer
      r_vt = 'int';
      r_dv = [];
    case {'int_arr', 'int1', 'i1'}
      ## integer array
      r_vt = 'int_arr';
      r_dv = [];
    case {'int_mat', 'int2', 'i2'}
      ## integer matrix
      r_vt = 'int_mat';
      r_dv = [];
    case {'single', 'sng', 'float', 'f'}
      ## single precision
      r_vt = 'float';
      r_dv = 0.0;
    case {'single_arr', 'sng_arr', 'sng1', 'float_arr', 'float1', 'f1'}
      ## single precision array
      r_vt = 'float_arr';
      r_dv = [];
    case {'single_mat', 'sng_mat', 'sng2', 'float_mat', 'float2', 'f2'}
      ## single precision matrix
      r_vt = 'float_mat';
      r_dv = [];
    case {'double', 'dbl', 'd'}
      ## double precision
      r_vt = 'dbl';
      r_dv = [];
    case {'double_arr', 'double1', 'dbl_arr', 'dbl1', 'd1'}
      ## double precision array
      r_vt = 'dbl_arr';
      r_dv = [];
    case {'double_mat', 'double2', 'dbl_mat', 'dbl2', 'd2'}
      ## double precision matrix
      r_vt = 'dbl_mat';
      r_dv = [];
    otherwise
      help struct_objdata;
      error('Unknown value type name: %s', p_vt);
  endswitch
  
endfunction
