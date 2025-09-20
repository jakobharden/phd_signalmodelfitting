## Create atomic data structure for a univariate distribution
##
## Usage: [r_ds] = aggr_atom(p_i, p_x, p_u, p_d)
##
## p_i  ... identifier, <str>
## p_x  ... number array, [<dbl>] or [[<dbl>]]
## p_u  ... unit, <str>
## p_d  ... description, optional, default = '', <str>
## r_ds ... return: atomic data structure, univariate distribution, <struct_aggr_atom>
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
function [r_ds] = aggr_atom(p_i, p_x, p_u, p_ut, p_d)
  
  ## check arguments
  if (nargin < 5)
    p_d = '';
  endif
  if (nargin < 4)
    p_ut = '';
  endif
  if (nargin < 3)
    p_u = '';
  endif
  if (nargin < 2)
    help aggr_atom;
    error('Less arguments given!');
  endif
  
  ## create data structure
  ## header
  r_ds.obj = 'struct_aggr_atom';
  r_ds.ver = uint16([1, 0]);
  r_ds.des = 'Aggregation atom data structure';
  ## data
  r_ds.i = p_i; # atom identifier
  r_ds.x = p_x; # value array or value matrix
  r_ds.u = p_u; # unit, Octave representation
  r_ds.ut = p_ut; # unit, LaTeX representation
  r_ds.d = p_d; # atom description
  r_ds.N = size(p_x, 1); # number of items (rows)
  
endfunction
