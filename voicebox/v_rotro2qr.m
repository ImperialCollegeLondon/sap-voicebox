function q=v_rotro2qr(r)
%V_ROTRO2QR converts a 3x3 rotation matrix to a real quaternion
% Inputs:
%
%     R(3,3,...)   Input rotation matrix
%
% Outputs:
%
%     Q(4,...)   normalized real-valued quaternion
%
% In the quaternion representation of a rotation, and q(1) = cos(t/2)
% where t is the angle of rotation in the range 0 to 2pi
% and q(2:4)/sin(t/2) is a unit vector lying along the axis of rotation
% a positive rotation about [0 0 1] takes the X axis towards the Y axis.

%      Copyright (C) Mike Brookes 2007-2018
%      Version: $Id: v_rotro2qr.m 10865 2018-09-21 17:22:45Z dmb $
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

% in the comments below, t is the rotation angle, a is the rotation axis
sz=size(r);
r=reshape(r,9,[]); % make 2-dimensional
q=zeros(4,size(r,2));
d = 1+r(1,:)+r(5,:)+r(9,:);     % 2(1+cos(t)) = 4(cos(t/2))^2 = 4 q(1)^2
mm=d>1; % mask for rotation angles < 120 degrees
if any(mm)                       % for rotation angles less than 120 degrees
    s = sqrt(d(mm))*2;            % 4 cos(t/2) = 2 sin(t)/sin(t/2)
    q(2,mm) = (r(6,mm)-r(8,mm))./s;
    q(3,mm) = (r(7,mm)-r(3,mm))./s;
    q(4,mm) = (r(2,mm)-r(4,mm))./s;
    q(1,mm) = 0.25*s;            % cos(t/2)
end
if any(~mm)
    m=(r(1,:)>r(5,:)) & (r(1,:)>r(9,:)) & ~mm;
    if any(m)
        s  = sqrt( 1.0+r(1,m)-r(5,m)-r(9,m))*2;  % s>=2 always: s=4 a(1) sin(t/2) = 2 a(2) (1-cos(t))/sin(t/2)
        q(2,m) = 0.25*s;
        q(3,m) = (r(2,m)+r(4,m))./s;
        q(4,m) = (r(7,m)+r(3,m))./s;
        q(1,m) = (r(6,m)-r(8,m))./s;
        mm=mm|m;
    end
    m=(r(5,:)>r(9,:)) & ~mm;
    if any(m)
        s  = sqrt( 1.0+r(5,m)-r(1,m)-r(9,m))*2; % s>=2 always: s=4 a(2) sin(t/2)
        q(2,m) = (r(2,m)+r(4,m))./s;
        q(3,m) = 0.25*s;
        q(4,m) = (r(6,m)+r(8,m))./s;
        q(1,m) = (r(7,m)-r(3,m))./s;
        mm=mm|m;
    end
    if any(~mm)
        m=~mm;
        s  = sqrt( 1.0+r(9,m)-r(1,m)-r(5,m))*2;  % s>=2 always: s=4 a(3) sin(t/2)
        q(2,m) = (r(7,m)+r(3,m))./s;
        q(3,m) = (r(6,m)+r(8,m))./s;
        q(4,m) = 0.25*s;
        q(1,m) = (r(2,m)-r(4,m))./s;
    end
end
if max(abs(sum(q.^2,1)-1))>1e-8; % check normalization
    error('Input to rotro2qr must be a rotation matrix with det(r)=+1');
end
if length(sz)<3
    sz=[4 1];
else
    sz=[4 sz(3:end)];
end
q=reshape(q.*repmat(sign([8 4 2 1]*sign(q)),4,1),sz); % force leading coefficient to be positive and reshape
if ~nargout
    v_rotqr2ro(q); % plot a cube
end
