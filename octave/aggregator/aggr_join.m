## Join set of atomic data structures by identifier group membership
##
## Usage: [r_ds] = aggr_join(p_as, p_gi, p_li)
##
## p_as ... atomic data structure array, [<struct_aggr_atom>]
## p_gi ... group identifier, <str>
## p_li ... list of atom identifiers to join, {<str>}
## p_gd ... group description, <str>
## r_ds ... return: group data structure, univariate distribution, <struct_aggr_group>
##
#######################################################################################################################
## LICENSE
##
##    Copyright (C) 2025 Jakob Harden (jakob.harden@tugraz.at, Graz University of Technology, Graz, Austria)
##    This file is part of the PhD thesis of Jakob Harden.
##
##    This program is free software: you can redistribute it and/or modify
##    it under the terms of the GNU Affero General Public License as
##    published by the Free Software Foundation, either version 3 of the
##    License, or (at your option) any later version.
##
##    This program is distributed in the hope that it will be useful,
##    but WITHOUT ANY WARRANTY; without even the implied warranty of
##    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##    GNU Affero General Public License for more details.
##
##    You should have received a copy of the GNU Affero General Public License
##    along with this program.  If not, see <https://www.gnu.org/licenses/>.
##
#######################################################################################################################
##
function [r_ds] = aggr_join(p_as, p_gi, p_li, p_gd = '')
  
  ## check arguments
  if (nargin < 3)
    help aggr_join;
    error('Less arguments given!');
  endif
  if isempty(p_li)
    ## join all atomic data structures in array
    p_li = {};
    for n = 1 : length(p_as)
      p_li = [p_li, p_as(n).i];
    endfor
  endif
  
  ## create data structure
  ## header
  r_ds.obj = 'struct_aggr_group';
  r_ds.ver = uint16([1, 0]);
  r_ds.des = 'Aggregation group data structure';
  ## data
  r_ds.i = p_gi; # group identifier
  r_ds.x = []; # group data array or matrix
  r_ds.u = p_as(1).u; # group unit
  r_ds.ut = p_as(1).ut; # group unit, LaTeX representation
  r_ds.d = p_gd; # group description
  r_ds.N = 0; # number of items (rows)
  r_ds.li = p_li; # group member identifier list
  
  ## join values
  for n = 1 : length(p_as)
    if (hlp_is_in_group(p_as(n).i, p_li))
      if isrow(p_as(n).x)
        ## join row vectors
        r_ds.x = [r_ds.x; p_as(n).x(:)];
      else
        ## join column vectors or matrices
        r_ds.x = [r_ds.x; p_as(n).x];
      endif
    endif
  endfor
  r_ds.N = size(r_ds.x, 1); # update number of items/rows
  
endfunction


function [r_r] = hlp_is_in_group(p_i, p_li)
  ## Check if atomic data structure identifier is matching one of the specified group identifiers
  ##
  ## Note: search is not case-sensitive
  ##
  ## p_i  ... atomic data structure identifier, {<str>}
  ## p_li ... list of identifiers to join, {<str>}
  ## p_r  ... return: search result, <bool>
  
  ## init return value
  r_r = false;
  
  ## check identifier list
  if not(iscell(p_li))
    p_li = {p_li};
  endif
  
  ## iterate over atomic data structure group labels
  for n = 1 : length(p_li)
    ## check membership
    if (strcmpi(p_i, p_li{n}))
      ## match
      r_r = true;
      break;
    endif
  endfor
  
endfunction
