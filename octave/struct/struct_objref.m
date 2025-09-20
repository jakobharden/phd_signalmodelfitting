## Create reference object (atomic reference element, ARE)
##
## FUNCTION SYNOPSIS:
##
## Usage 1: [r_ds] = struct_objref(p_t, p_i, p_r, p_d)
##                     non-interactive
##
## Usage 2: [r_ds] = struct_objref(p_t, p_i, p_r, [])
##          [r_ds] = struct_objref(p_t, p_i, p_r)
##                     non-interactive
##                     set description field to empty string, raise warning
##
## Usage 3: [r_ds] = struct_objref(p_t, p_i, [], p_d)
##                     non-interactive
##                     set reference target field to empty string, raise warning
##
## Usage 4: [r_ds] = struct_objref(p_t, [], p_r, p_d)
##                     non-interactive
##                     set reference index field to empty string, raise warning
##
## Note 1: p_i is NOT the index of a structure array. The referenced element must
##         contain an id field who's value can be compared to the id of the reference.
##         The name of the id field and the comparison function is up to the program code.
##         To access the element, it is necessary to iterate over the structure
##         array and to compare the id.
##         Example: p_i = 5, p_r = root.lvl1.authors points to a structure element in the
##                  structure array "authors" which is defined by: root.lvl1.authors(i).id = 5
##                  Here, i is the index of an item in the structure array.
##
## Note 2: p_r is a cell-array of strings. Each array items points to another level of
##        the structure hierarchy. Structure levels must be arranged in descending order
##        and the root of the hierarchy must not be referenced.
##        This definition allows to access any structure element by subsequent calls
##        to the "getfield(...)" command.
##        Example: reference to data structure element "test" in "root.lvl1.lvl2.test"
##                 results in: p_r = {"lvl1", "lvl2", "test"}
##
## p_t  ... tag, <str>
## p_i  ... reference index, IDs of related data object(s), optional, default = [], <uint> or [<uint>]
## p_r  ... reference target, structure path to related data object, optional, default = "", {<str>}
## p_d  ... description, optional, default = "", <str>
## r_ds ... return: data structure, <ARE/struct>
##   .obj ... object type, "ARE"
##   .ver ... version numbers [main_ver, sub_ver], [<uint>]
##   .t   ... tag, <str>
##   .i   ... reference index, IDs of related data object(s), <uint>
##   .r   ... reference target, structure path to related data object, {<str>}
##   .d   ... description, <str>
##
## see also: struct_objdata, struct_objattr
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
function [r_ds] = struct_objref(p_t, p_i, p_r, p_d)
  
  ## check arguments
  if (nargin < 1)
    help struct_objref;
    error('Less arguments given!');
  endif
  if isempty(p_t)
    help struct_objref;
    error('Reference tag is empty!');
  endif
  if (nargin < 2)
    p_i = [];
    warning('Reference index (ID of related data object) of atomic reference element is empty!');
  endif
  if (nargin < 3)
    p_r = '';
    warning('Reference target (structure path to related data object) of atomic reference element is empty!');
  endif
  if (nargin < 4)
    p_d = '';
    warning('Description of atomic reference element is empty!');
  endif
  
  ## check reference target value type
  if not(iscell(p_r))
    p_r = {p_r};
  endif
  
  ## check reference target index type
  if not(isempty(p_i))
    if not(isnumeric(p_i))
      help struct_objref;
      error("ID's to related data objects must be numeric values! (<uint> or [<uint>])");
    endif
  endif
  
  # create structure
  r_ds.obj = 'ARE';
  r_ds.ver = uint16([1, 0]);
  r_ds.t = p_t;
  r_ds.i = p_i;
  r_ds.r = p_r;
  r_ds.d = p_d;
  
endfunction
