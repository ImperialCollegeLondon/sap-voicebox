function r=v_roteu2ro(m,t)
%V_ROTEU2QR converts a sequence of Euler angles to a real unit quaternion
% Inputs:
%
%     M(1,n)   a string of n characters from the set {'x','y','z'}
%              or, equivalently, a vector whose elements are 1, 2, or 3
%     T(n,1)   n rotation angles. A positive rotation is clockwise if
%              looking along the axis away from the origin.
%
% Outputs:
%
%     R(3,3)   Input rotation matrix
%              Plots a diagram if no output specified
%
% The string M specifies the axes about which the rotations are performed.
% You cannot have the same axis in adjacent positions and so there are 12
% possibilities. Common ones are "ZXZ" and "ZYX". A positive rotation is clockwise
% if looking along the axis away from the origin; thus a rotation of +pi/2
% around Z rotates [1 0 0]' to [0 1 0]'.
%
% Inverse conversion: If m has length 3 with adjacent characters distinct,
%                     then v_rotro2eu(m,v_roteu2ro(m,t))=t.
%
% Inverse rotation:   v_roteu2ro(m,t)*v_roteu2ro(fliplr(m),-fliplr(t))=eye(3)

%
%      Copyright (C) Mike Brookes 2007-2018
%      Version: $Id: v_roteu2ro.m 10865 2018-09-21 17:22:45Z dmb $
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
if nargout
    r=v_rotqr2ro(v_roteu2qr(m,t));
else
    v_rotqr2ro(v_roteu2qr(m,t)); % draw a cube
end