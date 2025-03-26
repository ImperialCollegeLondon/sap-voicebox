function zz=v_lpcss2zz(ss,nreal)
%V_LPCSS2ZZ Convert s-plane poles to z-plane poles ZZ=(SS)
% the s-plane is in units of Normalized Hz and so the imaginary part
% of each ss() value should be in the range +-0.5
%
% If you multiply ss by the sample frequency, a formant with
% frequency f and bandwidth b will give an s-plane pole-pair
% of approximately -b/2 +-j*f
%
% The second [optional] argument gives then number of real s-plane poles.
% If this argument is given, then ss will be replaced
% by [ss(:,1:nreal) ss(:,nreal+1:end) conj(ss(:,nreal+1:end))].
%
% The inverse function is zz=v_lpczz2ss(zz)

%      Copyright (C) Mike Brookes 1997
%      Version: $Id: v_lpcss2zz.m 10865 2018-09-21 17:22:45Z dmb $
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
if nargin>1 && nreal<size(ss,2)
    ss=[real(ss(:,1:nreal)) ss(:,nreal+1:end) conj(ss(:,nreal+1:end))];
end
zz=exp(2*pi*ss);

