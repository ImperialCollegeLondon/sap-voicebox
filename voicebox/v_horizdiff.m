function [z,zm]=v_horizdiff(y,v,x,u,q)
%V_HORIZDIFF - Estimates the horizontal difference between two functions of x
%
% Usage: z=horizdiff(y,v,x); % Approximately: y(x) = v(x+z)
%
%  Inputs: y(n,m) each column is a function of x
%          v(k,1) reference function of u
%          x(n,1) x values [default: x'=1:n]
%          u(k,1) x values for v [default: v=x]
%          q      interpolation mode
%                    'l' linear [default]
%                    'p' pchip (n>=2)
%                    's' spline (n>=4)
%
% Outputs: z(n,m)   horizontal difference between v and y
%          zm(1,m)  MMSE horizontal difference that minimizes sum((y(x)-v(x+z)).^2)
%

%	   Copyright (C) Mike Brookes 2012
%      Version: $Id: v_axisenlarge.m 10865 2018-09-21 17:22:45Z dmb $
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
%
%
% choose interpolation method
%
[n,m]=size(y);
if nargin<5 || isempty(m)
    q='';
end
if n>=4 && any(q=='s')
    im='spline';
elseif n>=2 && (any(q=='s') || any(q=='p'))
    im='pchip';
else
    im='linear';
end
if nargin<3 || isempty(x)
    x=(1:n)';
end
if nargin<4 || isempty(u)
    u=x;
end
%
% Interpolate inverse function, u(v)
%
z=interp1(v,u,y,im,'extrap')-repmat(x,1,m);
if nargout>1
    zm=zeros(1,m);
    ff=@(zm,c)sum((c-interp1(u,v,x+zm,im,'extrap')).^2);
    for i=1:m
        zm(i)=fminbnd(@(zm) ff(zm,y(:,i)),u(1)-x(end),u(end)-x(1));
    end
end
if ~nargout
    subplot(212);
    plot(x,z);
    xlabel('x');
    ylabel('x shift');
    if all(abs(z-z(1))<=z(1)*1e-4)
        set(gca,'ylim',2*[min(z(1),0) max(z(1),0)]);
    end
    subplot(211);
    plot(x,y);
    hold on
    plot(u,v,':k');
    hold off
    ylabel('y and v');
end