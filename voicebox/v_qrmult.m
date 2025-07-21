function q=v_qrmult(q1,q2)
%V_QRMULT multiplies together two real quaternions matrices q=[q1,q2]
%
% Inputs:   q1(4m,n)  Two real quaternions arrays. Either array can
%           q2(4n,r)  also be a scalar quaternion.
%
% Outputs:   q(4m,r)  Matrix product of q1 and q2

%      Copyright (C) Mike Brookes 2000-2012
%      Version: $Id: v_qrmult.m 10865 2018-09-21 17:22:45Z dmb $
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
s1=size(q1);
s2=size(q2);
if isequal(s1,[4 1])
    q=v_qrdotmult(repmat(q1,s2(1)/4,s2(2)),q2);
elseif isequal(s2,[4 1])
    q=v_qrdotmult(q1,repmat(q2,s1(1)/4,s1(2)));
else
    q=v_rotqr2mr(q1)*q2;
end
