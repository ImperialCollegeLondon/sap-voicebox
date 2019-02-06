function [s,c,r,t]=v_atan2sc(y,x)
%V_ATAN2SC    sin and cosine of atan(y/x) [S,C,R,T]=(Y,X)
%
% Outputs:
%    s    sin(t) where tan(t) = y/x
%    c    cos(t) where tan(t) = y/x
%    r    sqrt(x^2 + y^2)
%    t    arctan of y/x
%
% Note y and x can be arrays but must be the same size. The outputs will
% all be the same size as y.

%      Copyright (C) Mike Brookes 2007
%      Version: $Id: v_atan2sc.m 10865 2018-09-21 17:22:45Z dmb $
%
%   VOICEBOX is a MATLAB toolbox for speech processing.
%   Home page: http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/voicebox.html
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This program is free software; you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation; either version 2 of the License, or
%   (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You can obtain a copy of the GNU General Public License from
%   http://www.gnu.org/copyleft/gpl.html or by writing to
%   Free Software Foundation, Inc.,675 Mass Ave, Cambridge, MA 02139, USA.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sz=size(y);
s=zeros(sz);
c=NaN(sz);
r=zeros(sz);
t=NaN(sz);
m=y==0;
if any(m(:)) % handle case when y=0 and possibly x=0 also
    t(m)=(x(m)<0);
    c(m)=1-2*t(m);
    r(m)=abs(x(m));
    t(m)=t(m)*pi;
end
m=abs(y)>abs(x) & isnan(c);
if any(m(:))
    q = x(m)./y(m);
    u = sqrt(1+q.^2).*sign(y(m)); % avoids underflow even if x and y are very small
    s(m) = 1./u;
    c(m) = s(m).*q;
    r(m) = y(m).*u;
end
m=isnan(c);
if any(m(:))
    q = y(m)./x(m);
    u = sqrt(1+q.^2).*sign(x(m));
    c(m) = 1./u;
    s(m) = c(m).*q;
    r(m) = x(m).*u;
end
m=isnan(t);
if nargout>3 && any(m(:))
    t(m)=atan2(s(m),c(m));
end