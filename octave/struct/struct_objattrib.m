## Create attribute object (atomic attribute element, AAE)
##
## FUNCTION SYNOPSIS:
##
## Usage 1: [r_ds] = struct_objattrib(p_t, p_v, p_d)
##                     non-interactive
##
## Usage 2: [r_ds] = struct_objattrib(p_t, p_v, [])
##          [r_ds] = struct_objattrib(p_t, p_v)
##                     non-interactive
##                     set description field to empty string, raise warning
##
## Usage 3: [r_ds] = struct_objattrib(p_t, [], p_d)
##                     non-interactive
##                     set value field to empty string
##
## p_t  ... attribute tag, <str>
## p_v  ... attribute value, optional, default = "", <str> or {<str>}
## p_d  ... description, optional, default = "", <str>
## r_ds ... return: data structure, <AAE/struct>
##   .obj ... object type, "AAE"
##   .ver ... version numbers [main_ver, sub_ver], [<uint>]
##   .t   ... attribute tag, <str>
##   .v   ... attribute value, optional, <str> or {<str>}
##   .d   ... description, optional, <str>
##
## see also: struct_objdata, struct_objref
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
function [r_ds] = struct_objattrib(p_t, p_v, p_d)
  
  ## check arguments
  if (nargin < 1)
    help struct_objattrib;
    error('Less arguments given!');
  endif
  if (nargin < 2)
    p_v = '';
  endif
  if (nargin < 3)
    p_d = '';
    warning('Description of atomic attribute element is empty!');
  endif
  if isempty(p_t)
    help struct_objattrib;
    error('Attribute tag is empty!');
  endif
  if isempty(p_v)
    p_v = '';
  endif
  
  ## create structure
  r_ds.obj = 'AAE';
  r_ds.ver = uint16([1, 0]);
  r_ds.t = p_t;
  r_ds.v = p_v;
  r_ds.d = p_d;
  
endfunction
