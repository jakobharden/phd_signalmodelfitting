## Analysis parameter definitions
##
## Usage: [r_ds] = algo_param(p_rm)
##
## p_rm ... run mode, optional, default = 0 (do not export settings to TeX files), <uint>
## r_ds ... return: analysis parameter data structure, <struct_param>
##
## Notes:
##   1) Any parameters and constants used throughout the entire analysis are stored in this file!
##   2) After changing values, it is necessary to run algo_param(1) to export the values used in the manuscript.
##
## see also: algo_freqz, algo_part_1, algo_part_2, algo_part_3, algo_part_4, algo_stats, algo_mp41, algo_mp42
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
function [r_ds] = algo_param(p_rm = 0)
  
  ## Init data structure
  r_ds.obj = 'struct_algo_param';
  r_ds.ver = uint16([1, 0]);
  r_ds.des = 'Analysis parameter structure';
  
  #############################################################################
  ## File and directory path settings
  
  ## Result directory paths
  r_ds.rpath = fullfile('.', 'results');
  r_ds.rpath_algo_param = fullfile(r_ds.rpath, 'algo_param');
  r_ds.rpath_algo_mp43 = fullfile(r_ds.rpath, 'algo_mp43');
  r_ds.rpath_algo_sigfit = fullfile(r_ds.rpath, 'algo_sigfit');
  
  ## Dataset directory paths
  r_ds.datapath = fullfile(filesep(), 'home', 'harden', 'Documents', 'tugraz', '0_test_series');
  r_ds.dspath1 = fullfile(r_ds.datapath, 'ts1_cem1_paste', 'oct');
  r_ds.dspath2 = fullfile(r_ds.datapath, 'ts5_ref_air', 'oct');
  r_ds.dspath3 = fullfile(r_ds.datapath, 'ts6_ref_water', 'oct');
  r_ds.dspath4 = fullfile(r_ds.datapath, 'ts7_ref_aluminium', 'v11', 'oct');
  r_ds.dspaths = {r_ds.dspath1, r_ds.dspath2, r_ds.dspath3, r_ds.dspath4};
  
  ## Output file name prefix
  r_ds.par.fnpfx_out = 'par'; # algorithm parameters
  r_ds.sf.fnpfx_out = 'sf'; # semi-automated signal model fitting
  r_ds.mp43.fnpfx_out = 'mp43'; # MP4 video files, semi-automated signal model fitting results
  
  #############################################################################
  ## Signal model settings (synthetic signals)
  
  ## Sampling rate
  r_ds.sig.fs = 1e7; # Hz
  
  ## Nyquist frequency (sampling theorem of Nyquist-Shannon)
  r_ds.sig.fny = r_ds.sig.fs / 2; # Hz
  
  ## Number of cycles (number of complete sine waves)
  r_ds.sig.nc = 3;
  
  ## Frequency limits
  r_ds.sig.fq_low = 5000; # Hz
  r_ds.sig.fq_upp = 150000; # Hz
  
  ## Signal-to-noise ratio limits
  r_ds.sig.snr_low = 20; # dB
  r_ds.sig.snr_upp = 63; # dB
  
  ## Default signal model parameters
  ## mpar = [A, F1, alpha, beta, gamma]
  ## A     ... amplitude scaling factor
  ## F1    ... base frequency (first sinusoidal part)
  ## alpha ... frequency ratio (second sinusoidal part), alpha = F2 / F1
  ## beta  ... decay factor 1 (first exponential part)
  ## gamma ... decay factor 2 (second exponential part)
  #r_ds.sig.mpar = [1, r_ds.sig.fq_low, 2, 0.75, 5];
  r_ds.sig.mpar = [1, r_ds.sig.fq_low, 2, 0.5, 2.5];
  
  #############################################################################
  ## Signal properties (natural signals)
  
  ## Length and begin of electromagnetic response section (ERS), number of samples
  ## see also: Harden, J. (2023) 'Ultrasonic through-transmission method: Characterisation and detection of the 
  ##           electromagnetic disturbances caused by pulse excitation observed in combined compression and shear wave 
  ##           measurements of cement paste'. Graz University of Technology. doi: 10.3217/eh2ek-56e78.
  r_ds.nat.ers_len = [95, 95, 95, 85]; # ERS length (i = 1: cement paste, i = 2: ambient air, i = 3: tap water, i = 4: aluminium cylinder)
  r_ds.nat.ers_del = 10; # ERS delay, delay between trigger-point and initial amplitudes of the electromagentic disturbance
  
  ## transducer resonance frequency
  r_ds.nat.fqres = 500000; # Hz
  
  #############################################################################
  ## Semi-automated signal model fitting settings
  
  ## data set identifieres under consideration, see also algo_dsdefs.m
  r_ds.sf.dsids1 = [4, 5, 6, 10, 11, 12, 16, 17, 18]; # cement paste
  r_ds.sf.dsids2 = [1 : 16]; # ambient air
  r_ds.sf.dsids3 = [1 : 32]; # tap water
  r_ds.sf.dsids4 = [1 : 12]; # aluminium cylinder
  
  ## polynomial regression to find the maximum point
  r_ds.sf.prlmin = 10; # minimum number of samples required to use the regression
  r_ds.sf.prord = 2; # polynomial order
  
  ## parameter variation settings
  r_ds.sf.nvar = 30; # number of variation steps, interval subdivision
  r_ds.sf.intf = 10; # interpolation factor used to interpolate the natural signal
  r_ds.sf.rfmat = ...
  [
    [0.25, 1.5]; ...
    [0.75, 1.25]; ...
    [0.75, 1.25]; ...
    [0.75, 1.25] ...
  ]; # range factor matrix, row1 is related to F_1, row2 is related to alpha, row3 is related to beta, row4 is related to gamma
  ## variation range (e.g., F_1): F_1,0 * rfmat(1, 1) <= F_1,0 <= F_1,0 * rfmat(1, 2)
  
  ## optimisation error, weight factors for the weighted metric score
  r_ds.sf.phi1 = 2 / 3; # weight factor related to the optimisation error in first half of error measuring window
  r_ds.sf.phi2 = 1 / 3; # weight factor related to the optimisation error in second half of error measuring window
  r_ds.sf.phi = [r_ds.sf.phi1, r_ds.sf.phi2] / (r_ds.sf.phi1 + r_ds.sf.phi2); # phi = [phi_1, phi_2]
  ## error measuring window: signal partition between the sound wave's onset point and its first local maximum point
  
  ## optimisation error, this maximum error scores define the detection limit
  r_ds.sf.errmax = [0.001, 0.001, 0.009, 0.001]; # i = 1: cement paste, i = 2: ambient air, i = 3: tap water, i = 4: aluminium cylinder
  
  ## characterisation of the fitting error, quantile limits
  r_ds.sf.qlim = [0.05, 0.25, 0.75, 0.95];
  
  #############################################################################
  ## MP4 video output settings
  
  r_ds.mp4.res = [1280, 720]; # video resolution, see also: https://support.google.com/youtube/answer/6375112?hl=en&co=GENIE.Platform%3DDesktop
  r_ds.mp4.fr = 3; # video frame rate, frames per second
  r_ds.mp4.aut = 'Jakob Harden'; # author name
  r_ds.mp4.cpr = 'CC BY 4.0 (2025) Jakob Harden (Graz University of Technology)'; # copyright information
  r_ds.mp4.pub = 'Graz University of Technology (Graz, Austria)'; # publisher information
  r_ds.mp4.lic = 'This video is licensed under a Creative Commonons Attribution 4.0 International license.'; # license information
  
  ## everything beyond this line does not contain additional settings
  #############################################################################
  ## Create and export parameter data structure
  
  ## check arguments
  if (nargin == 0)
    ## do not export settings (default behaviour)
    return;
  endif
  
  ## data structure header
  ps = struct_initcollection('struct_algo_param', 'Parameter data structure containing the parameters for all algorithms', [1, 0], ...
    'algo_param', [1, 0]);
  ps.obj = 'struct_algo_param';
  ps.ver = uint16([1, 0]);
  ps.des = 'Parameter data structure containing the parameters for all algorithms';
  ## synthetic signal properties
  ps.sigfs = struct_objdata('sigfs', 'uint', r_ds.sig.fs, 'Hz', 'sampling frequency, Hz');
  ps.sigfskhz = struct_objdata('sigfskhz', 'uint', r_ds.sig.fs / 1000, 'kHz', 'Sampling frequency, kHz');
  ps.sigfsmhz = struct_objdata('sigfsmhz', 'uint', r_ds.sig.fs / 1e6, 'MHz', 'Sampling frequency, Mhz');
  ps.sigfny = struct_objdata('sigfny', 'uint', r_ds.sig.fny, 'Hz', 'Nyquist frequency, Hz');
  ps.sigfnykhz = struct_objdata('sigfnykhz', 'uint', r_ds.sig.fny / 1000, 'kHz', 'Nyquist frequency, kHz');
  ps.sigfnymhz = struct_objdata('sigfnymhz', 'uint', r_ds.sig.fny / 1e6, 'MHz', 'Nyquist frequency, MHz');
  ps.signc = struct_objdata('signc', 'uint', r_ds.sig.nc, '1', 'number of cycles (number of complete sine waves)');
  ps.sigfqlow = struct_objdata('sigfqlow', 'uint', r_ds.sig.fq_low, 'Hz', 'lowest frequency to be considered, Hz');
  ps.sigfqlowkhz = struct_objdata('sigfqlowkhz', 'uint', r_ds.sig.fq_low / 1000, 'kHz', 'lowest frequency to be considered, kHz');
  ps.sigfqupp = struct_objdata('sigfqupp', 'uint', r_ds.sig.fq_upp, 'Hz', 'highest frequency to be considered, Hz');
  ps.sigfquppkhz = struct_objdata('sigfquppkhz', 'uint', r_ds.sig.fq_upp / 1000, 'kHz', 'highest frequency to be considered, kHz');
  ps.sigsnrlow = struct_objdata('sigsnrlow', 'uint', r_ds.sig.snr_low, 'dB', 'lowest signal-to-noise ratio to be considered, dB');
  ps.sigsnrupp = struct_objdata('sigsnrupp', 'uint', r_ds.sig.snr_upp, 'dB', 'highest signal-to-noise ratio to be considered, dB');
  ps.sigmpar1 = struct_objdata('sigmpar1', 'dbl', r_ds.sig.mpar(1), '1', 'amplitude scaling factor');
  ps.sigmpar2 = struct_objdata('sigmpar2', 'dbl', r_ds.sig.mpar(2), 'Hz', 'primary frequency (first sinusoidal part)');
  ps.sigmpar3 = struct_objdata('sigmpar3', 'dbl', r_ds.sig.mpar(3), '1', 'frequency ratio (second sinusoidal part)');
  ps.sigmpar4 = struct_objdata('sigmpar4', 'dbl', r_ds.sig.mpar(4), '1', 'decay factor 1 (first exponential part)');
  ps.sigmpar5 = struct_objdata('sigmpar5', 'dbl', r_ds.sig.mpar(5), '1', 'decay factor 2 (second exponential part)');
  ## natural signal properties
  ps.naterslen = struct_objdata('naterslen', 'uint', r_ds.nat.ers_len, '1', 'electromagnetic response section length, number of samples');
  ps.natersdel = struct_objdata('natersdel', 'uint', r_ds.nat.ers_del, '1', 'electromagnetic response section delay, number of samples');
  ps.natfqres = struct_objdata('natfqres', 'uint', r_ds.nat.fqres, 'Hz', 'transducer resonance frequency, Hz');
  ps.natfqreskhz = struct_objdata('natfqres', 'uint', r_ds.nat.fqres / 1000, 'kHz', 'transducer resonance frequency, kHz');
  ## Semi-automated signal model fitting settings
  ps.sfprlmin = struct_objdata('sfprlmin', 'uint', r_ds.sf.prlmin, '1', ...
    'maximum point detection, minimum number of samples required to use the regression');
  ps.sfprord = struct_objdata('sfprord', 'uint', r_ds.sf.prord, '1', ...
    'maximum point detection, polynomial order of the regression');
  ps.sfnvar = struct_objdata('sfnvar', 'uint', r_ds.sf.nvar, '1', ...
    'parameter variation, number of variation steps, interval subdivision');
  ps.sfintf = struct_objdata('sfintf', 'uint', r_ds.sf.intf, '1', ...
    'interpolation factor used to interpolate the natural signal');
  ps.sfrf11 = struct_objdata('sfrf11', 'dbl', r_ds.sf.rfmat(1,1), '1', 'parameter variation, lower range factor, cement paste');
  ps.sfrf12 = struct_objdata('sfrf12', 'dbl', r_ds.sf.rfmat(1,2), '1', 'parameter variation, upper range factor, cement paste');
  ps.sfrf21 = struct_objdata('sfrf21', 'dbl', r_ds.sf.rfmat(2,1), '1', 'parameter variation, lower range factor, ambient air');
  ps.sfrf22 = struct_objdata('sfrf22', 'dbl', r_ds.sf.rfmat(2,2), '1', 'parameter variation, upper range factor, ambient air');
  ps.sfrf31 = struct_objdata('sfrf31', 'dbl', r_ds.sf.rfmat(3,1), '1', 'parameter variation, lower range factor, tap water');
  ps.sfrf32 = struct_objdata('sfrf32', 'dbl', r_ds.sf.rfmat(3,2), '1', 'parameter variation, upper range factor, tap water');
  ps.sfrf41 = struct_objdata('sfrf41', 'dbl', r_ds.sf.rfmat(4,1), '1', 'parameter variation, lower range factor, aluminium cylinder');
  ps.sfrf42 = struct_objdata('sfrf42', 'dbl', r_ds.sf.rfmat(4,2), '1', 'parameter variation, upper range factor, aluminium cylinder');
  ps.sfphi1 = struct_objdata('sfphi1', 'dbl', r_ds.sf.phi(1), '1', ...
    'weighted error score, weight factor, first half of error measuring window');
  ps.sfphi2 = struct_objdata('sfphi2', 'dbl', r_ds.sf.phi(2), '1', ...
    'weighted error score, weight factor, second half of error measuring window');
  ps.sferrmax1 = struct_objdata('sferrmax1', 'dbl', r_ds.sf.errmax(1), '1', ...
    'weighted error score maximum, detection limit for signals from cement paste tests');
  ps.sferrmax2 = struct_objdata('sferrmax2', 'dbl', r_ds.sf.errmax(2), '1', ...
    'weighted error score maximum, detection limit for signals from tests on ambient air');
  ps.sferrmax3 = struct_objdata('sferrmax3', 'dbl', r_ds.sf.errmax(3), '1', ...
    'weighted error score maximum, detection limit for signals from tests on tap water');
  ps.sferrmax4 = struct_objdata('sferrmax4', 'dbl', r_ds.sf.errmax(4), '1', ...
    'weighted error score maximum, detection limit for signals from tests on aluminium cylinder');
  ##
  ## export settings
  ofp = fullfile(r_ds.rpath_algo_param, sprintf('%s_settings', r_ds.par.fnpfx_out));
  tex_struct_export(ps, 'par', ofp);
  
endfunction
