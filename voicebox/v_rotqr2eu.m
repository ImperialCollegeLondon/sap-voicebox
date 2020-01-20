function e=v_rotqr2eu(m,q)
%V_ROTQR2EQ converts a real unit quaternion into the corresponding euler angles
% Inputs: 
%     M        a string of n characters from the set determining the order of rotation axes
%              as listed below. Note that the control characters 'rdoOaA' may occur anywhere in the string:
%                'x','y','z'    rotate around the given axis by the corresponding angle
%                               given in e()
%                '1','2','3'    90° rotation around x,y or z axis; doesn't use a value from e()
%                '4','5','6'    180° rotation around x,y or z axis; doesn't use a value from e()
%                '7','8','9'    270° rotation around x,y or z axis; doesn't use a value from e()
%                'r','d'        all angles are given in radians or degrees  [default='r']
%                'R','D'        all angles are given in radians or degrees and are negated
%             'o','O','a','A'   selects whether to rotate the object or the coordinate axes and
%                               whether the rotation axes remain fixed in space for consecutive
%                               rotations (extrinsic) or else move with each rotation (intrinsic).
%                                  'o' = object-extrinsic [default]
%                                  'O' = object-intrinsic
%                                  'a' = axes-extrinsic
%                                  'A' = axes-intrinsic
%
%     Q(4,...) array of quaternions

%
% Outputs:
%
%     E(K,...)  K Euler angles in radians (or degrees if 'd' or 'D' specified) per quaternion where K is the number of 'xyz' characters in M.
%               A positive rotation is clockwise if looking along the +ve axis away from the origin or anti-clockwise if 'R' or 'D' is given.
%               The x, y, z axes form a right-handed triple.
%
% The string M specifies the seqeunce of axes about which the rotations are performed. There are 12
% possible 3-character sequences that avoid consecutive repetitions. These are 'Euler angles' if
% there is a repeated axis or 'Tait-Bryan angles' if not. Common choices are:
% (1) 'zxz' the most common Euler angle set
% (2) 'xyz' corresponds to 'roll, pitch, yaw' for an aeroplane heading in the x direction with y to
%     the right and z down. The intrinsic equivalent is 'Ozyx' corresponding to 'yaw, pitch, roll'.
% (3) 'z1z1z' involves 5 rotations, in which all the non-fixed rotations are around the z axis.
%
% The Euler angles are not, in general, unique. In particular:
%  (1) v_roteu2ro('zxz',[a b c]) = v_roteu2ro('zxz',[a+pi -b c+pi])
%  (2) v_roteu2ro('xyz',[a b c]) = v_roteu2ro('xyz',[a+pi pi-b c+pi])

% 
%      Copyright (C) Mike Brookes 2007-2019
%      Version: $Id: v_rotqr2eu.m 10865 2018-09-21 17:22:45Z dmb $
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
    e=v_rotro2eu(m,v_rotqr2ro(q));
else
   v_rotqr2ro(q); % draw a cube
end