## Plot signal model
##
## Usage: algo_sigmod()
##
## see also: algo_param.m
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
function algo_sigmod()
  
  ## load analysis parameters structure
  ap = algo_param();
  
  ## generate signal
  [ss, nn, Ns] = tool_gen_signal(Fs = 1e7, Ncy = 1, modelparm = ap.sig.mpar);
  [vmax, nmax] = max(ss); # maximum point
  [vxc, nxc] = find(ss(nmax : end) < 0, 1, 'first'); nxc = nxc + nmax - 2; # first x-axis crossing point
  
  ## plot signal model
  [fh, ah] = tool_plot_create_figure(6, 'Signal model', false);
  set(fh, 'position', [100, 100, 700, 700*0.62]);
  hold(ah, 'on');
  plot(ah, nn([1, end]), [0, 0], 'color', [1, 1, 1] * 0.5, 'handlevisibility', 'off');
  plot(ah, nn, ss, '-k', 'linewidth', 2, 'displayname', 's[n]');
  plot(ah, nmax, vmax, 'ok', 'handlevisibility', 'off', 'linewidth', 1, 'markersize', 5);
  plot(ah, nmax, 0, 'ok', 'handlevisibility', 'off', 'linewidth', 1, 'markersize', 5);
  plot(ah, nxc, 0, 'ok', 'handlevisibility', 'off', 'linewidth', 1, 'markersize', 5);
  plot(ah, 0, 0, 'ok', 'handlevisibility', 'off', 'linewidth', 1, 'markersize', 5);
  plot(ah, [1, 1] * nmax, [0, 1], ':k', 'handlevisibility', 'off', 'linewidth', 1);
  text(ah, nmax, -0.02, sprintf(' n_{max,1} = %d', nmax), 'horizontalalignment', 'left', 'verticalalignment', 'top');
  text(ah, nxc, 0.02, sprintf(' n_{xc} = %d', nxc), 'horizontalalignment', 'left', 'verticalalignment', 'bottom');
  text(ah, 0, -0.02, ' n_0 = 0', 'horizontalalignment', 'left', 'verticalalignment', 'top');
  ## parameter
  text(ah, 10, -0.2, sprintf(' A = %.2f', ap.sig.mpar(1)), 'horizontalalignment', 'left');
  text(ah, 10, -0.3, sprintf(' F_1 = %.2f kHz', ap.sig.mpar(2) / 1000), 'horizontalalignment', 'left');
  text(ah, 10, -0.4, sprintf(' alpha = %.2f', ap.sig.mpar(3)), 'horizontalalignment', 'left');
  text(ah, 10, -0.5, sprintf(' beta = %.2f', ap.sig.mpar(4)), 'horizontalalignment', 'left');
  text(ah, 10, -0.6, sprintf(' gamma = %.2f', ap.sig.mpar(5)), 'horizontalalignment', 'left');
  text(ah, 10, -0.7, sprintf(' N_{cycle} = %d', Ncy), 'horizontalalignment', 'left');
  text(ah, 10, -0.8, sprintf(' Fs = %d MHz', Fs / 1e6), 'horizontalalignment', 'left');
  hold(ah, 'off');
  tool_plot_axes_annotate(ah, {'Sample index', '1'}, {'Amplitude, norm.', '1'}, 'Signal model', []);
  legend(ah, 'location', 'northwest', 'box', 'off');
  xlim(ah, [-100, nn(end)+50]);
  
  ## save results
  ofp1 = fullfile(ap.rpath_algo_sigfit, 'fig', 'signal_model.ofig');
  ofp2 = fullfile(ap.rpath_algo_sigfit, 'png', 'signal_model.png');
  hgsave(fh, ofp1);
  saveas(fh, ofp2);
  close(fh);
  
endfunction
