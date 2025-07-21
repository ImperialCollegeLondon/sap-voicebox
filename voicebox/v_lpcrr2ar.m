function [ar,e]=v_lpcrr2ar(rr);
%V_LPCRR2AR convert autocorrelation coefs to ar coefs [AR,E]=(RR)
%E is the residual energy

% could test e each time and remove rows when it gets small


%      Copyright (C) Mike Brookes 1997
%      Version: $Id: v_lpcrr2ar.m 10865 2018-09-21 17:22:45Z dmb $
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

[nf,p1]=size(rr);
p=p1-1;
ar=ones(nf,p1);
ar(:,2) = -rr(:,2)./rr(:,1);
e = rr(:,1).*(ar(:,2).^2-1);
for n = 2:p
   k = (rr(:,n+1)+sum(rr(:,n:-1:2).*ar(:,2:n),2)) ./ e;
   ar(:,2:n) = ar(:,2:n)+k(:,ones(1,n-1)).*ar(:,n:-1:2);
   ar(:,n+1) = k;
   e = e.*(1-k.^2);
end
e=-e;
