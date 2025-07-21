function r=v_rotpl2ro(u,v,t)
%V_ROTPL2RO find matrix to rotate in the plane containing u and v r=[u,v,t]
% Inputs:
%
%     U(n,1) and V(n,1) define a plane in n-dimensional space
%     T is the rotation angle in radians from U towards V. If T
%       is omitted it will default to the angle between U and V
%
% Outputs:
%
%     R(n,n)   Rotation matrix

%
%      Copyright (C) Mike Brookes 2007-2018
%      Version: $Id: v_rotpl2ro.m 10865 2018-09-21 17:22:45Z dmb $
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

u=u(:);
    n=length(u);
v=v(:);
l=sqrt(u'*u);
if l==0, error('input u is a zero vector'); end
u=u/l;      % normalize
q=v-v'*u*u;        % q is orthogonal to x
l=sqrt(q'*q);
if l==0          % u and v are colinear or v=zero
    [m,i]=max(abs(u));
    q=zeros(n,1);
    q(1+mod(i(1),n))=1;  % choose next available dimension
    q=q-q'*u*u;  % q is orthogonal to x
    l=sqrt(q'*q);
end
q=q/l;          % normalize
if nargin<3
    [s,c]=v_atan2sc(v'*q,v'*u);
    r=eye(n)+(c-1)*(u*u'+q*q')+s*(q*u'-u*q');
else
    r=eye(n)+(cos(t)-1)*(u*u'+q*q')+sin(t)*(q*u'-u*q');
end
if ~nargout && n==3
    v_rotqr2ro(v_rotro2qr(r)); % plot a rotated cube
end

