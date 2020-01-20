function mv=v_roteucode(m)
%V_ROTEUCODE decodes a string specifying a rotation axis sequence
%     M(n)     a string of n characters from the set determining the order of rotation axes
%              as listed below. Note that the control characters 'rdoOaA' may occur anywhere in the string:
%                'x','y','z'    rotate around the given axis by the corresponding angle
%                               given in e()
%                '1','2','3'    90° rotation around x,y or z axis; doesn't use a value from e()
%                '4','5','6'    180° rotation around x,y or z axis; doesn't use a value from e()
%                '7','8','9'    270° rotation around x,y or z axis; doesn't use a value from e()
%                'r','d'        all angles are given in radians or degrees  [radians]
%             'o','O','a','A'   selects whether to rotate the object or the coordinate axes and
%                               whether the rotation axes remain fixed in space for consecutive
%                               rotations (extrinsic) or else move with each rotation (intrinsic).
%                                  'o' = object-extrinsic [default]
%                                  'O' = object-intrinsic
%                                  'a' = axes-extrinsic
%                                  'A' = axes-intrinsic
% Outputs:
%
%     mv(7,k)    where k-1 is the number of non-control characters in the input string m
%                    mv(1,j) = Code for the j'th rotation: 1,2,3 for x,y,z rotation and 4 to 12 for the fixed rotations listed above.
%                              All entries are in the range [1,12] except for mv(1,k)=0.
%                    mv(2,j) = index into euler angle array for x,y,z rotations. mv(2,k) gives total number of euler angles needed
%                    mv(3,j) = rotation class before rotation j. mv(3,k) is the final rotation class and equals 52 for arbitrary rotations.
%                    mv(4,j) = index into a vectorized matrix of the entry that becomes non-zero after rotation j
%                    mv(5,j) = index into a vectorized matrix of the other changing element in the same column
%                    mv(6,j) = +-1 = sign of the sine term affecting entry mv(4,j). For mv(1,j) in [1,3], mv(6,j)=0 if the rotation is unnecessary
%                    mv(7,j) = +-1 = sign of entry mv(5,j) before rotation j if known
%                Special entries:
%                    mv(7,k) = -1 to invert the rotation (i.e. transpose the matrix) or +1 otherwise
%                    mv(4,k) = scale factor for euler angles: +-1 or +-pi/180
%      
%
% The string M specifies the seqeunce of axes about which the rotations are performed. There are 12
% possible 3-character sequences that avoid consecutive repetitions. These are 'Euler angles' if
% there is a repeated axis or 'Tait-Bryan angles' if not. Common choices are:
% (1) 'zxz' the most common Euler angle set
% (2) 'xyz' corresponds to 'roll, pitch, yaw' for an aeroplane heading in the x direction with y to
%     the right and z down. The intrinsic equivalent is 'Ozyx' corresponding to 'yaw, pitch, roll'.
% (3) 'z1z1z' involves 5 rotations, in which all the non-fixed rotations are around the z axis.
%

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

persistent mes trmap zel mch mvch  jch nch
if isempty(mes)     % setup fixed arrays and initialize cache of mode strings
    nch=5;          % size of cache
    mch=cell(nch,1); % cache of input character strings
    mvch=cell(nch,1);  % cache of output mv codes
    flefch=zeros(nch,2);  % cache of output flef codes
    jch=(1:nch); % cache usage order jch(1) is the most recent, jch(nch) the oldest
    for i=1:nch
        mch{i}='';
        mvch{i}=[0;0;1;1;0;0;1];
    end
    mes=[1:3 10:12 7:9 4:6]; % sign reversal look-up table
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % The trmap and zel arrays contain information about each of 52 different  %
    % patterns of -1,0,+1 that may exist in a rotation matrix as follows:      %
    %                                                                          %
    %   1-3 : identity matrix rows in order: 123, 231, 312                     %
    %   4-6 : negated identity matrix rows in order: 132, 213, 321             %
    %   7-12: As 1-6 but with rows 2,3 negated                                 %
    %  13-18: As 1-6 but with rows 1,3 negated                                 %
    %  19-24: As 1-6 but with rows 1,2 negated                                 %
    %  25-33: +1 in position (i-24) and 0's in remainder of this row and col   %
    %  34-42: -1 in position (i-24) and 0's in remainder of this row and col   %
    %  43-51: 0 in position (i-42)                                             %
    %  52: no special symmetry                                                 %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % trmap(i,j) gives the pattern that i is transformed into by rotation j    %
    % where j=1:3 corresponds to x,y,z and j=4:12 corresponds to the 9         %
    % multiples of 90° rotations listed in the main comments.                  %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    trmap=[ 25 29 33 16 24 11  7 13 19 22 12 17;
        28 32 27 17 22 12  8 14 20 23 10 18;
        31 26 30 18 23 10  9 15 21 24 11 16;
        34 41 39 13 20  9 10 16 22 19  8 15;
        37 35 42 14 21  7 11 17 23 20  9 13;
        40 38 36 15 19  8 12 18 24 21  7 14;
        25 38 42 22  6 23  1 19 13 16 18  5;
        28 41 36 23  4 24  2 20 14 17 16  6;
        31 35 39 24  5 22  3 21 15 18 17  4;
        34 32 30 19  2 21  4 22 16 13 14  3;
        37 26 33 20  3 19  5 23 17 14 15  1;
        40 29 27 21  1 20  6 24 18 15 13  2;
        34 29 42 10 12  5 19  1  7  4 24 23;
        37 32 36 11 10  6 20  2  8  5 22 24;
        40 26 39 12 11  4 21  3  9  6 23 22;
        25 41 30  7  8  3 22  4 10  1 20 21;
        28 35 33  8  9  1 23  5 11  2 21 19;
        31 38 27  9  7  2 24  6 12  3 19 20;
        34 38 33  4 18 17 13  7  1 10  6 11;
        37 41 27  5 16 18 14  8  2 11  4 12;
        40 35 30  6 17 16 15  9  3 12  5 10;
        25 32 39  1 14 15 16 10  4  7  2  9;
        28 26 42  2 15 13 17 11  5  8  3  7;
        31 29 36  3 13 14 18 12  6  9  1  8;
        25 44 45 25 36 26 25 34 34 25 27 35;
        43 26 45 27 26 34 35 26 35 36 26 25;
        43 44 27 35 25 27 36 36 27 26 34 27;
        28 47 48 28 39 29 28 37 37 28 30 38;
        46 29 48 30 29 37 38 29 38 39 29 28;
        46 47 30 38 28 30 39 39 30 29 37 30;
        31 50 51 31 42 32 31 40 40 31 33 41;
        49 32 51 33 32 40 41 32 41 42 32 31;
        49 50 33 41 31 33 42 42 33 32 40 33;
        34 44 45 34 27 35 34 25 25 34 36 26;
        43 35 45 36 35 25 26 35 26 27 35 34;
        43 44 36 26 34 36 27 27 36 35 25 36;
        37 47 48 37 30 38 37 28 28 37 39 29;
        46 38 48 39 38 28 29 38 29 30 38 37;
        46 47 39 29 37 39 30 30 39 38 28 39;
        40 50 51 40 33 41 40 31 31 40 42 32;
        49 41 51 42 41 31 32 41 32 33 41 40;
        49 50 42 32 40 42 33 33 42 41 31 42;
        43 52 52 43 45 44 43 43 43 43 45 44;
        52 44 52 45 44 43 44 44 44 45 44 43;
        52 52 45 44 43 45 45 45 45 44 43 45;
        46 52 52 46 48 47 46 46 46 46 48 47;
        52 47 52 48 47 46 47 47 47 48 47 46;
        52 52 48 47 46 48 48 48 48 47 46 48;
        49 52 52 49 51 50 49 49 49 49 51 50;
        52 50 52 51 50 49 50 50 50 51 50 49;
        52 52 51 50 49 51 51 51 51 50 49 51;
        52 52 52 52 52 52 52 52 52 52 52 52];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Each Euler angle is chosen so that the inverse rotation forces a specific element  %
    % of the rotation matrix to zero. zel(k,j,i) gives information about which element   %
    % ceases to be zero when a rotation around axis j is applied to pattern i.           %
    %    k=1 gives the index into a vectorized matrix of the entry that becomes non-zero %
    %    k=2 gives the index of the other element in the same column that changes        %
    %    k=3 gives the sign of the sine term affecting the first of these entries        %
    %    k=4 gives the sign of the initial value of the second of these entries if known %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    zel=reshape([  6  5  1  1  3  1 -1  1  2  1  1  1;
        2  3 -1  1  1  3  1  1  5  4  1  1;
        3  2  1  1  4  6  1  1  1  2 -1  1;
        5  6 -1 -1  3  1 -1 -1  2  1  1 -1;
        3  2  1 -1  6  4 -1 -1  1  2 -1 -1;
        2  3 -1 -1  1  3  1 -1  4  5 -1 -1;
        6  5  1 -1  3  1 -1  1  2  1  1  1;
        2  3 -1 -1  1  3  1 -1  5  4  1  1;
        3  2  1 -1  4  6  1 -1  1  2 -1 -1;
        5  6 -1  1  3  1 -1 -1  2  1  1 -1;
        3  2  1  1  6  4 -1 -1  1  2 -1  1;
        2  3 -1  1  1  3  1  1  4  5 -1  1;
        6  5  1  1  3  1 -1 -1  2  1  1 -1;
        2  3 -1 -1  1  3  1 -1  5  4  1 -1;
        3  2  1  1  4  6  1 -1  1  2 -1  1;
        5  6 -1  1  3  1 -1  1  2  1  1  1;
        3  2  1 -1  6  4 -1  1  1  2 -1 -1;
        2  3 -1  1  1  3  1  1  4  5 -1 -1;
        6  5  1 -1  3  1 -1 -1  2  1  1 -1;
        2  3 -1  1  1  3  1  1  5  4  1 -1;
        3  2  1 -1  4  6  1  1  1  2 -1 -1;
        5  6 -1 -1  3  1 -1  1  2  1  1  1;
        3  2  1  1  6  4 -1  1  1  2 -1  1;
        2  3 -1 -1  1  3  1 -1  4  5 -1  1;
        0  0  0  0  3  1 -1  1  2  1  1  1;
        3  2  1  1  0  0  0  0  1  2 -1  1;
        2  3 -1  1  1  3  1  1  0  0  0  0;
        0  0  0  0  6  4 -1  1  5  4  1  1;
        6  5  1  1  0  0  0  0  4  5 -1  1;
        5  6 -1  1  4  6  1  1  0  0  0  0;
        0  0  0  0  9  7 -1  1  8  7  1  1;
        9  8  1  1  0  0  0  0  7  8 -1  1;
        8  9 -1  1  7  9  1  1  0  0  0  0;
        0  0  0  0  3  1 -1 -1  2  1  1 -1;
        3  2  1 -1  0  0  0  0  1  2 -1 -1;
        2  3 -1 -1  1  3  1 -1  0  0  0  0;
        0  0  0  0  6  4 -1 -1  5  4  1 -1;
        6  5  1 -1  0  0  0  0  4  5 -1 -1;
        5  6 -1 -1  4  6  1 -1  0  0  0  0;
        0  0  0  0  9  7 -1 -1  8  7  1 -1;
        9  8  1 -1  0  0  0  0  7  8 -1 -1;
        8  9 -1 -1  7  9  1 -1  0  0  0  0;
        0  0  0  0  1  3  1  1  1  2 -1  1;
        2  3 -1  1  0  0  0  0  2  1  1  1;
        3  2  1  1  3  1 -1  1  0  0  0  0;
        0  0  0  0  4  6  1  1  4  5 -1  1;
        5  6 -1  1  0  0  0  0  5  4  1  1;
        6  5  1  1  6  4 -1  1  0  0  0  0;
        0  0  0  0  7  9  1  1  7  8 -1  1;
        8  9 -1  1  0  0  0  0  8  7  1  1;
        9  8  1  1  9  7 -1  1  0  0  0  0;
        0  0  0  0  0  0  0  0  0  0  0  0]',4,3,52);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Convert the m string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~ischar(m) % lecacy call with integer m argument
    m=char(m+'w'); % convert to characters
end
ich=find(strcmp(m,mch),1);      % check if already in the cache
if isempty(ich)                 % not yet in the cache
    mm=m-'w';                   % convert to integers with x -> 1
    mi=mm>=-31 & mm<=-29;       % find characters XYZ
    mm(mi)=mm(mi)+32;           % convert XYZ to xyz (for compatibility)
    mi=mm>=-70 & mm<=-62;       % find digits 1:9
    mm(mi)=mm(mi)+74;           % convert to 4:12
    mi=mm<=0;                   % select control characters
    mc=mm(mi);                  % controls
    mm=mm(~mi);                 % rotations
    ef=1;                       % angle scale factor
    es=1;                       % angle sign
    fl=1;                       % default to no rotation matrix tranposing
    for i=1:length(mc)
        switch mc(i)
            case -5             % 'r' = radians
            case -19            % 'd' = degrees
                ef=pi/180;      % scale factor to convert to radians
            case -37            % 'R' = negated radians
                ef=-1;
            case -51            % 'D' = negated degrees
                ef=-pi/180;      % scale factor to convert to radians
            case -8             % 'o' = object-extrinsic
            case -40            % 'O' = object-intrinsic
                fl=-1;
                es=-1;
            case -22            % 'a' = axes-extrinsic
                fl=-1;
            case -54            % 'A' = axes-intrinsic
                es=-1;
            otherwise
                error('Invalid character: %s',mc(i)+'w')
        end
    end
    ef=ef*es;               % change sign of scale factor if necessary
    if es<0
        mm=mes(mm);         % sign-reverse: interchage 4,5,6 with 10,11,12
    end
    nm=length(mm);
    mv=zeros(7,nm+1);
    mv(1,:)=[mm 0];
    mv(2,:)=cumsum([mm<=3 0]);      % index into euler angle array
    mv(3,1)=1; % initial pattern is the identity matrix
    for i=1:nm                % loop for each rotation
        mmi=mm(i); % rotation code
        mv(3,i+1)=trmap(mv(3,i),mmi); % pattern ID after rotation
        if mmi<4
            mv(4:7,i)=zel(:,mmi,mv(3,i)); % information about which matrix elements change from zero
        end
    end
    mv(end)=fl;
    mv(end-3)=ef;
    % now save in the cache
    ich=jch(nch);       % find oldest cache entry
    mch{ich}=m;                 % save input string
    mvch{ich}=mv;               % save parameters
    jch=[ich jch(1:nch-1)];     % age all the other cache entries
else                            % already in the cache
    kch=find(jch==ich,1);       % find existing ich entry
    jch(1:kch)=[ich jch(1:kch-1)];
    mv=mvch{ich};               % retrieve from cache
end
