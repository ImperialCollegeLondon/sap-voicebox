function s=v_frac2bin(d,n,m)
%V_FRAC2BIN Convert an column vector to binary S=(D,N,M)
%  Inputs:  D   scalar or column vector to convert
%           N   minimum number of integer bits to output [default 1]
%           M   number of places after binary point [default 0]
%
%  Outputs: S   String matrix with one value per row. A binary point is included
%               if M>0. The values in D are rounded to the number of displayed bits.
%               If N is negative then leading zeros will be output as spaces if they are to the
%               left of the |N|'th integer column (i.e. N digits will always be output)
%               If M is negative, then values will be truncated rather than rounded.
%
% Bug: doesn't yet cope with negative numbers

%      Copyright (C) Mike Brookes 2005
%      Version: $Id: v_frac2bin.m 10865 2018-09-21 17:22:45Z dmb $
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

if nargin<3
    m=0;
    if nargin<2
        n=1;
    end
end
l=abs(n);
r=abs(m);
[f,e]=log2(max(d));
if m<0
    v=floor(pow2(d(:),r));
else
    v=round(pow2(d(:),r));
end
s=setstr(rem(floor(v*pow2(1-max(l,e)-r:0)),2)+'0');
c=size(s,2)+1;  % size including binary point (even if not present)
b=c-r;          % position of binary point
if r>0
    s(1,c)='0'; % make s bigger
    s(:,b+1:c)=s(:,b:c-1);  % shift binary places to the right
    s(:,b)='.';
end
q=cumsum(s~='0',2);
if n<0
    t=s(:,1:b-l-1);
    t(~q(:,1:b-l-1))=' ';
    s(:,1:b-l-1)=t;
end
    