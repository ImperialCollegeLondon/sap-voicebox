function [u,v,t]=v_rotro2pl(r)
%V_ROTRO2PL find the plane and rotation angle of a rotation matrix [u,v,t]=r
% Inputs:
%
%     R(n,n)   Rotation matrix
%
% Outputs:
%
%     U(n,1) and V(n,1) are orthonormal vectors defining a plane in n-dimensional space
%     T is the rotation angle in radians from U towards V with 0<=T<=pi. If T
%       is omitted it U and V will be separated by T instead of being orthogonal

%
%      Copyright (C) Mike Brookes 2007-2018
%      Version: $Id: v_rotro2pl.m 10865 2018-09-21 17:22:45Z dmb $
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

n=size(r,1);
[q,e]=schur(r);
[m,i]=max(abs(e(2:n+1:n^2)));
z=e(i+1,i)<0; % =1 if negative
uv=q(:,i+z:1-2*z:i+1-z);
u=uv(:,1);
% the following code selects unique values of u and v
% v=uv(:,2);
% f=u.*v;         % maximize inner product of u.^2 and v.^2
% g=(v+u).*(v-u);
% t=atan2(sum(f.*g),sum(g.^2/4-f.^2))/4;
% c=cos(t);
% s=sin(t);
% uv=uv*[c s; -s c];
% a=sum(uv)<0;
% uv=uv*[1-a(1)-a(2) a(2)-a(1); a(1)-a(2) 1-a(1)-a(2)];
% u=uv(:,1);
if nargout>2
    v=uv(:,2);
    t=atan2(abs(e(i+1,i)),e(i,i));
elseif nargout
    [s,c]=v_atan2sc(abs(e(i+1,i)),e(i,i));
    v=uv*[c;s];
elseif n==3 % if a 3D rotation
    v_rotqr2ro(v_rotro2qr(r)); % plot a rotated cube
end
