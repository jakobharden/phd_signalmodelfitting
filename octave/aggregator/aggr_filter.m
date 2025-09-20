## Filter set of atomic data structures by filter criterion
##
## Usage: [r_as] = aggr_filter(p_as, p_fc, p_fo, p_fv, p_ad)
##
## p_as ... atomic data structure (scalar structure or structure array), <struct_aggr_atom> or [<struct_aggr_atom>]
## p_fc ... filter support, <str>
## p_fo ... filter operator, <str>
## p_fv ... filter value, <dbl> or <uint>
## p_ad ... auxilary data, [<dbl>]
## r_ds ... return: filtered atomic data structure array, <struct_aggr_atom>
##
## Filter supports:
##   p_fc = 'index', 'idx', 'i':    filter array or matrix x using the row index of x
##   p_fc = 'value', 'val', 'v':    filter array x using the values of x
##   p_fc = 'row-min', 'rmin':      filter matrix x using the ensemble minimum of each row
##   p_fc = 'row-max', 'rmax':      filter matrix x using the ensemble maximum of each row
##   p_fc = 'row-avg', 'ravg':      filter matrix x using the ensemble average of each row
##   p_fc = 'row-med', 'rmed':      filter matrix x using the ensemble median of each row
##   p_fc = 'auxilary', 'aux', 'a': filter array or matrix x using an auxilary data array
##                    (number of rows of the auxilary data array and the data array x must be equal)
##
## Filter operators:
##   p_fo = 'eq', '=', '==': x equal to filter value
##   p_fo = 'gt', '>':       x is greater than filter value
##   p_fo = 'ge', '>=':      x is greater then or equal to filter value
##   p_fo = 'lt', '<':       x is lower than filter value
##   p_fo = 'le', '<=':      x is lower then or equal to filter value
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
function [r_as] = aggr_filter(p_as, p_fc, p_fo, p_fv, p_ad)
  
  ## check arguments
  if (nargin < 4)
    p_gd = '';
  endif
  if (nargin < 3)
    help aggr_join;
    error('Less arguments given!');
  endif
  
  ## filter criterion and filter operator
  fc = tolower(p_fc);
  fo = tolower(p_fo);
  
  ## filter atomic data structures
  r_as = p_as;
  for n = 1 : length(p_as)
    ## select filter support
    switch (fc)
      case {'index', 'fltidx', 'i'}
        ## use row index of x
        r_as(n).x = hlp_filter_index(r_as(n).x, fo, p_fv);
      case {'value', 'val', 'v'}
        ## use values of array x
        r_as(n).x = hlp_filter_valarray(r_as(n).x, fo, p_fv);
      case {'row-min', 'rmin'}
        ## use ensemble minimum of each row of matrix x
        r_as(n).x = hlp_filter_valmatrix(r_as(n).x, fo, p_fv, 'min');
      case {'row-max', 'rmax'}
        ## use ensemble maximum of each row of matrix x
        r_as(n).x = hlp_filter_valmatrix(r_as(n).x, fo, p_fv, 'max');
      case {'row-avg', 'ravg'}
        ## use ensemble average of each row of matrix x
        r_as(n).x = hlp_filter_valmatrix(r_as(n).x, fo, p_fv, 'avg');
      case {'row-med', 'rmed'}
        ## use ensemble median of each row of matrix x
        r_as(n).x = hlp_filter_valmatrix(r_as(n).x, fo, p_fv, 'med');
      case {'auxilary', 'aux', 'a'}
        ## use auxilary data provided along with x
        r_as(n).x = hlp_filter_auxilary(r_as(n).x, fo, p_fv, p_ad);
      otherwise
        ## not implemented
        help aggr_filter;
        error('Filter criterion "%s" not implemented yet!', fc);
    endswitch
    r_as(n).N = size(r_as(n).x, 1);
  endfor
  
endfunction


function [r_x] = hlp_filter_index(p_x, p_fo, p_fv)
  ## Filter data by row index (argument of x)
  ##
  ## p_x  ... data, [<dbl>] or [[<dbl>]]
  ## p_fo ... filter operator, <str>
  ## r_x  ... return: filtered data, [] or [<dbl>] or [[<dbl>]]
  
  ## check x
  if isempty(p_x)
    r_x = [];
    return;
  endif
  
  ## row index array
  ridx = 1 : size(x, 1);
  
  ## select filter operator and create filter index list
  switch (p_fo)
    case {'equal', 'eq', '=', '=='}
      ## filter: arg(x) == fv
      p_fv = fix(p_fv);
      if (p_fv < 1) || (p_fv > length(ridx))
        fltidx = [];
      else
        fltidx = p_fv;
      endif
    case {'greater-than', 'gt', '>'}
      ## filter: arg(x) > fv
      fltidx = find(ridx > p_fv);
    case {'greater-or-equal', 'ge', '>='}
      ## filter: arg(x) >= fv
      fltidx = find(ridx >= p_fv);
    case {'lower-than', 'lt', '<'}
      ## filter: arg(x) < fv
      fltidx = find(ridx < p_fv);
    case {'lower-or-equal', 'le', '<='}
      ## filter: arg(x) <= fv
      fltidx = find(ridx <= p_fv);
    otherwise
      help aggr_filter;
      error('Filter operator "%s" not implemented yet!', p_fo);
  endswitch
  
  ## filter data
  r_x = p_x(fltidx, :);
  
endfunction


function [r_x] = hlp_filter_valarray(p_x, p_fo, p_fv)
  ## Filter data by value of array x
  ##
  ## p_x  ... data, [<dbl>] or [[<dbl>]]
  ## p_fo ... filter operator, <str>
  ## r_x  ... return: filtered data, [] or [<dbl>] or [[<dbl>]]
  
  ## check x
  if isempty(p_x)
    r_x = [];
    return;
  endif
  if not(isrow(p_x) || iscolumn(p_x))
    error('Data array must be a row or column vector!');
  endif
  if isrow(p_x)
    p_x = p_x(:);
  endif
  
  ## select filter operator and create filter index list
  switch (p_fo)
    case {'equal', 'eq', '=', '=='}
      ## filter: x == fv
      fltidx = find(p_x == p_fv);
    case {'greater-than', 'gt', '>'}
      ## filter: x > fv
      fltidx = find(p_x > p_fv);
    case {'greater-or-equal', 'ge', '>='}
      ## filter: x >= fv
      fltidx = find(p_x >= p_fv);
    case {'lower-than', 'lt', '<'}
      ## filter: x < fv
      fltidx = find(p_x < p_fv);
    case {'lower-or-equal', 'le', '<='}
      ## filter: x <= fv
      fltidx = find(p_x <= p_fv);
    otherwise
      help aggr_filter;
      error('Filter operator "%s" not implemented yet!', p_fo);
  endswitch
  
  ## filter data
  r_x = p_x(fltidx, :);
  
endfunction


function [r_x] = hlp_filter_valmatrix(p_x, p_fo, p_fv, p_em)
  ## Filter data by value of array x
  ##
  ## p_x  ... data, [[<dbl>]]
  ## p_fo ... filter operator, <str>
  ## r_em ... row ensemble mode, one out of {'min', 'max', 'avg', 'med'}, <str>
  ## r_x  ... return: filtered data, [] or [[<dbl>]]
  
  ## check x
  if isempty(p_x)
    r_x = [];
    return;
  endif
  
  ## select ensemble mode, compute auxilary array for filtering
  switch (p_em)
    case 'min'
      ## minimum of each row
      aux = min(p_x, [], 2);
    case 'max'
      ## maximum of each row
      aux = max(p_x, [], 2);
    case 'avg'
      ## average of each row
      aux = mean(p_x, 2);
    case 'med'
      ## median of each row
      aux = median(p_x, 2);
    otherwise
      error('Row ensemble mode "%s" not implemented yet!', p_em);
  endswitch
  
  ## filter data
  r_x = hlp_filter_auxilary(p_x, p_fo, p_fv, aux);
  
endfunction


function [r_x] = hlp_filter_auxilary(p_x, p_fo, p_fv, p_ad)
  ## Filter data by auxilary data provided along with the data
  ##
  ## p_x  ... data, [<dbl>] or [[<dbl>]]
  ## p_fo ... filter operator, <str>
  ## p_ad ... auxilary data, [<dbl>]
  ## r_x  ... return: filtered data, [] or [<dbl>] or [[<dbl>]]
  
  ## check x
  if isempty(p_x)
    r_x = [];
    return;
  endif
  
  ## check auxilary data
  if not(iscolumn(p_ad) || isrow(p_ad))
    error('Auxilary data must be a row or column vector!');
  endif
  p_ad = p_ad(:);
  
  ## check array size
  if (size(p_x, 1) != length(p_ad))
    error('Lenght of auxilary data array (%d) and number of rows of data x (%d) are not equal!', length(p_ad), size(p_x, 1));
  endif
  
  ## select filter operator and create filter index list
  switch (p_fo)
    case {'equal', 'eq', '=', '=='}
      ## filter: ad == fv
      fltidx = find(p_ad == p_fv);
    case {'greater-than', 'gt', '>'}
      ## filter: ad > fv
      fltidx = find(p_ad > p_fv);
    case {'greater-or-equal', 'ge', '>='}
      ## filter: ad >= fv
      fltidx = find(p_ad >= p_fv);
    case {'lower-than', 'lt', '<'}
      ## filter: ad < fv
      fltidx = find(p_ad < p_fv);
    case {'lower-or-equal', 'le', '<='}
      ## filter: ad <= fv
      fltidx = find(p_ad <= p_fv);
    otherwise
      help aggr_filter;
      error('Filter operator "%s" not implemented yet!', p_fo);
  endswitch
  
  ## filter data
  r_x = p_x(fltidx, :);
  
endfunction
