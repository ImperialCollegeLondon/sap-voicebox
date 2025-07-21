function ss=v_lpczz2ss(zz)
%V_LPCZZ2SS Convert z-plane poles to s-plane poles SS=(ZZ)
%the s-plane is in units of Normalized Hz and so the imaginary part
% of each ss() value is in the range +-0.5
%
% If you multiply ss by the sample frequency, a formant with
% frequency f and bandwidth b will give an s-plane pole-pair
% of approximately -b/2 +-j*f
%
% The inverse function is zz=v_lpcss2zz(ss)


%      Copyright (C) Mike Brookes 1997
%      Version: $Id: v_lpczz2ss.m 10865 2018-09-21 17:22:45Z dmb $
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

ss=log(max(zz,1e-8))*0.5/pi;
