function rr=v_lpcar2rr(ar,p)
%V_LPCAR2RR Convert autoregressive coefficients to autocorrelation coefficients RR=(AR,P)
% The routine calculated the autocorrelation coefficients of the signal
% that results from feeding unit-variance, zero-mean noise into the all-pole filter
% Input:   ar(:,n+1)  Autoregressive coefficients including 0'th coefficient
% Output:  rr(:,p+1)    Autocorrelation coefficients including 0'th order coefficient
% If p is not specified it is taken to be n


%      Copyright (C) Mike Brookes 1997
%      Version: $Id: v_lpcar2rr.m 10865 2018-09-21 17:22:45Z dmb $
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

k=ar(:,1).^(-2);
if size(ar,2)==1
   rr=k;
else
   if nargin>1
      rr=v_lpcrf2rr(v_lpcar2rf(ar),p).*k(:,ones(1,p+1));
   else
      rr=v_lpcrf2rr(v_lpcar2rf(ar)).*k(:,ones(1,size(ar,2)));
   end
end
