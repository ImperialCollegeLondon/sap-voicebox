function x=v_usasi(n,fs)
%V_USASI generates N samples of USASI noise at sample frequency FS X=(N,FS)

% This routine is based on the USASI noise defined in [1] which was later
% reissued as [2]. USASI noise is intended to simulate the long-term average
% of typical audio program material. The routine does not currently implement
% the pulsation at 2.5Hz 12.5% duty cycle that is recommended by the standard.
% Also it should probably be scaled to a well-defined power.
%
%  [1] NRSC AM Reemphasis, Deemphasize, and Broadcast Audio Transmission Bandwidth Specifications,
%      EIA-549 Standard, Electronics Industries Association , July 1988.
%  [2] NRSC AM Reemphasis, Deemphasize, and Broadcast Audio Transmission Bandwidth Specifications,
%      NRSC-1-A Standard, Sept 2007, Online: http://www.nrscstandards.org/SG/NRSC-1-A.pdf 

%      Copyright (C) Mike Brookes 1997
%      Version: $Id: v_usasi.m 10865 2018-09-21 17:22:45Z dmb $
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

if nargin<2 fs=8000; end
b=[1 0 -1];
a=poly(exp(-[100 320]*2*pi/fs));

x=v_randfilt(b,a,n);