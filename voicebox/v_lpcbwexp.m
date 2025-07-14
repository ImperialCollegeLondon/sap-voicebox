function arx=v_lpcbwexp(ar,bw)
%V_LPCBWEXP expand formant bandwidths of LPC filter ARX=(AR,BW)
%minimum bandwidth will be BW*fs where fs is the sampling frequency
%the radius of each pole will be multiplied by R=exp(-BW*pi)
% To set the maximum pole radius to R use BW=-log(R)/PI.



%      Copyright (C) Mike Brookes 1998
%      Version: $Id: v_lpcbwexp.m 10865 2018-09-21 17:22:45Z dmb $
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

[nf,p1]=size(ar);
k=exp(-pi*(0:p1-1)*bw);
arx=ar.*k(ones(nf,1),:);
