function [y,s]=v_gammalns(x)
%V_GAMMALNS Log of Gamma(x) for positive or negative real x [y,s]=(x)
%
%  Inputs: x      real matrix of input values
%
% Outputs: y      log(gamma(x)) or, if s is present, log(abs(gamma(x))) 
%          s      sign(gamma(x))
%
% If s is not specified then y will b complex if gamma(x) is negative (i.e. if floor(x) is negative and odd).
% Uses gamma(x) = pi/gamma(1-z)/sin(pi*z) which is 5.5.3 from [1]
%
% [1]	F. W. J. Olver, D. W. Lozier, R. F. Boisvert, and C. W. Clark, editors.
%       NIST Handbook of Mathematical Functions. CUP, 2010. ISBN 978-0-521-14063-8.

%      Copyright (C) Mike Brookes 2017
%      Version: $Id: v_gammalns.m 10865 2018-09-21 17:22:45Z dmb $
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
persistent l
m=x<=0;
y=zeros(size(x));
s=ones(size(x));
if ~all(m(:)) % non-negative x values
    y(~m)=gammaln(x(~m));
end
f=m & (x==fix(x)); % find and non-positive integers
if any(f(:))
    y(f)=Inf; % set output to infinity
    m=m & ~f; % do not consider these values furhter
end
if any(m(:)) % negative x values
    if isempty(l)
        l=log(pi);
    end
    t=sin(pi*x(m));
    if nargout>1
        p=t<0;
        s(m)=1-2*(p); 
        y(m)=l-gammaln(1-x(m))-log(abs(t));
    else
        y(m)=l-gammaln(1-x(m))-log(t);
    end
end
    
