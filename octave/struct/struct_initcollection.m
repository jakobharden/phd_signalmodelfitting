## Initialise collection of atomic structure elements
##
## FUNCTION SYNOPSIS:
##
## Usage: [r_ds] = struct_initcollection(p_n, p_d, p_v, p_algn, p_algv, p_autn, p_auta, p_licl, p_lics, p_licu)
##
## p_n    ... collection name, optional, default = 'struct_collection', <str>
## p_d    ... collection description, optional, default = 'collection of atomic structure elements', <str>
## p_v    ... collection version [major, minor], optional, default = uint16([1, 0]), [<uint16>, <uint16>]
## p_algn ... algorithm name, optional, default = 'N.N.', <str>
## p_algv ... algorithm version, optional, default = uint16([1, 0]), <str>
## p_autn ... author name, optional, default = 'Jakob Harden', <str>
## p_auta ... author affiliation, optional, default = 'Graz University of Technology, Graz, Austria', <str>
## p_licl ... license name, long, optional, default = 'Creative Commons Attribution 4.0 International', <str>
## p_lics ... license name, shortcut, optional, default = 'CC BY 4.0', <str>
## p_licu ... license URL, optional, default = 'https://creativecommons.org/licenses/by/4.0/deed.en', <str>
## r_ds   ... return: initialised data structure, <struct>
##   .obj ... collection name, <str>
##   .ver ... collection version, [<uint16>, <uint16>]
##   .des ... collection description, <str>
##   .algoname ... algorithm name, <str>
##   .algover  ... algorithm version, <str>
##   .cpr      ... copyright information, <str>
##   .liclong  ... license name, long, <str>
##   .licshort ... license name, shortcut, <str>
##   .licurl   ... license URL, <str>
##   .created  ... creation date and time (output of datestr(now()), <str>
##
## see also: struct_objdata, struct_objattr, struct_objref, struct_objmesh
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
function [r_ds] = struct_initcollection(...
  p_n = 'struct_collection', ...
  p_d = 'collection of atomic structure elements', ...
  p_v = uint16([1, 0]), ...
  p_algn = 'N.N.', ...
  p_algv = uint16([1, 0]), ...
  p_autn = 'Jakob Harden', ...
  p_auta = 'Graz University of Technology, Graz, Austria', ...
  p_licl = 'Creative Commons Attribution 4.0 International', ...
  p_lics = 'CC BY 4.0', ...
  p_licu = 'https://creativecommons.org/licenses/by/4.0/deed.en')
  
  ## create collection data structure
  r_ds.obj = p_n;
  r_ds.ver = uint16(p_v);
  r_ds.des = p_d;
  r_ds.algoname = p_algn;
  r_ds.algover = uint16(p_algv);
  if (isempty(p_auta))
    cpr = sprintf('Copyright (%s) %s', datestr(now(), 10), p_autn);
  else
    cpr = sprintf('Copyright (%s) %s (%s)', datestr(now(), 10), p_autn, p_auta);
  endif
  r_ds.cpr = cpr;
  r_ds.liclong = p_licl;
  r_ds.licshort = p_lics;
  r_ds.licurl = p_licu;
  r_ds.created = datestr(now());
  
endfunction
