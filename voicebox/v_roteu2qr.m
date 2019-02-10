function q=v_roteu2qr(m,e)
%ROTEU2QR converts a sequence of Euler angles to a real unit quaternion
% Inputs:
%
%     M        a string of n characters from the set determining the order of rotation axes
%              as listed below:
%                'x','y','z'    rotate around the given axis by the corresponding angle
%                               given in e()
%                '1','2','3'    90� rotation around x,y or z axis; doesn't use a value from e()
%                '4','5','6'    180� rotation around x,y or z axis; doesn't use a value from e()
%                '7','8','9'    270� rotation around x,y or z axis; doesn't use a value from e()
%                'r','d'        all angles are given in radians or degrees  [radians]
%             'o','O','a','A'   selects whether to rotate the object or the coordinate axes and
%                               whether the rotation axes remain fixed in space for consecutive
%                               rotations (extrinsic) or else move with each rotation (intrinsic).
%                                  'o' = object-extrinsic [default]
%                                  'O' = object-intrinsic
%                                  'a' = axes-extrinsic
%                                  'A' = axes-intrinsic
%
%     E(n,...) column vector of rotation angles in radians (or degrees if 'd' specified).
%              A positive rotation is clockwise if looking along the +ve axis away from the origin.
%              The x, y, z axes form a right-handed triple.
%
% Outputs:
%
%     Q(4,...)   output quaternion. Q is normalized to have magnitude 1 with
%                its first non-zero coefficient positive.
%
% The string M specifies the seqeunce of axes about which the rotations are performed. There are 12
% possible 3-character sequences that avoid consecutive repetitions. These are 'Euler angles' if
% there is a repeated axis or 'Tait-Bryan angles' if not. Common choices are:
% (1) 'zxz' the most common Euler angle set (including a replicated axis, z)
% (2) 'xyz' corresponds to 'roll, pitch, yaw' for an aeroplane heading in the x direction with y to
%     the right and z down. The intrinsic equivalent is 'Ozyx' corresponding to 'yaw, pitch, roll'.
% (3) 'z1z1z' involves 5 rotations, in which all the non-fixed rotations are around the z axis. 
%
% Inverse conversion: If m has length 3 with adjacent characters distinct,
%                     then v_rotqr2eu(m,v_roteu2qr(m,e))=e.
%
% Inverse rotation:   qrmult(roteu2qr(m,e),roteu2qr(fliplr(m),-fliplr(e)))=+-[ 1 0 0 0]'

%
%      Copyright (C) Mike Brookes 2007-2018
%      Version: $Id: v_roteu2qr.m 10865 2018-09-21 17:22:45Z dmb $
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
persistent y cb sb
if isempty(y)
    y=repmat([2 4 1 3 1 3 2 4; 3 2 1 4 1 4 3 2; 3 4 2 1 1 2 4 3],4,1);
    cb=cos([0 0 0 1 1 1 2 2 2 3 3 3]*pi/4);
    sb=sin([0 0 0 1 1 1 2 2 2 3 3 3]*pi/4);
end
% m consists of a sequence of axes e.g. 'zxy'
% and e gives the rotation angles in radians or degrees
if ischar(m)
    m=m-'w'; % convert to integers for backwards compatibiity
end
mi=m>=-31 & m<=-29; % convert XYZ to xyz
m(mi)=m(mi)+32;
mi=m>=-70 & m<=-62; % find digits 1:9
m(mi)=m(mi)+74; % convert to 4:12
mi=m<=0; % select control characters
mc=m(mi); % controls
m=m(~mi); % rotations
ef=0.5; % angle scale factor
es=1; % angle sign
fl=0; % need to flip rotation order
for i=1:length(mc)
    switch mc(i)
        case -5 % 'r' = radians
        case -19 % 'd' = degrees
            ef=pi/360; % scale factor to convert to radians and halve
        case -8 % 'o' = object-extrinsic
        case -40 % 'O' = object-intrinsic
            fl=1;
        case -22 % 'a' = axes-extrinsic
            fl=1;
            es=-1;
        case -54 % 'A' = axes-intrinsic
            es=-1;
        otherwise
            error('Invalid character: %s',mc(i)+'w')
    end
end
ne=sum(m<=3); % number of elements required in e per output
if ne==0
    ne=1;
    sz=[1 1];
    nq=1;
    e=[]; % create a dummy e in case it wasn't specified
else
    sz=size(e);
    if sz(1)==1 && numel(e)==ne % allow legacy call with row-vector input
        e=e(:);
        sz=size(e);
    else
        e=reshape(e,sz(1),[]); % put each set of angles in a separate column
    end
    nq=size(e,2);
end
q=zeros(4,nq);
q(1,:)=1; % initialize output quaternions to the value 1
r=q; % space for temporary quaternion
j=0; % number of angles used so far
if fl
    m=m(end:-1:1); % reverse the order of m
    e=e(end:-1:1,:); % and of e
end
for i=1:length(m)
    mi=m(i);
    x=y(mi,:); % index for x,y,or z axes
    if mi<4
        j=j+1; % next angle required
        b=ef*e(j,:); % rotation semi-angle in radians
        c=cos(b);
        s=sin(b);
    else
        c=cb(mi);
        s=sb(mi);
    end
    r(x(1:2),:)=q(x(3:4),:);
    r(x(5:6),:)=-q(x(7:8),:);
    q=repmat(c,4,1).*q+repmat(s*es,4,1).*r;
end
if ~nargout
    v_rotqr2ro(q(:,1)); % plot a cube
else
    sz(1)=4; % each rotation needs 4 outputs
    q=reshape(q.*repmat(sign([8 4 2 1]*sign(q)),4,1),sz); % force leading coefficient to be positive and reshape
end