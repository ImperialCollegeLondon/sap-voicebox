function [y,zf,u,p]=v_randfilt(pb,pa,ny,zi)
%V_RANDFILT Generate filtered gaussian noise without initial transient
%
%  Inputs: pb(1,:)  Numerator polynomial of discrete time filter
%          pa(1,:)  Denominator polynomial of discrete time filter
%          ny       Number of output samples required
%          zi       Optional initial filter state
%
% Outputs: y(ny,1)  Filtered Gaussian noise
%          zf       final filter state (can be used to extend the noise sequence)
%          u        The state covariance matrix, <zf*zf'>, is u*u'
%          p        Is the expected value of y(i)^2
%
% zf and zi are the output and optional input state as defined in filter() as given below.
% If zi is not specified, random numbers with the correct covariance will be used.
% output u*u' is the state covariance matrix for filter(). Output p is the
% mean power of the output signal y.
%
% The state space representation of filter() is z=Az+Bx, y=Cz+Dx where
%       A=[-pa(2:k); eye(k-2) zeros(k-2,1)].'
%       B=[pb(2:k)-pb(1)*pa(2:k)].'
%       C=[1 zeros(1,k-2)]
%       D=pb(1)
% and k is the order of the filter, pa(1)=1 and pa and pb are zero-padded to length k+1.
%
% Refs:
% [1]	D. M. Brookes. Coloured noise generation without filter startup transient.
%       IEE Electronics Lett., 37 (4): 255–256, Feb. 2001. doi: 10.1049/el:20010144.

%      Copyright (C) Mike Brookes 1997-2021
%      Version: $Id: v_randfilt.m 10865 2018-09-21 17:22:45Z dmb $
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

% first normalize the denominator polynomial if necessary

if pa(1)~=1
    pb=pb/pa(1); pa=pa/pa(1);
end

% check to see if we must generate zi

if nargin<4 | nargout>2
    lb=length(pb);
    la=length(pa);

    k=max(la,lb)-1;     % filter order
    n=la-1;             % denominator order
    ii=k+1-n:k;

    % form controllability matrix

    q=zeros(k,k);
    [z,q(:,1)]=filter(pb,pa,1);
    for i=2:k [z,q(:,i)]=filter(pb,pa,0,q(:,i-1)); end

    % we generate m through the step-down procedure
    s=randn(k,1);
    if n
        m=zeros(n,n);
        g=pa;
        for i=1:n
            g=(g(1)*g(1:end-1)-g(end)*g(end:-1:2))/sqrt((g(1)-g(end))*(g(1)+g(end)));
            m(i,i:n)=g;
        end
        s(ii)=triu(toeplitz(pa(1:n)))*(m\s(ii));
        if nargout>2
            u=q;
            u(:,ii)=q(:,ii)*triu(toeplitz(pa(1:n)))/m;
        end
    else
        if nargout>2
            u=q;
        end
    end
    if nargin < 4
        if k
            zi=q*s;
        else
            zi=[];
        end
    end
end
if nargout>2
    if ~numel(u)
        p=pb(1).^2;
    else
        p=u(1,:)*u(1,:)'+pb(1).^2;
    end
end
if nargin>2 && ny>0
    [y,zf]=filter(pb,pa,randn(ny,1),zi);
else
    zf=zi;
    y=[];
end