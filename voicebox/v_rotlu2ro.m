function r=v_rotlu2ro(l,u)
%V_ROTLU2RO converts look and up directions to a rotation matrix
%  Inputs:  L(3,...)    Vector specifying look direction (need not be a unit vector)
%           U(3,...)    Vector specifying up direction. Default is u=[0 0 1]'
%                       unless l is a multiple of this, in which case u=[0 1 0]'.
%
% Outputs:  R(3,3,...)  Equivalent rotation matrix
%
% The rotation maps the look direction to the negative z-axis and the up direction
% to lie in the y-z plane with a positive y component. That is, R*L=a*[0 0 -1]' and
% R*U=b*[0 1 c] for postive constants a and b. After applying this rotation to an object,
% the 2-D data obtained by omitting the z-component represents an orthographic projection
% performed by a camera looking in the direction L.

%      Copyright (C) Mike Brookes 2023
%      Version: $Id: v_rotlu2ro.m 10865 2018-09-21 17:22:45Z dmb $
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
persistent mk
if isempty(mk)
    mk=cat(3,repmat([-1;1;-1],1,3),repmat([1;-1;-1],1,3),repmat([1;1;1],1,3),repmat([-1;-1;1],1,3));
end
sz=size(l);
l=reshape(l,3,[]);          % make 2-dimensional
n=size(l,2);                % number of rotation matrices to generate
if n==1
    r=zeros(3,3);
else
    r=zeros([3 3 sz(2:end)]);
end
if nargin<2
    u=repmat([0;0;1],1,n);
    u(2,:)=u(2,:)+(l(1,:)==0 & l(2,:)==0);
end
for i=1:n
    [q,t]=qr([l(:,i) u(:,i)]);
    rx=[cross(q(:,2),q(:,1)) q(:,2) q(:,1)]';
    r(:,:,i)=rx.*mk(:,:,2*(rx(3,:)*l(:,i)<0)+(rx(2,:)*u(:,i)<0)+1);
end
if ~nargout
    v_rotro2qr(r(:,:,1)); % plot a cube
    set(gca,'CameraPosition',[0 0 1]);
end
