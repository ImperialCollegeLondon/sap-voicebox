function qc=v_rotqr2qc(qr)
%V_ROTQR2QC converts a matrix of real quaternion vectors into complex form
%
% Inputs: 
%
%     QR(4m,...)   array of real-valued quaternions
%
% Outputs: 
%
%     QC(2m,...)   array of complex-valued quaternions
%
% The real-valued quaternion [r a b c]' becomes [r+j*b  a+j*c]'

% 
%      Copyright (C) Mike Brookes 2000-2018
%      Version: $Id: v_rotqr2qc.m 10865 2018-09-21 17:22:45Z dmb $
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
persistent a b
if isempty(a)
    a=[1 3 2 4];
    b=[1 1i];
end
s=size(qr);
qq=reshape(qr,4,[]);
s(1)=s(1)/2;
qc=reshape(b*reshape(qq(a,:),2,[]),s);
if ~nargout
    v_rotqr2ro(qq(:,1)); % plot a rotated cube
end