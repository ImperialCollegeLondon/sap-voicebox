function [mel,mr] = v_frq2mel(frq)
%V_FRQ2MEL  Convert Hertz to Mel frequency scale MEL=(FRQ)
%
% Usage: (1) v_frq2mel(-20000:400:20000); % plot Mel and Mel-rate versus frequency 
%
%  Input:   frq     Scalar, vector or matrix of frequency values in Hz
%
% Outputs:  mel     Corresponding values in Mel (same shape as frq)
%           mr      Corresponding gradients in Hz/Mel (linear function of frequency)
%
%	The Mel scale corresponds to the perceived pitch of a pure tome. The relationship
%   between mel and frq is given by [1]:
%
%	            m = ln(1 + f/700) * 1000 / ln(1+1000/700)
%
%  	This means that m(1000) = 1000
%
%	References:
%
%     [1] J. Makhoul and L. Cosell. "Lpcw: An lpc vocoder with
%         linear predictive spectral warping", In Proc IEEE Intl
%         Conf Acoustics, Speech and Signal Processing, volume 1,
%         pages 466-469, 1976. doi: 10.1109/ICASSP.1976.1170013.
%	  [2] S. S. Stevens & J. Volkman "The relation of pitch to
%		  frequency", American J of Psychology, V 53, p329 1940
%	  [3] C. G. M. Fant, "Acoustic description & classification
%		  of phonetic units", Ericsson Tchnics, No 1 1959
%		  (reprinted in "Speech Sounds & Features", MIT Press 1973)
%	  [4] S. B. Davis & P. Mermelstein, "Comparison of parametric
%		  representations for monosyllabic word recognition in
%		  continuously spoken sentences", IEEE ASSP, V 28,
%		  pp 357-366 Aug 1980
%	  [5] J. R. Deller Jr, J. G. Proakis, J. H. L. Hansen,
%		  "Discrete-Time Processing of Speech Signals", p380,
%		  Macmillan 1993

%      Copyright (C) Mike Brookes 1998
%      Version: $Id: v_frq2mel.m 10865 2018-09-21 17:22:45Z dmb $
%
%   VOICEBOX is a MATLAB toolbox for speech processing.
%   Home page: http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/voicebox.html
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This program is free software; you can redistribute it and/or modify
%   it under the terms of the GNU Lesser General Public License as published by
%   the Free Software Foundation; either version 3 of the License, or
%   (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU Lesser General Public License for more details.
%
%   You can obtain a copy of the GNU Lesser General Public License from
%   https://www.gnu.org/licenses/ .
%    See files gpl-3.0.txt and lgpl-3.0.txt included in this distribution.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
persistent k c kr logkcr
if isempty(k)
    c=700;                              % corner frequency in Hz
    k=1000/log(1+1000/c);               % useful constant: 1127.01048
    kr=1/k;
    logkcr=log(k/c);
end
mr=kr*(c+abs(frq));                     % Mel rate in Hz/Mel
mel=sign(frq).*(log(mr)+logkcr)*k;
if ~nargout
    subplot(2,1,2);
    plot(frq,mr,'-x');
    xlabel(['Frequency (' v_xticksi 'Hz)']);
    ylabel(['Mel-Rate (' v_yticksi 'Hz/Mel)']);
    subplot(2,1,1);
    plot(frq,mel,'-x');
    xlabel(['Frequency (' v_xticksi 'Hz)']);
    ylabel(['Mel-Freq (' v_yticksi 'Mel)']);
end
