function p=v_sone2phon(s)
%V_PHON2SONE convert SONE loudness values to PHONs p=(s)
%Inputs:    s is a matrix of sone values
%
%Outputs:   p is a matrix, the same size as s, of phon values
%
% The phon scale measures perceived loudness in dB; at 1 kHz it is identical to dB SPL
% relative to 20e-6 Pa sound pressure. The sone scale is proportional to apparent loudness
% and, by definition, equals 1 at 40 phon. The form of the loudness curve is taken from [1].
% The hearing threshold at 1 kHz for 18 to 25 year olds with normal hearing is taken from [2].
%
% Refs: [1]	J. Lochner and J. Burger. Form of the loudness function in the presence of masking noise.
%           The Journal of the Acoustical Society of America, 33: 1705, 1961.
%       [2]	ISO/TC43. Acoustics, Normal equal-loudness-level contours.
%           Standard ISO 226:2003, Aug. 2003.


%      Copyright (C) Mike Brookes 2012-2013
%      Version: $Id: v_sone2phon.m 10865 2018-09-21 17:22:45Z dmb $
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
persistent a b d
if isempty(a)
    b=1/(log(10)*0.1*0.27); % 0.27 is the exponent from [1] and [2]
    d=exp(2.4/b); % 2.4 dB is teh hearing threshold from [2]
    a=exp(40/b)-d; % scale factor to make p=40 give s=1
end
if nargout>0

    p=b*log(a*s+d);
else
    if nargin<1 || isempty(s)
        pp=linspace(5,90,100)'; % phon values
        ss=v_phon2sone(pp);
    else
        ss=s;
    end
    semilogx(ss,v_sone2phon(ss));
    v_axisenlarge(-1);
    v_xticksi;
    ylabel('phon = dB SPL @ 1 kHz');
    xlabel('sone');
end
