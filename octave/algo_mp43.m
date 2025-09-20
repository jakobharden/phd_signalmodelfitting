## Create MP4 video file showing the semi-automated signal model fitting results
##
## Usage: algo_mp43()
##
## Note:
##  1) Compile MP4 video for all test series (cement paste, air, water, alumninium cylinder)
##  2) The required data to render the video files are taken from the results of algo_sigfit.m
##          
## see also: algo_sigfit.m, algo_param.m
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
function algo_mp43()
  
  ## load video package
  pkg load video;
  
  ## load analysis parameter structure
  ap = algo_param();
  
  ## channel identifier
  cid = 1; # P-wave
  
  ## generate list of signal model fitting results
  fpat = sprintf('%s%s%s%s*_fit.oct', ap.rpath_algo_sigfit, filesep, 'oct', filesep);
  flst = dir(fpat);
  
  ##-------------------------------------------------------------------------------------
  ## render videos
  
  ## loop over analysis result datasets
  for i = 1 : numel(flst)
    ## input file path
    ifn = flst(i).name;
    ifp = fullfile(flst(i).folder, ifn);
    ## load analysis result
    ads = load(ifp, 'ads').ads;
    ## render results to MP4 video file
    mp43_video(ap, ads);
  endfor
  
  ##-------------------------------------------------------------------------------------
  ## create video description file
  
  ## open file
  ofp_descr = fullfile(ap.rpath_algo_mp43, filesep, 'video_description.txt');
  fid = fopen(ofp_descr, 'w');
  ## loop over analysis result datasets
  for i = 1 : numel(flst)
    ## input file path
    ifn = flst(i).name;
    ifp = fullfile(flst(i).folder, ifn);
    ## load analysis result
    ads = load(ifp, 'ads').ads;
    ## write video description to file
    int_umd = algo_dsdefs(ads.dstype.v).umd(ads.did.v);
    str_mat = {'cement paste at the early stage of hydration', 'ambient air', 'tap water', 'aluminium cylinder'}{ads.dstype.v};
    fprintf(fid, '--------------------------------------------------------\n');
    fprintf(fid, 'dataset: %s\n', ads.dscode.v);
    fprintf(fid, '\n');
    fprintf(fid, '%s - signal model fitting results\n', ads.dscode.v);
    fprintf(fid, '\n');
    fprintf(fid, 'Signal analysis concerning signal recordings from ultrasonic pulse transmission tests. Semi-automated fitting of a damped sinusoidal signal model to natural signals. In this video, the signals, the optimised signal model parameters and the optimisation error are shown. Testing material: %s; Ultrasonic measuring distance: %d mm; Data set: %s.oct; %s (DOI: %s)\n', str_mat, int_umd, ads.dscode.v, ads.tsname.v, ads.tsdoi.v);
    fprintf(fid, '\n');
    fprintf(fid, 'License:\n');
    fprintf(fid, 'Copyright (2025) Jakob Harden (Graz University of Technology, Graz, Austria)\n');
    fprintf(fid, 'This video is licensed under a Creative Commons Attribution 4.0 International license.\n');
    fprintf(fid, 'This file is part of the PhD Thesis of Jakob Harden.\n');
    fprintf(fid, '\n');
    fprintf(fid, 'Author information:\n');
    fprintf(fid, 'Website: https://jakobharden.at/wordpress/\n');
    fprintf(fid, 'E-Mail: jakob.harden@tugraz.at, jakob.harden@student.tugraz.at, office@jakobharden.at\n');
    fprintf(fid, 'ORCID: https://orcid.org/0000-0002-5752-1785\n');
    fprintf(fid, 'LinkedIn: https://www.linkedin.com/in/jakobharden/\n');
    fprintf(fid, '\n');
  endfor
  ## close file
  fclose(fid);

endfunction


function mp43_video(p_ap, p_ads)
  ## Render MP4 video for a dataset showing the analysis results for each signal
  ##
  ## p_ap  ... analysis parameter structure, <struct_algo_param>
  ## p_ads ... analysis data structure, see also algo_part_4, <struct_algo_part_4>
  
  ## detection limit
  dl = p_ads.dlima.v;
  if (dl == 0)
    return;
  endif
  idx = dl : size(p_ads.nmat.v, 1);
  
  ## analysis result matrices
  nmat = p_ads.nmat.v(idx, :);
  pmat = p_ads.pmat.v(idx, :);
  emat = p_ads.emat.v(idx, :);
  
  ## data set parameters
  dscode = p_ads.dscode.v; # data set code, string representation
  dscode_tex = strrep(dscode, '_', '\_'); # data set code, TeX representation
  dsch = p_ads.cid.v; # channel, P-wave (1) or S-wave (2)
  tsdoi = p_ads.tsdoi.v; # DOI of data set
  Nsig = numel(idx); # number of signals within detection limits
  
  ## video output file path
  ofp = fullfile(p_ap.rpath_algo_mp43, sprintf('%s_%s.mp4', p_ap.mp43.fnpfx_out, dscode));
  if (exist(ofp, 'file') == 2)
    delete(ofp);
  endif
  
  ## create temporary directory for the video frames
  mp4_tmpdir = fullfile(p_ap.rpath_algo_mp43, 'tmp');
  mkdir(mp4_tmpdir);
  
  ## print status message
  printf('algo_mp43: rendering dataset %s\n', dscode);
  printf('  number of signals = %d\n', Nsig);
  printf('  detection limit   = %d\n', dl);
  printf('  output file path  = %s\n', ofp);
  
  ## loop over analysis results for each signal
  anx0 = 0.08; # annotation x0
  any0 = 0.9; # annotation y0
  txtf = 0.025;
  fh = figure('name', dscode, 'position', [100, 100, p_ap.mp4.res]);
  annotation(fh, 'textbox', [0, 0, 1, 0.1], 'string', p_ap.mp4.cpr, ...
    'linestyle', 'none', 'fontsize', 10); # copyright information
  annotation(fh, 'rectangle', [anx0, any0 - 0.34, 0.13, 0.27], ...
    'facecolor', [1, 1, 1], 'linestyle', 'none'); # legend background
  annotation(fh, 'textbox', [anx0, any0 - 0.09, 1, 0.1], 'string', 'Signal model parameters', ...
    'linestyle', 'none', 'fontsize', 12, 'fontweight', 'bold'); # legend, line 1
  annotation(fh, 'textbox', [anx0, any0 - 0.12, 1, 0.1], 'string', sprintf('  sampling frequency = %d MHz', p_ads.fsmhz.v), ...
    'linestyle', 'none', 'fontsize', 12); # legend, line 2
  for j = 1 : Nsig
    ## signal id
    sid = dl + j - 1;
    ## values
    nn_ss = p_ads.optss(j).nn_ss;
    ss = p_ads.optss(j).ss;
    nn_xx = p_ads.optss(j).nn_xx;
    xx = p_ads.optss(j).xx;
    dL = max([nmat(j, 5) - nmat(j, 2), 10]); # nx_intp - n0, min 10 samples
    xl = [nmat(j, 2) - (dL * 1.5), nmat(j, 2) + (dL * 1.25)]; # n0 +/- dL
    yl = [-0.5, 1.1];
    ## plot
    if (j == 1) # initialise frame
      ## create axis
      ah = axes(fh, 'tickdir', 'out', 'position', [0.07, 0.08, 0.84, 0.835], 'xlim', xl, 'ylim', yl);
      tith = title(ah, sprintf('Data set: %s, channel: P-wave, signal id: %d', dscode_tex, sid));
      set(tith, 'fontsize', 16);
      xlabel(ah, 'Sample index [1]');
      ylabel(ah, 'Amplitude, norm. [1]');
      ## variable annotation
      anh1 = annotation(fh, 'textbox', [anx0, any0 - 0.14, 1, 0.1], 'string', sprintf('  A = %.1f', pmat(j, 1)), ...
        'linestyle', 'none', 'fontsize', 12); # legend, line 3
      anh2 = annotation(fh, 'textbox', [anx0, any0 - 0.16, 1, 0.1], 'string', sprintf('  F_1 = %.3f kHz', pmat(j, 2) / 1000), ...
        'linestyle', 'none', 'fontsize', 12); # legend, line 4
      anh3 = annotation(fh, 'textbox', [anx0, any0 - 0.18, 1, 0.1], 'string', sprintf('  alpha = %.2f', pmat(j, 3)), ...
        'linestyle', 'none', 'fontsize', 12); # legend, line 5
      anh4 = annotation(fh, 'textbox', [anx0, any0 - 0.20, 1, 0.1], 'string', sprintf('  beta = %.2f', pmat(j, 4)), ...
        'linestyle', 'none', 'fontsize', 12); # legend, line 6
      anh5 = annotation(fh, 'textbox', [anx0, any0 - 0.22, 1, 0.1], 'string', sprintf('  gamma = %.2f', pmat(j, 5)), ...
        'linestyle', 'none', 'fontsize', 12); # legend, line 7
      anh6 = annotation(fh, 'textbox', [anx0, any0 - 0.24, 1, 0.1], 'string', sprintf('  error = %.3f * 10^{-3}', emat(j, 1) * 1e3), ...
        'linestyle', 'none', 'fontsize', 12); # legend, line 7
      anh7 = annotation(fh, 'textbox', [anx0, 0.12, 1, 0.1], ...
        'string', '  s[n] = ( sin(omg*n) + 1/alpha * sin(omg*n*alpha) ) * (1 - exp(-beta*n/(N-1)) * exp(-gamma*n/(N-1))', ...
        'linestyle', 'none', 'fontsize', 12); # legend, line 8
      ## plots
      hold(ah, 'on');
      ph1 = plot(ah, xl, [0, 0], 'linewidth', 0.5, 'color', [1, 1, 1] * 0.5, 'handlevisibility', 'off'); # x axis
      ph2 = plot(ah, nn_xx, xx, 'linewidth', 1, 'color', [1, 1, 1] * 0.5, 'displayname', 'x[n]'); # signal
      ph3 = plot(ah, nn_ss, ss, 'linewidth', 2, 'color', 'r', 'displayname', 's[n]'); # signal
      ph4 = plot(ah, nmat(j, 2), 0, 'o', 'linewidth', 1, 'color', 'k', 'handlevisibility', 'off'); # onset point
      ph5 = plot(ah, nmat(j, 3), 0, 'o', 'linewidth', 1, 'color', 'k', 'handlevisibility', 'off'); # maximum location
      ph6 = plot(ah, nmat(j, 3), 1, 'o', 'linewidth', 1, 'color', 'k', 'handlevisibility', 'off'); # maximum point
      ph7 = plot(ah, [1, 1] * nmat(j, 3), [0, 1], ':', 'linewidth', 1, 'color', 'k', 'handlevisibility', 'off'); # dotted line to maximum point
      ph8 = plot(ah, nmat(j, 5), 0, 'o', 'linewidth', 1, 'color', 'k', 'handlevisibility', 'off'); # x-axis crossing
      th1 = text(ah, nmat(j, 2), -0.02, sprintf(' n_0 = %d ', nmat(j, 2)), ...
        'horizontalalignment', 'left', 'verticalalignment', 'top', 'fontsize', 12);
      th2 = text(ah, nmat(j, 3), -0.02, sprintf(' n_{max,1} = %d ', nmat(j, 3)), ...
        'horizontalalignment', 'left', 'verticalalignment', 'top', 'fontsize', 12);
      th3 = text(ah, nmat(j, 5), 0.02, sprintf(' n_{xc} = %d ', nmat(j, 5)), ...
        'horizontalalignment', 'left', 'verticalalignment', 'bottom', 'fontsize', 12);
      hold(ah, 'off');
      legend(ah, 'box', 'off', 'location', 'northwest');
    else # update frame
      xlim(ah, xl); # x axis limits
      ylim(ah, yl); # y axis limits
      title(ah, sprintf('Data set: %s, channel: P-wave, signal id: %d', dscode_tex, sid));
      set(ph1, 'xdata', xl); # x axis
      set(ph2, 'xdata', nn_xx, 'ydata', xx);
      set(ph3, 'xdata', nn_ss, 'ydata', ss);
      set(ph4, 'xdata', nmat(j, 2)); # onset point
      set(ph5, 'xdata', nmat(j, 3)); # maximum location
      set(ph6, 'xdata', nmat(j, 3)); # maximum point
      set(ph7, 'xdata', [1, 1] * nmat(j, 3)); # dotted line to maximum point
      set(ph8, 'xdata', nmat(j, 5)); # x-axis crossing
      set(th1, 'position', [nmat(j, 2), -0.02, 0], 'string', sprintf(' n_0 = %d ', nmat(j, 2)));
      set(th2, 'position', [nmat(j, 3), -0.02, 0], 'string', sprintf(' n_{max,1} = %d ', nmat(j, 3)));
      set(th3, 'position', [nmat(j, 5), 0.02, 0], 'string', sprintf(' n_{xc} = %d ', nmat(j, 5)));
      set(anh1, 'string', sprintf('  A = %.1f', pmat(j, 1)));
      set(anh2, 'string', sprintf('  F_1 = %.1f kHz', pmat(j, 2) / 1000));
      set(anh3, 'string', sprintf('  alpha = %.2f', pmat(j, 3)));
      set(anh4, 'string', sprintf('  beta = %.2f', pmat(j, 4)));
      set(anh5, 'string', sprintf('  gamma = %.2f', pmat(j, 5)));
      set(anh6, 'string', sprintf('  error = %.3f * 10^{-3}', emat(j, 1) * 1e3));
    endif
    ## save frame to temporary directory
    drawnow('expose');
    imwrite(getframe(fh).cdata, fullfile(mp4_tmpdir, sprintf('mp43_img%03d.png', j - 1)));
  endfor
  
  ## close figure
  close(fh);
  
  ## create MP4 video file from images
  cmd_bin = 'ffmpeg';
  cmd_fr = sprintf('-r %d', p_ap.mp4.fr);
  cmd_files = sprintf('-i %s/mp43_img%%03d.png', mp4_tmpdir);
  cmd_codec = sprintf('-vcodec %s', 'libx264');
  cmd_scale = sprintf('-vf scale=%d:-1', p_ap.mp4.res(1));
  cmd_meta1 = sprintf('-metadata title="%s"', sprintf('Semi-automated onset point picking results. Data set: %s, DOI: %s', dscode, tsdoi));
  cmd_meta2 = sprintf('-metadata author="%s"', p_ap.mp4.aut);
  cmd_meta2a = sprintf('-metadata album_artist="%s, %s"', p_ap.mp4.aut, p_ap.mp4.pub);
  cmd_meta2b = sprintf('-metadata artist="%s, %s"', p_ap.mp4.aut, p_ap.mp4.pub);
  cmd_meta3 = sprintf('-metadata date="%s"', strftime('%Y-%m-%d', localtime(time())));
  cmd_meta3a = sprintf('-metadata year="%s"', strftime('%Y', localtime(time())));
  cmd_meta4 = sprintf('-metadata comment="%s, %s. %s"', p_ap.mp4.aut, p_ap.mp4.pub, p_ap.mp4.lic);
  cmd_meta5 = sprintf('-metadata genre="%s"', 'science, ultrasonic pulse transmission method');
  cmd_meta5a = sprintf('-metadata album="%s"', 'Ultrasonic Pulse Transmission Method: Enhanced dual threshold detection method enabling fast and robust primary wave time range estimation');
  cmd_meta6 = sprintf('-metadata copyright="%s"', p_ap.mp4.cpr);
  cmd_meta7 = sprintf('-metadata description="%s"', sprintf('data set: %s, DOI: %s', dscode, tsdoi));
  cmd_meta8 = sprintf('-metadata cprt="%s"', p_ap.mp4.cpr);
  cmd_meta9 = sprintf('-metadata publisher="%s"', p_ap.mp4.pub);
  cmd_output = ofp;
  mp4_cmd = cstrcat(cmd_bin, ' ', cmd_fr, ' ', cmd_files, ' ', cmd_codec, ' ', cmd_scale, ...
    ' ', cmd_meta1, ' ', cmd_meta2, ' ', cmd_meta2a, ' ', cmd_meta2b, ' ', cmd_meta3, ' ', cmd_meta3a, ...
    ' ', cmd_meta4, ' ', cmd_meta5, ' ', cmd_meta5a, ...
    ' ', cmd_meta6, ' ', cmd_meta7, ' ', cmd_meta8, ' ', cmd_meta9, ' ', cmd_output);
  
  ## run system command (create MP4 video file)
  system(mp4_cmd);
  
  ## remove temporary files
  if not(isempty(mp4_tmpdir))
    delete(fullfile(mp4_tmpdir, 'mp43_img*.png'));
  endif
  
endfunction


function [r_ff, r_pp] = mp42_fltpsd(p_xx, p_wm, p_nz, p_fs, p_fo, p_fw, p_fr)
  ## Filter signal and estimate PSD
  ##
  ## p_xx ... signal amplitude array, [<dbl>]
  ## p_wm ... frequency measuring window, <uint>
  ## p_nz ... number of zeros, DFT zero padding, <uint>
  ## p_fs ... sampling rate, Hz, <uint>
  ## p_fo ... filter order, <uint>
  ## p_fw ... filter window type, <str>
  ## p_fr ... sensor resonance frequency, Hz, <dbl>
  ## r_ff ... return: frequency array, [<dbl>]
  ## r_pp ... return: PSD magnitude array, [<dbl>]
  
  ## filter signal
  xx = tool_flt_fir(p_xx, p_fo, p_fw);
  
  ## estimate PSD
  [ff, ~, ~, ~, ~, psd, ~] = tool_est_dft(xx(p_wm(1) : p_wm(2)), p_fs, p_nz, 'unilateral');
  
  ## limit frequency range to sensor resonance frequency
  idx_fres = find(ff >= p_fr, 1, 'first');
  r_ff = ff(1 : idx_fres) / 1000;
  r_pp = psd(1 : idx_fres);
  
endfunction