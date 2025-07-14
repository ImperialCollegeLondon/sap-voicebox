function rr=v_lpcpf2rr(pf,p)
%V_LPCPF2RR convert power spectrum to autocorrelation coefs RR=(PF,P)
% Note that these will only be accurate if the power spectrum is much longer than p


%      Copyright (C) Mike Brookes 1997
%      Version: $Id: v_lpcpf2rr.m 10865 2018-09-21 17:22:45Z dmb $
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

[nf,p2]=size(pf);
if nargin<2 p=p2-2; end;
ir=v_irfft(pf,[],2);
if p>p2-2
  rr=[ir(:,1:p2-1) zeros(nf,p+2-p2)];
else
  rr=ir(:,1:p+1);
end
