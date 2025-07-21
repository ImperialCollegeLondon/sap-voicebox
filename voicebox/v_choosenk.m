function x=v_choosenk(n,k)
%V_CHOOSENK All choices of K elements taken from 1:N [X]=(N,K)
% The output X is a matrix of size (N!/(K!*(N-K)!),K) where each row
% contains a choice of K elements taken from 1:N without duplications.
% The rows of X are in lexically sorted order.
%
% To choose from the elements of an arbitrary vector V use
% V(CHOOSENK(LENGTH(V),K)).

% CHOOSENK(N,K) is the same as the MATLAB5 function NCHOOSEK(1:N,K) but is
% much faster for large N and most values of K.

%   Copyright (c) 1998 Mike Brookes,  mike.brookes@ic.ac.uk
%      Version: $Id: v_choosenk.m 10865 2018-09-21 17:22:45Z dmb $
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

kk=min(k,n-k);
if kk<2
   if kk<1
      if k==n
         x=1:n;
      else
         x=[];
      end
   else
      if k==1
         x=(1:n)';
      else
         x=1:n;
         x=reshape(x(ones(n-1,1),:),n,n-1);
      end
   end   
else
   n1=n+1;
   m=prod(n1-kk:n)/prod(1:kk);
   x=zeros(m,k);
   f=n1-k;
   x(1:f,k)=(k:n)';
   for a=k-1:-1:1
      d=f;
      h=f;
      x(1:f,a)=a;
      for b=a+1:a+n-k
         d=d*(n1+a-b-k)/(n1-b);
         e=f+1;
         f=e+d-1;
         x(e:f,a)=b;
         x(e:f,a+1:k)=x(h-d+1:h,a+1:k);
      end
   end
end