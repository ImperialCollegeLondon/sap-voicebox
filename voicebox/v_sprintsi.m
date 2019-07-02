function s=v_sprintsi(x,d,w,u)
%V_SPRINTSI Print X with SI multiplier S=(X,D,W,U)
% D is number of decimal places (+ve) or significant digits (-ve) [default=-3]
% |W| is total width including multiplier
% if W<=0 then trailing 0's will be eliminated
% U give a unit string (any initial space will be placed before the multiplier) [default ' ']
%
% Example: v_sprintsi(2345,-2) gives '2.3 k'
%V_SPGRAMBW Draw spectrogram [T,F,B]=(s,fs,mode,bw,fmax,db,tinc,ann)
%
%  Usage: (1) v_sprintsi(2345,-2) -> '2.3 k'
%         (2) v_sprintsi(2345,-2,8,' ') -> '   2.3 k' 
%         (3) v_sprintsi(2345,-2,[],'Hz') -> '2.3kHz' 
%
%  Inputs:  X        the value to print
%           D        number of decimal places (+ve) or significant digits (-ve) [default=-3]
%           W        add leading spaces so that |W| is total width including multiplier.
%                    If W<=0 then trailing 0's will be eliminated.
%           U        string giving the unit (any initial space will be placed before the multiplier)
%
% Outputs:  S        output string

%      Copyright (C) Mike Brookes 1998-2019
%      Version: $Id: v_sprintsi.m 10865 2018-09-21 17:22:45Z dmb $
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

if nargin<4
    u=' ';
end
if nargin<3 || isempty(w)
    w=0;
end
if nargin<2 || isempty(d)
    d=-3;
end
f='afpnum kMGT';
e=max(-18,min(12,floor(log10(abs(x)))));
k=floor(e/3);
dp=max([0 d 3*k-d-e-1]);
if w<=0 & dp
   w=abs(w);
   dp=max(find([1 mod(mod(round(x*10^(dp-3*k)),10^dp),10.^(dp:-1:1))]))-1;
end
if length(u)>0 && u(1)==' '
if(k)
   s=sprintf(sprintf('%%%d.%df %c%s',max(w-2,0),dp,f(k+7),u(2:end)),x*1e-3^k);
else
   s=sprintf(sprintf('%%%d.%df %s',max(w-1,0),dp,u(2:end)),x*1e-3^k);
end
else
    if(k)
   s=sprintf(sprintf('%%%d.%df%c%s',max(w-2,0),dp,f(k+7),u),x*1e-3^k);
else
   s=sprintf(sprintf('%%%d.%df%s',max(w-1,0),dp,u),x*1e-3^k);
end
end
