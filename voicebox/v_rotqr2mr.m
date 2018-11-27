function mr=v_rotqr2mr(qr)
%V_ROTQR2MR converts a matrix of real quaternion vectors to quaternion matrices
% Inputs:
%
%     QR(4m,n,...)   mxn matrix of real quaternion vectors (each 4x1)
%
% Outputs:
%
%     MR(4m,4n,...)   mxn matrix of real quaternion matrices (each 4x4)
%
% In matrix form, quaternions can be multiplied and added using normal matrix
% arithmetic. Each element of an mxn matrix of quaternions is itself a 4x4 block
% so the total dimension of MR is 4m x 4n.

%
%      Copyright (C) Mike Brookes 2000-2018
%      Version: $Id: v_rotqr2mr.m 10865 2018-09-21 17:22:45Z dmb $
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
persistent a b c
if isempty(a)
    a=[1 2 3 3 1 2];    % destination row of +ve entries (from 0)
    b=[1 2 3 2 3 1];    % destination col of +ve entries (from 0)
    c=[0 0 0 1 2 3];    % source row of +ve entries (from 0)
end
s=size(qr);
m=s(1);
mr=repmat(reshape(qr,s(1),[]),4,1);
n=size(mr,2);
mn=s(1)*n;
j=repmat(4*m*(0:n-1),m/4,1);
i=repmat((1:4:m)',n,1)+j(:);
ni=length(i);
i6=repmat(i,1,6);
mr(i6+repmat(a+m*b,ni,1))=mr(i6+repmat(c,ni,1));
mr(i6+repmat(c+m*b,ni,1))=-mr(i6+repmat(a,ni,1));
s(2)=4*s(2); % output array size
mr=reshape(mr,s);
if ~nargout
    qr=qr(1:4);
    v_rotqr2ro(qr(:)); % plot a rotated cube
end
