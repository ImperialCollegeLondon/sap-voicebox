function [c,cr] = v_frq2cent(frq)
%V_FRQ2ERB  Convert Hertz to Cents frequency scale [C,CR]=(FRQ)
%	[c,cr] = v_frq2mel(frq) converts a vector of frequencies (in Hz)
%	to the corresponding values on the logarithmic cents scale.
%   100 cents corresponds to one semitone and 440Hz corresponds to 5700
%   cents.
%   The optional cr output gives the gradient in Hz/cent.
%
%	The relationship between cents and frq is given by:
%
%	c = 1200 * log2(f/(440*(2^((3/12)-5)))
%
%	Reference:
%
%     [1] Ellis, A.
%         On the Musical Scales of Various Nations
%         Journal of the Society of Arts, 1885, 485-527

%      Copyright (C) Mike Brookes 1998
%      Version: $Id: v_frq2cent.m 10865 2018-09-21 17:22:45Z dmb $
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
persistent p q
if isempty(p)
    p=1200/log(2);
    q=5700-p*log(440);
end
af=abs(frq);
% c = 1200*sign(frq).*log2(frq/(440*2^((3/12)-5)));
c=sign(frq).*(p*log(af)+q);
cr=af/p;
if ~nargout
    plot(frq,c,'-x');
    xlabel(['Frequency (' v_xticksi 'Hz)']);
    ylabel(['Frequency (' v_yticksi 'Cents)']);
end
