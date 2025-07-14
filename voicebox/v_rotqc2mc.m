function mc=v_rotqc2mc(qc)
%V_ROTQC2MC converts a matrix of complex quaternion vectors to quaternion matrices
% Inputs: 
%
%     QC(2m,n,...)   array of complex quaternion vectors (each 2x1)
%
% Outputs: 
%
%     MC(2m,2n,...)   array of complex quaternion matrices (each 2x2)
%
% Each quarternion, r+ai+bj+ck is a 2x1 complex vector in the input array of the
% form [ r+bi ; a+ci ]. In the output array, this becomes a 2x2 complex matrix
% of the form [ r+bi -a+ci ; a+ci r-bi ].
% 
% In matrix form, quaternions can be multiplied and added using normal matrix 
% arithmetic. The complex matrix form has 4 complex elements while the real
% matrix form has 16 real elements.

% 
%      Copyright (C) Mike Brookes 2000-2018
%      Version: $Id: v_rotqc2mc.m 10865 2018-09-21 17:22:45Z dmb $
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
s=size(qc);
m=s(1);
qa=reshape(qc,m,[]);
n=2*size(qa,2);
mc=zeros(m,n);
ix=1:2:m;
jx=2:2:n;
mc(:,jx-1)=qa;
mc(ix,jx)=-conj(qa(ix+1,:));
mc(ix+1,jx)=conj(qa(ix,:));
s(2)=2*s(2);
mc=reshape(mc,s);
if ~nargout
    v_rotqr2ro([real(qc(1)); real(qc(2)); imag(qc(1)); imag(qc(2))]); % plot a rotated cube
end