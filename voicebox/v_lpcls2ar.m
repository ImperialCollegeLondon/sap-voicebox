function ar=v_lpcls2ar(ls)
%V_LPCLS2AR convert line spectrum pair frequencies to ar polynomial AR=(LS)
% input vector elements should be in the range 0 to 0.5


%      Copyright (C) Mike Brookes 1997
%      Version: $Id: v_lpcls2ar.m 10865 2018-09-21 17:22:45Z dmb $
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

[nf,p]=size(ls);
p1=p+1;
p2 = p1*2;
ar=zeros(nf,p1);
for k=1:nf
  le=exp(ls(k,:)*pi*2i);
  lf=[1 le -1 conj(fliplr(le))];
  y=real(poly(lf(1:2:p2)));
  x=real(poly(lf(2:2:p2)));
  ar(k,:)=(x(1:p1)+y(1:p1))/2;
end
