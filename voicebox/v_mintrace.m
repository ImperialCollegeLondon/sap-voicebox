function p=v_mintrace(x)
%V_MINTRACE find row permutation to minimize the trace p=(x)
%Inputs:    x(n,n)  is a square real-valued matrix
%
%Outputs:   p(n,1)  is the row permutation that minimizes the trace
%                   so that trace(x(p,:)) is as small as possible

%      Copyright (C) Mike Brookes 2012-2013
%      Version: $Id: v_mintrace.m 10865 2018-09-21 17:22:45Z dmb $
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
n=size(x,1);    % input x must be square
p=v_permutes(n);  % try all permutations
c=0:n:n^2-1;    % convert olumns to single indexing
[v,i]=min(sum(x(p+c(ones(length(p),1),:)),2));
p=p(i,:)';

