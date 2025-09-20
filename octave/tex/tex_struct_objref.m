## Serialize atomic reference element to TeX code
##
## FUNCTION SYNOPSIS:
##
## Usage 1: [r_tc] = tex_struct_objref(p_ss, p_ds, p_sp, p_tc)
##                     non-interactive mode
##                     update given TeX code listing
##
## Usage 2: [r_tc] = tex_struct_objref(p_ss, p_ds, p_sp, [])
##          [r_tc] = tex_struct_objref(p_ss, p_ds, p_sp)
##                     non-interactive mode
##                     start new TeX code listing
##
## Usage 3: [r_tc] = tex_struct_objref([], p_ds, p_sp, p_tc)
##                     non-interactive mode
##                     load default TeX serialization settings (see tex_settings.m)                    
##
## p_ss ... serialization settings data structure, <struct_tex_settings>
## p_ds ... atomic reference element, data structure, <ARE/struct>
## p_sp ... structure path, <str>
## p_tc ... TeX code listing, optional, default = {}, {<str>}
## r_tc ... return: updated TeX code listing, {<str>}
##
## see also: struct_objref.m, tex_def_scalar.m, tex_def_csvarray.m, tex_def_dotarray.m, tex_settings.m
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
function [r_tc] = tex_struct_objref(p_ss, p_ds, p_sp, p_tc)
  
  ## check arguments
  if (nargin < 3)
    help tex_struct_objref;
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
    warning('Data structure is not of type REFERENCE! name = %s', p_sp);
    return;
  else
    if (not(p_ds.obj == 'ARE'))
      warning('Data structure is not of type REFERENCE! name = %s', p_sp);
      return;
    endif
  endif
  
  ## set default values
  if isempty(p_ss)
    p_ss = tex_settings();
  endif
  
  ## render data structure to TeX code
  r_tc = [r_tc; '%% Atomic Reference Element (ARE)'];
  r_tc = [r_tc; ['%%   ', p_ds.d]]; # add description as comment line
  #r_tc = tex_def_scalar(p_ss, [p_sp, '.obj'], 'str', p_ds.obj, r_tc);
  #r_tc = tex_def_csvarray(p_ss, [p_sp, '.ver'], 'uint_arr', p_ds.ver, r_tc);
  r_tc = tex_def_scalar(p_ss, [p_sp, '.t'], 'str', p_ds.t, r_tc);
  #r_tc = tex_def_scalar(p_ss, [p_sp, '.d'], 'str', p_ds.d, r_tc);
  r_tc = tex_def_csvarray(p_ss, [p_sp, '.i'], 'uint_arr', p_ds.i, r_tc);
  r_tc = tex_def_dotarray(p_ss, [p_sp, '.r'], 'str_arr', p_ds.r, r_tc);
  
endfunction
