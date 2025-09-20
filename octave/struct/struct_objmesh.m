## Create mesh object (atomic mesh data element, ADEmesh)
##
## FUNCTION SYNOPSIS:
##
## Usage: [r_ds] = struct_objattrib(p_t, p_x, p_y, p_z, p_u, p_d)
##
## p_t  ... mesh tag, <str>
## p_z  ... z coordinate/value matrix, [[<dbl>]]
## p_x  ... x coordinate matrix (e.g. output of meshgrid), optional, default = [], [[<dbl>]]
## p_y  ... y coordinate matrix (e.g. output of meshgrid), optional, default = [], [[<dbl>]]
## p_u  ... unit, SI unit identifier, optional, default = "1", <str>
## p_d  ... description, optional, default = "", <str>
## r_ds ... return: data structure, <AAE/struct>
##   .obj ... object type, "ADEmesh"
##   .ver ... version numbers [main_ver, sub_ver], [<uint>]
##   .t   ... mesh tag, <str>
##   .xx  ... x coordinate matrix, optional, [[<dbl>]]
##   .yy  ... y coordinate matrix, optional, [[<dbl>]]
##   .zz  ... z coordinate matrix, optional, [[<dbl>]]
##   .u   ... unit, <str>
##   .d   ... description, optional, <str>
##
## see also: struct_objdata, struct_objref, struct_objattrib
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
function [r_ds] = struct_objmesh(p_t, p_z, p_x = [], p_y = [], p_u = '1', p_d = '')
  
  ## check arguments
  if (nargin < 2)
    help struct_objmesh;
    error('Less arguments given!');
  endif
  if isempty(p_t)
    help struct_objmesh;
    error('Attribute tag is empty!');
  endif
  if isempty(p_z)
    help struct_objmesh;
    error('Z coordinate/value matrix is empty!');
  endif
  if isempty(p_u)
    p_u = '1';
  endif
  
  ## number of rows, columns
  [Nr, Nc] = size(p_z);
  
  ## check x coordinate matrix
  if (isempty(p_x))
    x = linspace(0, 1, Nc);
    xx = repmat(x, Nr, 1);
  else
    xx = p_x;
  endif
  
  ## check y coordinate matrix
  if (isempty(p_y))
    y = transpose(linspace(0, 1, Nr));
    yy = repmat(y, 1, Nc);
  else
    yy = p_y;
  endif
  
  ## check dimensions
  if (sum(size(xx) == size(p_z)) != 2)
    help struct_objmesh;
    error('Number of rows and columns must match! size(p_x) != size(p_z)');
  endif
  if (sum(size(yy) == size(p_z)) != 2)
    help struct_objmesh;
    error('Number of rows and columns must match! size(p_y) != size(p_z)');
  endif
  
  ## create structure
  r_ds.obj = 'ADEmesh';
  r_ds.ver = uint16([1, 0]);
  r_ds.t = p_t;
  r_ds.xx = xx;
  r_ds.yy = yy;
  r_ds.zz = p_z;
  r_ds.u = p_u;
  r_ds.d = p_d;
  
endfunction
