function ar=v_lpccc2ar(cc)
%V_LPCCC2AR Convert complex cepstrum to ar coefficients AR=(CC)
%
% MATLAB5 version


%      Copyright (C) Mike Brookes 1998
%      Version: $Id: v_lpccc2ar.m 10865 2018-09-21 17:22:45Z dmb $
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

[nf,p]=size(cc);
rp=-(1:p);
cc = cc .* rp(ones(nf,1),:);
if p<2
  ar = [ones(nf,1) cc(:,1)];
else
 ar=zeros(nf,p+1);
 ar(:,1:3) = [ones(nf,1) cc(:,1) (cc(:,2)+cc(:,1).^2)/2];
  for k=3:p
    ar(:,k+1) = (cc(:,k) + sum(cc(:,1:k-1).*ar(:,k:-1:2),2))/k;
  end
end

