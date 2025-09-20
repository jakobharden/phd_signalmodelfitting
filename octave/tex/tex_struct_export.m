## Export data structure(s) to TeX code file
##
## FUNCTION SYNOPSIS:
##
## Usage: [r_ec] = tex_struct_export(p_ds, p_dn, p_of)
##
## p_ds ... data structure, <struct>
## p_dn ... data structure name (parent object used in structure path), <str>
## p_of ... output file path without extension, full qualified, <str>
## r_ec ... return: error code, <bool>
##            true:  success
##            false: failure
##
## see also: tex_settings.m, tex_struct.m
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
## Revision history:
##   1) 2025-01-20; Jakob Harden; minor corrections in function synopsis
##
function [r_ec] = tex_struct_export(p_ds, p_dn, p_of)
  
  ## check arguments
  if (nargin < 3)
    help tex_struct_export;
    error('Less arguments given!');
  endif
  
  ## load TeX serialization settings
  ss = tex_settings();
  
  ## serialize data structure to TeX code
  r_tc = tex_struct(ss, p_ds, p_dn);
  if isempty(r_tc)
    r_ec = false;
    return;
  endif
  
  ## output file name
  ofn = [p_of, '.tex'];
  
  ## open TeX file 
  fid = fopen(ofn, 'w');
  printf('tex_struct_export: opened file, %s\n', ofn);
  if (fid < 0)
    r_ec = false;
    warning('tex_struct_export: an error occured while opening file "%s" for writing!', ofn);
    return;
  else
    r_ec = true;
  endif
  
  ## write TeX code to file
  for i = 1 : numel(r_tc)
    fprintf(fid, '%s\n', r_tc{i});
  endfor
  
  ## close TeX file
  fclose(fid);
  printf('tex_struct_export: closed file, %s\n', ofn);
  
endfunction
