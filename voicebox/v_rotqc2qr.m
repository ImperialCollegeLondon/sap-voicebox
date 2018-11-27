function qr=v_rotqc2qr(qc)
%V_ROTQC2QR converts a matrix of complex quaternion row vectors into real form
%
% Inputs: 
%
%     QC(2m,...)   array of complex-valued quaternions
%
% Outputs: 
%
%     QR(4m,...)   array of real-valued quaternions
%
% The complex-valued quaternion [r+j*b  a+j*c] becomes [r a b c]

% 
%      Copyright (C) Mike Brookes 2000-2018
%      Version: $Id: v_rotqc2qr.m 10865 2018-09-21 17:22:45Z dmb $
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
persistent a b
if isempty(a)
    a=[1 3 2 4];
end
s=size(qc);
s(1)=2*s(1); % each complex number needs two reals
qr=reshape([real(qc(:).'); imag(qc(:).')],4,[]);
qr=reshape(qr(a,:),s);
if ~nargout
    qr=qr(1:4); % just select the first one
    v_rotqr2ro(qr(:)); % plot a rotated cube
end
