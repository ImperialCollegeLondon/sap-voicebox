function dl=v_lpcaa2dl(aa)
%V_LPCAA2DL LPC: Convert area coefficients to dct of log area DL=(AA)

% note: we do not correct for sinc distortion; perhaps we should multiply by
% k=1:p-1;s=[sqrt(0.5)/p 2*sin(pi*k/(2*p))./(pi*k)];



%      Copyright (C) Mike Brookes 1998
%      Version: $Id: v_lpcaa2dl.m 10865 2018-09-21 17:22:45Z dmb $
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

[nf,p2]=size(aa);
dl=v_rdct(log(aa(:,2:p2-1)./aa(:,p2*ones(1,p2-2))).').';


