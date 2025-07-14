function q=v_qrdotmult(q1,q2)
%V_QRDOTMULT multiplies together two real quaternions arrays q=[q1,q2]
%
% Inputs:  q1(4n,...)
%          q2(4n,...)   Two real quaternion arrays of equal size
%
% Outputs: q(4n,...)    The Hadamard product (i.e. .*) of the input arrays
%
%      Copyright (C) Mike Brookes 2000-2012
%      Version: $Id: v_qrdotmult.m 10865 2018-09-21 17:22:45Z dmb $
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
%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
persistent a b c
if isempty(a)
    a=[1 2 3 4 2 1 4 3 3 4 1 2 4 3 2 1];
    b=[1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4];
    c=[2 3 4 7 12 14];
end
s=size(q1);
qa=reshape(q1,4,[]);
qb=reshape(q2,4,[]);
q=qa(a,:).*qb(b,:);
q(c,:)=-q(c,:);
q=reshape(sum(reshape(q,4,[]),1),s);
