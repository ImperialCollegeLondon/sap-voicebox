function rf=v_lpcar2rf(ar)
%V_LPCAR2RF Convert autoregressive coefficients to reflection coefficients AR=(RF)
%
% Input:   ar(:,p+1)  Autoregressive coefficients
% Output:  rf(:,p+1)  Reflection coefficients with rf(:,1)=1


%      Copyright (C) Mike Brookes 1997
%      Version: $Id: v_lpcar2rf.m 10865 2018-09-21 17:22:45Z dmb $
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

[nf,p1] = size(ar);
if p1==1
   rf=ones(nf,1);
else
   if any(ar(:,1)~=1)
      ar=ar./ar(:,ones(1,p1));
   end
   rf = ar;
   for j = p1-1:-1:2
      k = rf(:,j+1);
      d = (1-k.^2).^(-1);
      wj=ones(1,j-1);
      rf(:,2:j) = (rf(:,2:j)-k(:,wj).*rf(:,j:-1:2)).*d(:,wj);
   end
end

