function y=v_besselratio(x,v,p)
%V_BESSELRATIO calculate the Bessel function ratio besseli(v+1,x)./besseli(v,x)
%
%  Inputs: x Bessel function argument (scalar or matrix)
%          v denominator Bessel function order [0]
%          p digits precision <=14 [5]
%
% Outputs: y value of the Bessel function ratio besseli(v+1,x)./besseli(v,x)
%
% Uses an algorithm from [1] of which a pseudocode version is given in [2] but which
% has an misprint in the first line: "min" instead of "max".
% The iteration count and minimum initial order are made dependent on the
% required precision to improve efficiency.
%
% [1]	D. E. Amos. Computation of modified bessel functions and their ratios.
%       Mathematics of Computation, 28 (125): 239�251, jan 1974. doi: 10.1090/S0025-5718-1974-0333287-7.
% [2]	G. Kurz, I. Gilitschenski, and U. D. Hanebeck.
%       Recursive nonlinear filtering for angular data based on circular distributions.
%       In Proc American Control Conf, Washington, June 2013.

%      Copyright (C) Mike Brookes 2016-2017
%      Version: $Id: v_besselratio.m 10865 2018-09-21 17:22:45Z dmb $
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
wm=[1 1 2 4 10 20 14 21 16 22 18 23 20 25];  % lower bound for initial v as a function of p
nm=[1 1 1 1 1 1 2 2 3 3 4 4 5 5];            % number of iterations as a function of p
if nargin<3 || isempty(p)
    p=5;                            % default precision is 5 digits
else
    p=min(max(ceil(p),1),14);       % digits precision required
end                       
n=nm(p);                            % number of iterations
if nargin<2 || isempty(v)
    v=0;                            % default to I1/I0
end
u=max(v,wm(p));                        % minimum value of v for first stage
s=size(x);
x=x(:);
r=zeros(numel(x),n+1);              % intermediate estimates: one row per value of x
for i=1:n+1
    r(:,i)=x./(u+i-0.5+sqrt((u+i+0.5)^2+x.^2)); % lower bound for ratio: Eqn (20a) from [1]
end
for i=1:n
    for k=1:n-i+1                   % k is actually k+1 in (20b) of [1]
        r(:,k)=x./(u+k+sqrt((u+k)^2+x.^2.*r(:,k+1)./r(:,k)));  % Eqn (20b) from [1]
    end
end
y=r(:,1);
for i=u:-1:v+1
    y=1./(y+2*i./x);                % backward recursion on v using Eqn (2) from [1]
end
y(x==0)=0;                          % fix up special case of x=0
y=reshape(y,s);
if ~nargout
    plot(x,y);
    xlabel('x');
    ylabel(sprintf('I_{%d}(x)/I_{%d}(x)',v+1,v));
end
