function y=v_qrpermute(x,p)
%V_QRPERMUTE transpose or permute a quaternion array y=[x,p]
%
% Inputs:   x(4m,...)  Real quaternions array
%           p          new order of dimensions [default [2 1 ...]
%
% Outputs:  y(4n,...)  output real quaternion array

%      Copyright (C) Mike Brookes 2012
%      Version: $Id: v_qrpermute.m 10865 2018-09-21 17:22:45Z dmb $
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
s=size(x);
if nargin<2
    p=[2 1 3:length(s)];
end
s(1)=s(1)/4;
t=s(p);
t(1)=4*t(1);
y=reshape(permute(reshape(x,[4 s]),[1 p+1]),t);