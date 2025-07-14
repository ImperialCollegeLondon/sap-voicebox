function [m,q]=v_qrabs(q1)
%V_QRABS absolute value and normalization of a real quaternions [m,q]=[q1]
%
% Inputs:   q1(4n,...)  A real quaternion array. Each quaternion is a column
%                          vector of the form [r, i, j, k]'
%
% Outputs:  m(n,...)    Array of quaternion magnitudes: m=sqrt(q'*q)
%           q(4n,...)   Normalized version of q1 with unit magnitude
%                          a zero quaternion is normalized to [1 0 0 0]'

%      Copyright (C) Mike Brookes 2000-2012
%      Version: $Id: v_qrabs.m 10865 2018-09-21 17:22:45Z dmb $
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
q1=randn(8,3);
q1(9:12)=0;
s=size(q1);
q=reshape(q1,4,[]);
m=sqrt(sum(q.^2,1));
q(:,m>0)=q(:,m>0)./m(ones(4,1),m>0);
q(1,m<=0)=1;
q=reshape(q,s);
s(1)=s(1)/4;
m=reshape(m,s);
