function m = v_rnsubset(k,n)
%V_RNSUBSET choose k distinct random integers from 1:n M=(K,N)
%
%  Inputs:
%
%    K is number of disinct integers required from the range 1:N
%    N specifies the range - we must have K<=N
%
%  Outputs:
%
%    M(1,K) contains the output numbers

%      Copyright (C) Mike Brookes 2006
%      Version: $Id: v_rnsubset.m 10865 2018-09-21 17:22:45Z dmb $
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
if k>n
    error('rnsubset: k must be <= n');
end
% We use two algorithms according to the values of k and n
[f,e]=log2(n);
if k>0.03*n*(e-1)
[v,m]=sort(rand(1,n)); % for large k, just do a random permutation
else
    v=ceil(rand(1,k).*(n:-1:n-k+1));
    m=1:n;
    for i=1:k
        j=v(i)+i-1;
        x=m(i);
        m(i)=m(j);
        m(j)=x;
    end
end
m=m(1:k);
