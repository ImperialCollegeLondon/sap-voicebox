function [b,a]=v_potsband(fs)
%V_POTSBAND Design filter for 300-3400 telephone bandwidth [B,A]=(FS)
%
%Input: FS=sample frequency in Hz
%
%Output: B/A is a discrete time bandpass filter with a passband gain of 1
%
%The filter meets the specifications of G.151 for any sample frequency
%and has a gain of -3dB at the passband edges.


%      Copyright (C) Mike Brookes 1998
%      Version: $Id: v_potsband.m 10865 2018-09-21 17:22:45Z dmb $
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

szp=[0.19892796195357i; -0.48623571568937+0.86535995266875i]; 
szp=[[0; -0.97247143137874] szp conj(szp)];
% s-plane zeros and poles of high pass 3'rd order chebychev2 filter with -3dB at w=1
zl=2./(1-szp*tan(300*pi/fs))-1;
al=real(poly(zl(2,:)));
bl=real(poly(zl(1,:)));
sw=[1;-1;1;-1];
bl=bl*(al*sw)/(bl*sw);
zh=2./(szp/tan(3400*pi/fs)-1)+1;
ah=real(poly(zh(2,:)));
bh=real(poly(zh(1,:)));
bh=bh*sum(ah)/sum(bh);
b=conv(bh,bl);
a=conv(ah,al);