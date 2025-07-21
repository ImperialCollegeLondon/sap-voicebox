function [x,esq,j] = v_kmeanlbg(d,k)
%V_KMEANLBG Vector quantisation using the Linde-Buzo-Gray algorithm [X,ESQ,J]=(D,K)
%
%Inputs:
% D contains data vectors (one per row)
% K is number of centres required
%
%Outputs:
% X is output row vectors (K rows)
% ESQ is mean square error
% J indicates which centre each data vector belongs to
%
%  Implements LBG K-means algorithm:
% Linde, Y., A. Buzo, and R. M. Gray,
% "An Algorithm for vector quantiser design,"
% IEEE Trans Communications, vol. 28, pp.84-95, Jan 1980.


%      Copyright (C) Mike Brookes 1998
%      Version: $Id: v_kmeanlbg.m 10865 2018-09-21 17:22:45Z dmb $
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

nc=size(d,2);
[x,esq,j]=v_kmeans(d,1);
m=1;
while m<k
   n=min(m,k-m);
   m=m+n;
   e=1e-4*sqrt(esq)*rand(1,nc);
   [x,esq,j]=v_kmeans(d,m,[x(1:n,:)+e(ones(n,1),:); x(1:n,:)-e(ones(n,1),:); x(n+1:m-n,:)]);
end
