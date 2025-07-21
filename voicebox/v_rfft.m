function y=v_rfft(x,n,d)
%V_RFFT     Calculate the DFT of real data Y=(X,N,D)
% Data is truncated/padded to length N if specified.
%   N even:	(N+2)/2 points are returned with
% 			the first and last being real
%   N odd:	(N+1)/2 points are returned with the
% 			first being real
% In all cases floor(1+N/2) points are returned
% D is the dimension along which to do the DFT

%      Copyright (C) Mike Brookes 1998
%      Version: $Id: v_rfft.m 10865 2018-09-21 17:22:45Z dmb $
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

s=size(x);
if prod(s)==1
    y=x
else
    if nargin <3 || isempty(d)
        d=find(s>1,1);
        if nargin<2
            n=s(d);
        end
    end
    if isempty(n) 
        n=s(d);
    end
    y=fft(x,n,d);
    y=reshape(y,prod(s(1:d-1)),n,prod(s(d+1:end))); 
    s(d)=1+fix(n/2);
    y(:,s(d)+1:end,:)=[];
    y=reshape(y,s);
end
