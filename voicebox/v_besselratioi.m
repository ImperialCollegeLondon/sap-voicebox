function s=v_besselratioi(r,v,p)
%V_BESSELRATIOI calculate the inverse Bessel function ratio
%  Inputs:
%      r    value of the Bessel function ratio besseli(v+1,s)./besseli(v,s) (scalar or matrix)
%      v    denominator Bessel function order [0] [for now v=0 always]
%      p    digits precision <=14 [5]
%
% Outputs:
%      s    value of s such that r=besseli(v+1,s)./besseli(v,s)
%
% This function implements function VKAPPA from [1] for which a FORTRAN
% implementation is available in [2].
%
% Refs:
% [1] G. W. Hill, Evaluation and Inversion of the Ratios of Modified Bessel
%     Functions, I 1 (x)/I 0 (x) and I 1.5 (x)/I 0.5 (x),
%     ACM Transactions on Mathematical Software (TOMS), Vol 7, pp199-208, 1981
% [2] ACM Collected Algorithms (CALGO), http://calgo.acm.org/

%      Copyright (C) Mike Brookes 2017-2018
%      Version: $Id: v_besselratioi.m 10865 2018-09-21 17:22:45Z dmb $
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
if nargin<3 || isempty(p)
    p=5;
else
    p=min(max(ceil(p),1),13);       % digits precision required
end
if nargin<2 || isempty(v)
    v=0;                            % default to I1/I0
end
sr=size(r);
r=r(:); % convert to a column vector
nr=prod(sr);
if v~=0
    error('v must be zero (for now)');
end
s=repmat(-1,nr,1);      % default is -1 for r<0 or r>=1
y=2./(1-r);
m1=r>=0 & r<1;          % m1 is mask for valid range
mn=m1;                  % mn is mask for using Newton iteration
m=m1 & r<=0.85;         % use inverse taylor series for 0<=r<=0.85
if any(m)
    rm=r(m);  
    mn(m)= rm>=0.642;   % we will need a Newton iteration for 0.642<=r<=0.85
    xm=rm.^2;
    sm=(((rm-5.6076).*rm+5.0797).*rm-4.6494).*y(m).*xm-1;
    s(m)=((((sm.*xm+15.0).*xm+60.0).*xm/360.0+1.0).*xm-2.0).*rm./(xm-1);
end
m=m1 & ~m;              % use continued fraction for 0.85<r<1
if any(m)
    rm=r(m);
    mn(m)=rm<0.95;      % we will need a Newton iteration for 0.85<r<0.95
    ym=y(m);
    mc=rm<0.95;
    if any(mc)
        rm(mc)=(-2326.0.*rm(mc)+4317.5526).*rm(mc) - 2001.035224;
    end
    if any(~mc)    
        rm(~mc)=32.0./(120.0*rm(~mc)-131.5+ym(~mc));
    end
    s(m)=(ym+1.0+3.0./(ym-5.0-12.0./(ym-10.0-rm)))*0.25;    
end
if any(mn)              % we need to do one or two Newton iterations
    rmn=r(mn);
    smn=s(mn);
    ymn=y(mn);
    ymn= ((0.00048*ymn-0.1589).*ymn+0.744).*ymn - 4.2932;   % Gradient approximation ds/dr
    smn=smn+(v_besselratio(smn,0,p+1)-rmn).*ymn;              % do a Newton iteration
    mr=(rmn>=0.75) & (rmn<=0.875);                          % need a second Newton iteration for 0.75<=r<=0.875
    if any(mr)
        smn(mr)=smn(mr)+(v_besselratio(smn(mr),0,p+1)-rmn(mr)).*ymn(mr); % do a second Newton iteration
    end
    s(mn)=smn;                                              % update the main s() array
end
s=reshape(s,sr);                % put back into the same shape is the input r
if ~nargout
    plot(r,s);
    ylabel('x');
    xlabel(sprintf('I_{%d}(x)/I_{%d}(x)',v+1,v));
end