## Select atomic data structure from set of atomic data structures by identifier
##
## Usage: [r_as] = aggr_select(p_as, p_id)
##
## p_as ... atomic data structure array, [<struct_aggr_atom>]
## p_id ... data structure identifier, <str>
## r_ds ... return: atomic data structure, <struct_aggr_atom>
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
function [r_as] = aggr_select(p_as, p_id)
  
  ## check arguments
  if (nargin < 2)
    help aggr_select;
    error('Less arguments given!');
  endif
  
  ## select atmic data structure
  r_as = [];
  for n = 1 : length(p_as)
    if (strcmpi(p_id, p_as(n).i))
      r_as = p_as(n);
      break;
    endif
  endfor
  
endfunction
