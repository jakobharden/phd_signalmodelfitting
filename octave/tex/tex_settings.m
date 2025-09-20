## Create data structure containing the TeX code serialization settings
##
## FUNCTION SYNOPSIS:
##
## Usage: [r_ds] = tex_settings()
##
## r_ds  ... return: TeX output settings, <struct_tex_settings>
##
## see also: tex_def_csvarray.m, tex_def_dotarray.m, tex_def_scalar.m, tex_def_tabarray.m, tex_def_tabmatrix.m
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
function [r_ds] = tex_settings()
  
  ## Init data structure
  r_ds.obj = 'struct_tex_settings';
  r_ds.ver = uint16([1, 0]);
  
  #########################
  ## Serialization settings
  #########################
  
  ## Use fixed number of digits to serialize floating point values
  ## If this setting is false, the settings "r_ds.ser.single_ndig" and "r_ds.ser.double_ndig" are ignored.
  ## see also: json_val_scalar.m
  r_ds.ser.fixed_ndig = true;
  
  ## Number of digits to be serialized, single precision floating point numbers
  ## number between 1 and 7
  ## see also: tex_def_scalar.m
  r_ds.ser.single_ndig = 7;
  
  ## Number of digits to be serialized, double precision floating point numbers
  ## number between 1 and 16
  ## see also: tex_def_scalar.m
  r_ds.ser.double_ndig = 16;
  
  ## Maximum number of matrix columns to be serialized
  ## see also: tex_def_tabmatrix.m
  r_ds.ser.matrix_maxcols = 20;
  
  ## Maximum number of array elements to be serialized
  ## see also: tex_def_tabarray.m, tex_def_tabmatrix.m
  r_ds.ser.array_maxelems = 5000;
  
  ## TeX command definition, prefix
  r_ds.ser.cmd_pfx = '\\expandafter\\def\\csname';
  
  ## TeX command definition, suffix
  r_ds.ser.cmd_sfx = '\\endcsname';
  
  ## Begin filecontents environment
  r_ds.ser.env_fc_begin = '\begin{filecontents}[overwrite]';
  
  ## End filecontents environment
  r_ds.ser.env_fc_end = '\end{filecontents}';
  
  ## Variable name prefix
  ## The prefix is used to avoid variable name conflicts in the LaTeX document.
  ## Can be an empty string.
  r_ds.ser.var_pfx = 'oct2tex';
  
endfunction
