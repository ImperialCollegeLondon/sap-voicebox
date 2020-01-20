function e=v_rotro2eu(m,r)
%V_ROTRO2EU converts a 3x3 rotation matrix into the corresponding euler angles
% inverse of v_roteu2ro
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
%     R(3,3,...)   Input rotation matrix (or array of matrices)
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

%      Copyright (C) Mike Brookes 2007-2019
%      Version: $Id: v_rotro2eu.m 10865 2018-09-21 17:22:45Z dmb $
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
persistent mch mvch rtr rtci rtsi scai w6 th6 x6 pmw
if isempty(mvch)
    mch=''; % cached rotation code string
    mvch=[0;0;1;1;0;0;1];
    rtr=[1 4 7 2 5 8 3 6 9]; % indices to transpose a vectorized 3x3 matrix
    rtci=[2 3 5 6 8 9; 3 1 6 4 9 7; 1 2 4 5 7 8]';
    rtsi=[3 2 6 5 9 8; 1 3 4 6 7 9; 2 1 5 4 8 7]';
    scai=[0 0 0 1; 0 0 0 2; 0 0 0 3; 1 -1 0 1; 1 -1 0 2; 1 -1 0 3; 0 0 -1 1; 0 0 -1 2; 0 0 -1 3; -1 1 0 1; -1 1 0 2; -1 1 0 3]'; % [sin; -sin; cos; xyz] for fixed rotations
    w6=ones(6,1); %
    th6=3*w6;
    x6=[2 1 2 1 2 1]'; % Index for sin components
    pmw=[1; -1];
end

if ~nargout
    v_rotro2qr(r);
else
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Convert the m string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ischar(m) && strcmp(m,mch) % check if the rotation code string is cached
        mv=mvch;
    else
        mv=v_roteucode(m); % else decode the string
        mch=m; % and save the result in the cache for next time.
        mvch=mv;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now calculate euler angles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    nm=size(mv,2)-1; % number of rotation codes
    sz=size(r);
    r=reshape(r,9,[]); % vectorize the rotation matrices
    nr=size(r,2);                       % number of rotation matrices
    if mv(end)<0
        r=r(rtr,:);                     % transpose rotation matrix
    end
    e=zeros(mv(2,end),nr);              % initialize array of euler angles
    ef=mv(end-3);
    for i=nm:-1:1                       % process rotations in reverse order
        mvi=mv(:,i);
        mi=mvi(1);
        if mi<=3                        % rotation around x,y or z
            if mvi(6)~=0               % skip if this rotation is redundant
                [si,ci,ri,ti]=v_atan2sc(mvi(7)*r(mvi(4),:),mvi(7)*r(mvi(5),:));
                e(mv(2,i),:)=ti*mvi(6)/ef;  % save the euler angle
                si=mvi(6)*pmw*si;          % make -si available and correct sign
                r(rtci(:,mi),:)=ci(w6,:).*r(rtci(:,mi),:)-si(x6,:).*r(rtsi(:,mi),:); % apply reverse rotation
            end
        else % fixed rotation
            ai=scai(4,mi);                      % axis of rotation: 1, 2 or 3
            r(rtci(:,ai),:)=scai(th6,mi).*r(rtci(:,ai),:)-scai(x6,mi).*r(rtsi(:,ai),:); % apply reverse rotation
        end
    end
    if nr>1                                     % if there was >1 input matrix
        e=reshape(e,[size(e,1) sz(3:end)]);     % restore the shape of the Euler angle array
    end
end