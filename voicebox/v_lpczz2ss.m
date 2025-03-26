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
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation; either version 2 of the License, or
%   (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You can obtain a copy of the GNU General Public License from
%   http://www.gnu.org/copyleft/gpl.html or by writing to
%   Free Software Foundation, Inc.,675 Mass Ave, Cambridge, MA 02139, USA.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ss=log(max(zz,1e-8))*0.5/pi;
