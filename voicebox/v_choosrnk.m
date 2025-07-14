function x=v_choosrnk(n,k)
%V_CHOOSRNK All choices of K elements taken from 1:N with replacement. [X]=(N,K)
% The output X is a matrix of size ((N+K-1)!/(K!*(N-1)!),K) where each row
% contains a choice of K elements taken from 1:N with duplications allowed.
% The rows of X are in lexically sorted order.
%
% To choose from the elements of an arbitrary vector V use
% V(CHOOSRNK(LENGTH(V),K)).

%   Copyright (c) 1998 Mike Brookes,  mike.brookes@ic.ac.uk
%      Version: $Id: v_choosrnk.m 10865 2018-09-21 17:22:45Z dmb $
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
x=v_choosenk(n+k-1,k);
x=x-repmat(0:k-1,size(x,1),1);