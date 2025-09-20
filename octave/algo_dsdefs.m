## Data set definitions
##
## Usage: [r_ds] = algo_dsdefs(p_dtp)
##
## p_dtp ... dataset type enumerator, <uint>
## r_ds  ... return: dataset definition data structure, <struct_dsdef>
##
## Available dataset types:
##   p_dtp = 1: cement paste, dataset definitions
##   p_dtp = 2: air, reference test dataset definitions
##   p_dtp = 3: water, reference test dataset definitions
##   p_dtp = 4: aluminium cylinder, reference test dataset definitions
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
function [r_ds] = algo_dsdefs(p_dtp)
  
  ## load analysis parameter structure
  ap = algo_param();
  
  ## switch dataset type enumerator
  switch (p_dtp)
    case 1
      r_ds = hlp_dsl1(ap.dspath1);
    case 2
      r_ds = hlp_dsl2(ap.dspath2);
    case 3
      r_ds = hlp_dsl3(ap.dspath3);
    case 4
      r_ds = hlp_dsl4(ap.dspath4);
    otherwise
      error('Dataset type not available: %d', p_dtp);
  endswitch
  
endfunction


function [r_ds] = hlp_dsl1(p_dp)
  ## Setup dataset list 1: cement paste
  ##
  ## p_dp ... dataset directory path, <str>
  ## r_ds ... dataset definition data structure, <struct_dsdef>
  
  r_ds.obj = 'algo_dsdefs';
  r_ds.ver = uint16([1, 0]);
  r_ds.des = 'Dataset definition structure';
  
  r_ds.dsdir = p_dp;
  r_ds.dstype = 1;
  r_ds.dstype_str = 'cem1paste';
  r_ds.dsnum = 90;
  r_ds.tsid = 1; # test series id
  r_ds.tspfx = sprintf('ts%d', r_ds.tsid); # test series prefix
  r_ds.tsname = sprintf('Test series %d', r_ds.tsid); # test series name
  r_ds.tslong = sprintf('%s - %s', r_ds.tsname, r_ds.dstype_str); # test series name, long version
  r_ds.tsdoi = 'https://doi.org/10.3217/bhs4g-m3z76'; # digital object identifier
  
  pl_wc = {'040', '045', '050', '055', '060'};
  pl_di = {'25', '50', '70'};
  pl_umd = [25, 50, 70];
  pl_rp = {'1', '2', '3', '4', '5', '6'};
  r_ds.dsl = cell(1, r_ds.dsnum);
  r_ds.dsc = cell(1, r_ds.dsnum);
  r_ds.umd = zeros(1, r_ds.dsnum);
  cnt = 1;
  for i1 = 1 : length(pl_wc)
    for i2 = 1 : length(pl_di)
      for i3 = 1 : length(pl_rp)
        r_ds.dsc{cnt} = sprintf('%s_wc%s_d%s_%s', r_ds.tspfx, pl_wc{i1}, pl_di{i2}, pl_rp{i3});
        fn = sprintf('%s_wc%s_d%s_%s.oct', r_ds.tspfx, pl_wc{i1}, pl_di{i2}, pl_rp{i3});
        r_ds.dsl{cnt} = fullfile(r_ds.dsdir, fn);
        r_ds.umd(cnt) = pl_umd(i2);
        cnt += 1;
      endfor
    endfor
  endfor
  
endfunction


function [r_ds] = hlp_dsl2(p_dtp)
  ## Setup dataset list 2: air
  ##
  ## p_dtp ... dataset directory path, <str>
  ## r_ds  ... dataset definition data structure, <struct_dsdef>
  
  r_ds.obj = 'algo_dsdefs';
  r_ds.ver = uint16([1, 0]);
  r_ds.des = 'Dataset definition structure';
  
  r_ds.dsdir = p_dtp;
  r_ds.dstype = 2;
  r_ds.dstype_str = 'air';
  r_ds.dsnum = 0;
  r_ds.tsid = 5; # test series id
  r_ds.tspfx = sprintf('ts%d', r_ds.tsid); # test series prefix
  r_ds.tsname = sprintf('Test series %d', r_ds.tsid); # test series name
  r_ds.tslong = sprintf('%s - %s', r_ds.tsname, r_ds.dstype_str); # test series name, long version
  r_ds.tsdoi = 'https://doi.org/10.3217/bjkrj-pg829'; # digital object identifier
  
  pl_di = {'25', '50', '70', '90'}; # distance, mm
  pl_umd = [25, 50, 70, 90];
  pl_bs = {'16', '24', '33', '50'}; # block size, recording length, kilo-samples
  #pl_pv = {'400', '600', '800'}; # pulse voltage, V
  pl_pv = {'800'}; # pulse voltage, V
  r_ds.dsnum = length(pl_di) * length(pl_bs) * length(pl_pv);
  r_ds.dsl = cell(1, r_ds.dsnum);
  r_ds.dsc = cell(1, r_ds.dsnum);
  r_ds.umd = zeros(1, r_ds.dsnum);
  cnt = 1;
  for i1 = 1 : length(pl_di);
    for i2 = 1 : length(pl_bs);
      for i3 = 1 : length(pl_pv);
        r_ds.dsc{cnt} = sprintf('%s_d%s_b%s_v%s', r_ds.tspfx, pl_di{i1}, pl_bs{i2}, pl_pv{i3});
        fn = sprintf('%s_d%s_b%s_v%s.oct', r_ds.tspfx, pl_di{i1}, pl_bs{i2}, pl_pv{i3});
        r_ds.dsl{cnt} = fullfile(r_ds.dsdir, fn);
        r_ds.umd(cnt) = pl_umd(i1);
        cnt += 1;
      endfor
    endfor
  endfor
  
endfunction


function [r_ds] = hlp_dsl3(p_dtp)
  ## Setup dataset list 3: water
  ##
  ## p_dtp ... dataset directory path, <str>
  ## r_ds  ... dataset definition data structure, <struct_dsdef>
  
  r_ds.obj = 'algo_dsdefs';
  r_ds.ver = uint16([1, 0]);
  r_ds.des = 'Dataset definition structure';
  
  r_ds.dsdir = p_dtp;
  r_ds.dstype = 3;
  r_ds.dstype_str = 'water';
  r_ds.dsnum = 0;
  r_ds.tsid = 6; # test series id
  r_ds.tspfx = sprintf('ts%d', r_ds.tsid); # test series prefix
  r_ds.tsname = sprintf('Test series %d', r_ds.tsid); # test series name
  r_ds.tslong = sprintf('%s - %s', r_ds.tsname, r_ds.dstype_str); # test series name, long version
  r_ds.tsdoi = 'https://doi.org/10.3217/hn7we-q7z09'; # digital object identifier
  
  pl_di = {'25', '50', '70', '90'}; # distance, mm
  pl_umd = [25, 50, 70, 90];
  pl_bs = {'16', '24', '33', '50'}; # block size, recording length, kilo-samples
  #pl_pv = {'400', '600', '800'}; # pulse voltage, V
  pl_pv = {'600', '800'}; # pulse voltage, V
  r_ds.dsnum = length(pl_di) * length(pl_bs) * length(pl_pv);
  r_ds.dsl = cell(1, r_ds.dsnum);
  r_ds.dsc = cell(1, r_ds.dsnum);
  r_ds.umd = zeros(1, r_ds.dsnum);
  cnt = 1;
  for i1 = 1 : length(pl_di);
    for i2 = 1 : length(pl_bs);
      for i3 = 1 : length(pl_pv);
        if (i1 == 4)
          r_ds.dsc{cnt} = sprintf('%s_d%s_b%s_v%s_2', r_ds.tspfx, pl_di{i1}, pl_bs{i2}, pl_pv{i3});
          fn = sprintf('%s_d%s_b%s_v%s_2.oct', r_ds.tspfx, pl_di{i1}, pl_bs{i2}, pl_pv{i3});
        else
          r_ds.dsc{cnt} = sprintf('%s_d%s_b%s_v%s', r_ds.tspfx, pl_di{i1}, pl_bs{i2}, pl_pv{i3});
          fn = sprintf('%s_d%s_b%s_v%s.oct', r_ds.tspfx, pl_di{i1}, pl_bs{i2}, pl_pv{i3});
        endif
        r_ds.dsl{cnt} = fullfile(r_ds.dsdir, fn);
        r_ds.umd(cnt) = pl_umd(i1);
        cnt += 1;
      endfor
    endfor
  endfor
  
endfunction


function [r_ds] = hlp_dsl4(p_dtp)
  ## Setup dataset list 4: aluminium cylinder
  ##
  ## p_dtp ... dataset directory path, <str>
  ## r_ds  ... dataset definition data structure, <struct_dsdef>
  
  r_ds.obj = 'algo_dsdefs';
  r_ds.ver = uint16([1, 0]);
  r_ds.des = 'Dataset definition structure';
  
  r_ds.dsdir = p_dtp;
  r_ds.dstype = 4;
  r_ds.dstype_str = 'aluminium cylinder';
  r_ds.dsnum = 0;
  r_ds.tsid = 7; # test series id
  r_ds.tspfx = sprintf('ts%d', r_ds.tsid); # test series prefix
  r_ds.tsname = sprintf('Test series %d', r_ds.tsid); # test series name
  r_ds.tslong = sprintf('%s - %s', r_ds.tsname, r_ds.dstype_str); # test series name, long version
  r_ds.tsdoi = 'https://doi.org/10.3217/w3mb5-1wx17'; # digital object identifier
  
  pl_di = {'50'}; # distance, mm
  pl_umd = [50];
  pl_bs = {'16', '24', '33', '50'}; # block size, recording length, kilo-samples
  pl_pv = {'400', '600', '800'}; # pulse voltage, V
  r_ds.dsnum = length(pl_di) * length(pl_bs) * length(pl_pv);
  r_ds.dsl = cell(1, r_ds.dsnum);
  r_ds.dsc = cell(1, r_ds.dsnum);
  r_ds.umd = zeros(1, r_ds.dsnum);
  cnt = 1;
  for i1 = 1 : length(pl_di);
    for i2 = 1 : length(pl_bs);
      for i3 = 1 : length(pl_pv);
        r_ds.dsc{cnt} = sprintf('%s_d%s_b%s_v%s', r_ds.tspfx, pl_di{i1}, pl_bs{i2}, pl_pv{i3});
        fn = sprintf('%s_d%s_b%s_v%s.oct', r_ds.tspfx, pl_di{i1}, pl_bs{i2}, pl_pv{i3});
        r_ds.dsl{cnt} = fullfile(r_ds.dsdir, fn);
        r_ds.umd(cnt) = pl_umd(i1);
        cnt += 1;
      endfor
    endfor
  endfor
  
endfunction
