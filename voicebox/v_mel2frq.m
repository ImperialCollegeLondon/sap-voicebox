function [frq,mr] = v_mel2frq(mel)
%V_MEL2FRQ  Convert Mel frequency scale to Hertz FRQ=(MEL)
%	frq = v_mel2frq(mel) converts a vector of Mel frequencies
%	to the corresponding real frequencies.
%   mr gives the corresponding gradients in Hz/mel.
%	The Mel scale corresponds to the perceived pitch of a tone

%	The relationship between mel and frq is given by [1]:
%
%	m = ln(1 + f/700) * 1000 / ln(1+1000/700)
%
%  	This means that m(1000) = 1000
%
%	References:
%
%     [1] J. Makhoul and L. Cosell. "Lpcw: An lpc vocoder with
%         linear predictive spectral warping", In Proc IEEE Intl
%         Conf Acoustics, Speech and Signal Processing, volume 1,
%         pages 466�469, 1976. doi: 10.1109/ICASSP.1976.1170013.
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
%      Version: $Id: v_mel2frq.m 10865 2018-09-21 17:22:45Z dmb $
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
%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
persistent k
if isempty(k)
    k=1000/log(1+1000/700); % 1127.01048
end
frq=700*sign(mel).*(exp(abs(mel)/k)-1);
mr=(700+abs(frq))/k;
if ~nargout
    plot(mel,frq,'-x');
    xlabel(['Frequency (' v_xticksi 'Mel)']);
    ylabel(['Frequency (' v_yticksi 'Hz)']);
end
