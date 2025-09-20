## Serialize atomic mesh data element to TeX code
##
## FUNCTION SYNOPSIS:
##
## Usage 1: [r_tc] = tex_struct_objmesh(p_ss, p_ds, p_sp, p_tc)
##                     non-interactive mode
##                     update given TeX code listing
##
## Usage 2: [r_tc] = tex_struct_objmesh(p_ss, p_ds, p_sp)
##                     non-interactive mode
##                     start new TeX code listing
##
## Usage 3: [r_tc] = tex_struct_objmesh([], p_ds, p_sp, p_tc)
##                     non-interactive mode
##                     load default TeX serialization settings (see tex_settings.m)
##
## p_ss ... serialization settings data structure, <struct_tex_settings>
## p_ds ... atomic data element of type "mesh", data structure, <ADEmesh/struct>
## p_sp ... structure path, <str>
## p_tc ... TeX code listing, optional, default = {}, {<str>}
## r_tc ... return: updated TeX code listing, {<str>}
##
## see also: struct_objmesh.m, tex_def_tabmesh.m, tex_def_scalar.m, tex_settings.m
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
function [r_tc] = tex_struct_objmesh(p_ss, p_ds, p_sp, p_tc = {})
  
  ## check arguments
  if (nargin < 3)
    help tex_struct_objmesh;
    error('Less arguments given!');
  endif
  
  ## init return value
  r_tc = p_tc;
  
  ## check type of data structure
  if (not(isfield(p_ds, 'obj')))
    warning('Data structure is not of type mesh data! name = %s', p_sp);
    return;
  else
    if (not(p_ds.obj == 'ADEmesh'))
      warning('Data structure is not of type mesh data! name = %s', p_sp);
      return;
    endif
  endif
  
  ## set default values
  if isempty(p_ss)
    p_ss = tex_settings();
  endif
  
  ## render data structure to TeX code
  r_tc = [r_tc; '%% Atomic Mesh Data Element (ADEmesh)']; # head line, comment line
  r_tc = [r_tc; ['%%   ', p_ds.d]]; # add description as comment line
  #r_tc = tex_def_scalar(p_ss, [p_sp, '.obj'], 'str', p_ds.obj, r_tc);
  #r_tc = tex_def_csvarray(p_ss, [p_sp, '.ver'], 'uint_arr', p_ds.ver, r_tc);
  r_tc = tex_def_scalar(p_ss, [p_sp, '.t'], 'str', p_ds.t, r_tc);
  r_tc = tex_def_scalar(p_ss, [p_sp, '.u'], 'unitstr', p_ds.u, r_tc);
  r_tc = tex_def_tabmesh(p_ss, [p_sp, '.v'], p_ds.xx, p_ds.yy, p_ds.zz, r_tc);
  
endfunction
