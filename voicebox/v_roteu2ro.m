function r=v_roteu2ro(varargin)
%V_ROTEU2QR converts a sequence of Euler angles to a real unit quaternion
% Inputs:
%
%     M        a string of n characters from the set determining the order of rotation axes
%              as listed below:
%                'x','y','z'    rotate around the given axis by the corresponding angle
%                               given in e()
%                '1','2','3'    90° rotation around x,y or z axis; doesn't use a value from e()
%                '4','5','6'    180° rotation around x,y or z axis; doesn't use a value from e()
%                '7','8','9'    270° rotation around x,y or z axis; doesn't use a value from e()
%                'r','d'        all angles are given in radians or degrees  [radians]
%             'o','O','a','A'   selects whether to rotate the object ('o','O') or the coordinate
%                               axes ('a','A') and whether the rotation axes remain fixed in
%                               space for consecutive rotations (extrinsic: 'o','a') or else move
%                               with each rotation (intrinsic: 'O','A').
%                               The default is 'o' = object-extrinsic.
%
%     E(n,...) column vector of rotation angles in radians (or degrees if 'd' specified).
%              A positive rotation is clockwise if looking along the axis away from the origin.
%
% Outputs:
%
%     R(3,3,...)   Input rotation matrix
%              Plots a diagram if no output specified
%
% The string M specifies the axes about which the rotations are performed.
% You cannot have the same axis in adjacent positions and so there are 12
% 3-character possibilities. Common ones are "ZXZ" and "ZYX". A positive rotation
% is clockwise if looking along the axis away from the origin; thus a rotation
%  of +pi/2 around Z (i.e. '3' in m) rotates [1 0 0]' to [0 1 0]'.
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
    r=v_rotqr2ro(v_roteu2qr(varargin{:}));
else
    v_rotqr2ro(v_roteu2qr(varargin{:})); % draw a cube
end