## Serialize data structure(s) to TeX code
##
## FUNCTION SYNOPSIS:
##
## Usage 1: [r_tc] = tex_struct(p_ss, p_ds, p_dn)
##                     non-interactive
##
## Usage 2: [r_tc] = tex_struct(p_ss, p_ds, [])
##          [r_tc] = tex_struct(p_ss, p_ds)
##                     non-interactive
##                     use default data structure name (p_dn = "ds")
##
## Usage 3: [r_tc] = tex_struct([], p_ds, p_dn)
##                     non-interactive
##                     load default TeX serialization settings (see tex_settings.m)
##
## p_ss ... settings data structure, optional, <struct_tex_settings>
## p_ds ... data structure or data structure array, <struct> or [<struct>]
## p_dn ... data structure name, optional, default = "ds", <str>
## r_tc ... return: TeX code listing, {<str>}
##
## Note:
##   The following structure fields are considered:
##   - p_ds.obj ... object type descriptor, <str>
##   - p_ds.ver ... object version [major_version, minor_version], [<uint16>, <uint16>]
##   - p_ds.des ... object description, <str>
##   - p_ds.algoname ... algorithm name, <str>
##   - p_ds.algover  ... algorithm version [major_version, minor_version], [<uint>]
##   - p_ds.cpr      ... copyright information, <str>
##   - p_ds.liclong  ... license name, long, <str>
##   - p_ds.licshort ... license name, shortcut, <str>
##   - p_ds.licurl   ... license URL, <str>
##   - p_ds.<f> ... if <f> is one of the following predefined atomic structure elements
##       - ARE ... atomic reference element, <ARE/struct>
##       - AAE ... atomic attribute element, <AAE/struct>
##       - ADE ... atomic data element, <ADE/struct>
##       - ADEmesh ... atomic mesh data element, <ADEmesh/struct>
##
##  All other fields are ignored.
##
## see also: tex_struct_objref.m, tex_struct_objattrib, tex_struct_objdata.m, tex_struct_objmesh, tex_settings.m
##
## Copyright 2023,2025 Jakob Harden (jakob.harden@tugraz.at, Graz University of Technology, Graz, Austria)
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
function [r_tc] = tex_struct(p_ss, p_ds, p_dn)
  
  ## check arguments
  if (nargin < 2)
    help tex_struct;
    error('Less arguments given!');
  endif
  if (nargin < 3)
    p_dn = [];
  endif
  if isempty(p_ds)
    r_tc = {};
    return;
  endif
  
  ## set default values
  if isempty(p_ss)
    p_ss = tex_settings();
  endif
  if isempty(p_dn)
    p_dn = 'ds';
  endif
  
  ## add variable name prefix
  if not(isempty(p_ss.ser.var_pfx))
    p_dn = [p_ss.ser.var_pfx, '.', p_dn];
  endif
  
  ## start TeX code listing
  r_tc = {...
    '%% This file was written by Dataset Exporter'; ...
    '%% Dataset Exporter is a script collection conceived, implemented and tested by Jakob Harden (jakob.harden@tugraz.at, Graz University of Technology)';...
    '%% It is licenced under the MIT license and has been published under the following URL: https://doi.org/10.3217/9adsn-8dv64';...
    '%% To make use of the exported data in your LaTeX document in a convenient way, also include the following script file after the preamble: \input{oct2texdefs}';...
    '%% The respective TeX script file (oct2texdefs.tex) is stored in the following directory: ./tex/latex/';...
    '%% To import this file into your LaTeX document, use the following statement: \input{<filename>}'; ...
    '%% '; ...
    '%% Information to the exported data:'};
    
  ## check whether data structure is an atomic element or not
  if isfield(p_ds, 'obj')
    switch (p_ds.obj)
      case {'ARE', 'AAE', 'ADE', 'ADEmesh'}
        ## serialize atomic element(s)
        if (numel(p_ds) == 1)
          ## scalar structure, 1 element
          r_tc = hlp_atomic_single(p_ss, p_ds, p_dn, r_tc);
        else
          ## structure array, n elements
          r_tc = hlp_atomic_array(p_ss, p_ds, p_dn, r_tc);
        endif
        ## done
        return;
    endswitch
  endif
  
  ## create TeX object list of single data structure or array of data structures
  if (numel(p_ds) == 1)
    ## scalar structure, 1 element
    r_tc = hlp_struct_single(p_ss, p_ds, p_dn, r_tc);
  else
    ## structure array, n elements
    r_tc = hlp_struct_array(p_ss, p_ds, p_dn, r_tc);
  endif
  
endfunction


function [r_tc] = hlp_struct_array(p_ss, p_ds, p_dn, p_tc)
  ## Update TeX code listing with data structure array
  ##
  ## p_ss ... settings data structure, <struct_tex_settings>
  ## p_ds ... data structures, [<struct>]
  ## p_dn ... substructure name/path, <str>
  ## p_tc ... TeX code listing, {<str>}
  ## r_tc ... return: updated TeX code listing, {<str>}
  
  ## init return value
  r_tc = [...
    p_tc;...
    '%%'; ...
    '%% structure array'];
  
  ## collect data from structures
  for i = 1 : numel(p_ds)
    ## append index to structure path
    dn_i = sprintf('%s_%d', p_dn, i);
    ## append content to TeX code listing
    r_tc = hlp_struct_single(p_ss, p_ds(i), dn_i, r_tc);
  endfor
  
endfunction


function [r_tc] = hlp_struct_single(p_ss, p_ds, p_dn, p_tc)
  ## Update TeX code listing with single data structure
  ##
  ## p_ss ... settings data structure, <struct_tex_settings>
  ## p_ds ... data structure, <struct>
  ## p_dn ... substructure name/path, <str>
  ## p_tc ... TeX code listing, {<str>}
  ## r_tc ... return: updated TeX code listing, {<str>}
  
  ## enlist field names
  fldlst = fieldnames(p_ds);
  
  ## init return value
  r_tc = [...
    p_tc;...
    '%%';...
    '%% scalar structure'];
  
  ## collect data from structure fields
  for i = 1 : numel(fldlst)
    ## current field name
    fn_i = fldlst{i};
    ## current structure path, append current field name to given structure path
    sp_i = sprintf('%s.%s', p_dn, fn_i);
    ## current substructure or field
    ds_i = getfield(p_ds, fn_i);
    ## check for empty fields or structures
    if isempty(ds_i)
      continue;
    endif
    ## distinction between structure fields and substructures
    if isstruct(ds_i)
      ## handle structure
      ## check whether obj field exists or not
      if isfield(ds_i(1), 'obj')
        ## distinction between atomic elements and other substructures
        switch (ds_i(1).obj)
          case {'AAE', 'ARE', 'ADE', 'ADEmesh'}
            if (numel(ds_i) > 1)
              ## handle atomic element array
              r_tc = hlp_atomic_array(p_ss, ds_i, sp_i, r_tc);
            else
              ## handle single atomic element
              r_tc = hlp_atomic_single(p_ss, ds_i, sp_i, r_tc);
            endif
          otherwise
            if (numel(ds_i) > 1)
              ## handle substructure array
              r_tc = hlp_struct_array(p_ss, ds_i, sp_i, r_tc);
            else
              ## handle scalar substructure
              r_tc = hlp_struct_single(p_ss, ds_i, sp_i, r_tc);
            endif
        endswitch
      endif
    else
      ## handle recognized structure fields
      switch (fn_i)
        case 'obj'
          if not(isempty(ds_i))
            r_tc = tex_def_scalar(p_ss, sp_i, 'str', ds_i, r_tc);
          endif
        case 'ver'
          if not(isempty(ds_i))
            r_tc = tex_def_csvarray(p_ss, sp_i, 'uint_arr', ds_i, r_tc);
          endif
        case 'des'
          if not(isempty(ds_i))
            r_tc = tex_def_scalar(p_ss, sp_i, 'str', ds_i, r_tc);
          endif
        case 'algoname'
          if not(isempty(ds_i))
            r_tc = tex_def_scalar(p_ss, sp_i, 'str', ds_i, r_tc);
          endif
        case 'algover'
          if not(isempty(ds_i))
            r_tc = tex_def_csvarray(p_ss, sp_i, 'uint_arr', ds_i, r_tc);
          endif
        case 'cpr'
          if not(isempty(ds_i))
            r_tc = tex_def_scalar(p_ss, sp_i, 'str', ds_i, r_tc);
          endif
        case 'liclong'
          if not(isempty(ds_i))
            r_tc = tex_def_scalar(p_ss, sp_i, 'str', ds_i, r_tc);
          endif
        case 'licshort'
          if not(isempty(ds_i))
            r_tc = tex_def_scalar(p_ss, sp_i, 'str', ds_i, r_tc);
          endif
        case 'licurl'
          if not(isempty(ds_i))
            r_tc = tex_def_scalar(p_ss, sp_i, 'str', ds_i, r_tc);
          endif
        case 'created'
          if not(isempty(ds_i))
            r_tc = tex_def_scalar(p_ss, sp_i, 'str', ds_i, r_tc);
          endif
      endswitch
    endif
  endfor
  
endfunction


function [r_tc] = hlp_atomic_array(p_ss, p_ds, p_dn, p_tc)
  ## Update TeX code listing with array of atomic elements
  ##
  ## p_ss ... settings data structure, <struct_tex_settings>
  ## p_ds ... array of atomic structure elements, [<ARE/struct>] or [<AAE/struct>] or [<ADE/struct>]
  ## p_dn ... substructure name/path, <str>
  ## p_tc ... TeX code listing, {<str>}
  ## r_tc ... return: updated TeX code listing, {<str>}
  
  ## init return value
  r_tc = p_tc;
  
  ## collect data from structures
  for i = 1 : numel(p_ds)
    ## current element
    ds_i = p_ds(i);
    ## current structure path, append array index to structure path
    sp_i = sprintf('%s_%d', p_dn, i);
    ## check cardinality of element
    if (numel(ds_i) > 1)
      ## multiple elements
      r_tc = hlp_atomic_array(p_ss, ds_i, sp_i, r_tc);
    else
      ## single element
      r_tc = hlp_atomic_single(p_ss, ds_i, sp_i, r_tc);
    endif
  endfor
  
endfunction

function [r_tc] = hlp_atomic_single(p_ss, p_ds, p_dn, p_tc)
  ## Check type of atomic structure and update TeX code listing
  ##
  ## p_ss ... settings data structure, <struct_tex_settings>
  ## p_ds ... atomic structure element, <ARE/struct> or <AAE/struct> or <ADE/struct>
  ## p_dn ... substructure name/path, <str>
  ## p_tc ... TeX code listing, {<str>}
  ## r_tc ... return: updated TeX code listing, {<str>}
  
  ## init return value
  r_tc = p_tc;
  
  ## switch object type
  switch (p_ds.obj)
    case 'AAE'
      r_tc = tex_struct_objattrib(p_ss, p_ds, p_dn, r_tc);
    case 'ARE'
      r_tc = tex_struct_objref(p_ss, p_ds, p_dn, r_tc);
    case 'ADE'
      r_tc = tex_struct_objdata(p_ss, p_ds, p_dn, r_tc);
    case 'ADEmesh'
      r_tc = tex_struct_objmesh(p_ss, p_ds, p_dn, r_tc);
  endswitch
  
endfunction
