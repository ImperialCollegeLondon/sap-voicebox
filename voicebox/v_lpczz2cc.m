function cc=v_lpczz2cc(zz,np)
%V_LPCZZ2CC Convert poles to "complex" cepstrum CC=(ZZ,NP)


%      Copyright (C) Mike Brookes 1997
%      Version: $Id: v_lpczz2cc.m 10865 2018-09-21 17:22:45Z dmb $
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

[nf,p]=size(zz);
if (nargin < 2) np=p; end
cc=zeros(nf,np);
yy=zz.';
if p<2			% special case 'cos sum() is weird
  cc(:,1)=real(zz);
  for k=2:np
    yy=yy.*zz.';
    cc(:,k)=real(yy).'/k;
  end
else
  cc(:,1)=sum(real(yy)).';
  for k=2:np
    yy=yy.*zz.';
    cc(:,k)=sum(real(yy)).'/k;
  end
end
