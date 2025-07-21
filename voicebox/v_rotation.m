function [r,p,q]=v_rotation(x,y,z)
%V_ROTATION Encode and decode rotation matrices
% (1) r=v_rotation(x,y,angle) creates a matrix that rotates vectors in the
%     plane containing x and y. A small positive angle moves x towards y.
% (2) [x,y,ang]=v_rotation(r) is the inverse of (1) above. The input argument r
%     is assumed to be a rotation matrix: little error checking is done.
% (3) r=v_rotation(axis,angle)=v_rotation(axis*ang) only works for a 3-dimensional
%     vector axis and creates a rotation of angle radians around axis.
% (4) [axis,ang]=v_rotation(r) is the inverse of (3) above for a 3x3 input matrix r

%      Copyright (C) Mike Brookes 1998
%      Version: $Id: v_rotation.m 10865 2018-09-21 17:22:45Z dmb $
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

l=length(x(:));
if nargin>2
   x=x(:); x=x/sqrt(x'*x);
   y=y(:); y=y-y'*x*x; y=y/sqrt(y'*y);
   r=eye(l)+(cos(z)-1)*(x*x'+y*y')+sin(z)*(y*x'-x*y');
elseif l==3
   x=x(:);
   lx=sqrt(x'*x);
   if nargin==1
      y=lx;
   end
   x=x/lx;
   xx=x*x';
   s=zeros(3,3);
   s([6 7 2])=x;
   s([8 3 4])=-x;
   r=xx+cos(y)*(eye(3)-xx)+sin(y)*s;
else
   [v,d]=eig(x);
   [e,j]=sort(real(diag(d)));
   j1=j(1);
   an=angle(d(j1,j1));
   q=an;
   sq=sqrt(2);
   r=imag(v(:,j1))*sq;
   if r==0
      p=v(:,j1);
      r=v(:,j(2));
   else
      p=real(v(:,j1))*sq;
   end
   if nargout==2
      r=cross(r,p);
      p=an;
   end
end