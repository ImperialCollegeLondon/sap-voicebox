function [c,r,k]=v_pdfmoments(t,m,b,a)
%V_PDFMOMENTS convert between central moments, raw moments and cumulants [C,R,K]=(T,M,B,A)
%  Inputs: t  text string containing:
%               'm','r','k'  Imput is central moments, raw moments, cumulants [default 'm']
%               'M','R','K'  Ouptut c is central moments, raw moments, cumulants [default 'M']
%          m    vector of input moments; m(r) is moment r, m(1) is always the mean
%          a,b  If input moments are for x, output moments are for a*x+b [defaulta=1, b=0]
%
% Outputs: c    central moments (or as determined by 'R' or 'K' options)
%          r    raw moments
%          k    cumulants
%
% (a) For all formats, the first element is the mean (i.e. not the first central moment or cumulant which equal zero).
% (b) v_pdfmoments('k',[m,s^2,0,0,0])=v_pdfmoments('k',[0,1,0,0,0],m,s) gives a Gaussian with mean m and std dev s

%   Copyright (c) 1998 Mike Brookes,  mike.brookes@ic.ac.uk
%      Version: $Id: v_pdfmoments.m 10865 2018-09-21 17:22:45Z dmb $
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
persistent n0 bc mk fa
if isempty(n0)
    n0=3;  % order 3
    bc=[1 1 0 0; 1 2 1 0; 1 3 3 1]; % binomial coefficients
    mk={[1 1 1];[0 1 1 1]};  %  cumulant coefficients: one row per term, powers of k(2:i+1), coef k->m, coef m->k
    mn=[1 0; 1 1]; % [i,j] = number of terms in m(i+1) whose lowest moment is >= j+1
    fa=1; % factorial list
end
% check arguments
if nargin<4 || isempty(a)
    a=1;
end
if nargin<3 || isempty(b)
    b=0;
end
if isempty(t)
    t='';
end
n=length(m);                                    % number of moments required
if n>n0                                         % check if need to update coefficient arrays
    if fix(n/2-1)>length(fa)                    % we need factorials up to fix(n/2-1)
        fal=length(fa);
        fa(fix(n/2-1),1)=0;                     % enlarge factorial vector
        for i=fal+1:fix(n/2-1)
            fa(i)=i*fa(i-1);                    % create new factorials
        end
    end
    bc(n,n+1)=0;                                % enlarge binomial coefficient array
    mk{n-1,1}=[];                               % enlarge cumulant coefficient array
    mn(n-1,n-1)=0;                              % enlarge cumulant coefficient counts
    for i=n0+1:n
        bc(i,1:i+1)=[1 bc(i-1,1:i)+bc(i-1,2:i+1)];                      % update binomial coefficients
        j=fix((i+1)/2);                                                 % first coefficient row to sum
        nr=1+sum(mn(((j-1:i-3)+(n-1)*(i-j-2:-1:0))));                   % number of terms
        mki=zeros(nr,i+1);                                              % coefficient matrix
        ix=1;
        mki(1,i-1:i+1)=1;                                               % first term always has a coefficient of 1
        for r=j:i-2                                                     % previous coefficients to use
            nk=mn(r-1+(n-1)*(i-r-2));                                   % number of new coefficients for this value of r
            mkk=mk{r-1};                                                % old coefficients for this value of r
            mkik=mkk(1:nk,1:r-1);                                       % extract just the list of powers for each term
            mkik(:,i-r-1)=mkik(:,i-r-1)+1;                              % increment the power of moment  i-r
            mki(ix+1:ix+nk,1:r-1)=mkik;                                 % and save as new terms
            mki(ix+1:ix+nk,i)=mkk(1:nk,r)*bc(i,i-r+1)./mkik(:,i-r-1);   % calculate coefficient for r->m
            rho=sum(mkik,2)-1;                                          % rho is one less than the sum of the moment powers
            mki(ix+1:ix+nk,i+1)= mki(ix+1:ix+nk,i).*fa(rho).*(-1).^rho; % calculate coefficient for m->r
            ix=ix+nk;                                                   % update the number of terms so far
        end
        mki=sortrows(mki);                                              % sort according to the lowest moment that is used
        mn(i-1,1:i-1)=[nr sum(cumprod(mki(:,1:i-2)==0,2),1)];           % update count of terms with lowest moment >= j+1
        mk{i-1}=mki;                                                    % save in persistent cell array
    end
    n0=n;                                       % coefficients are now calculated up to order n
end
% apply scaling if input type is 'c' or 'k'
mu=a*m(1)+b; % calculate new mean
c=m; % initialize output shapes
r=m;
k=m;
m=m(:)'; % now force the input to be a row vector
if any(t=='k')
    tin=3; % set input type
    k(:)=k(:)'.*a.^(1:n);
    k(1)=0; % first cumulant is actually zero
elseif any(t=='r')
    tin=2;
else
    tin=1;
    c(:)=c(:)'.*a.^(1:n);
    c(1)=0;  % first cenral moment is actually zero
end
tout=[(~any(t=='K') && ~any(t=='R')) (nargout>=2 || any(t=='R')) (nargout>=3 || any(t=='K'))]; % outputs required
for il=1:2 % loop through conversion routines twice
    % first convert between moments
    if il==1 % convert unscaled R -> C
        v=[1 m.*a.^(1:n)];
        bb=b-mu;
        doit=tin==2 && (tout(1) || tout(3));
    else  % convert C -> R or unscaled R -> R
        if tin==2 % input type was 'r' (v is OK from previous iteration)
            bb=b;
        else % input type was 'c' or 'k'
            v=[1 c(:)'];
            bb=mu;
        end
        doit=tout(2); % convert if 'R' output required
    end
    if doit
        y=v(2:end);
        if bb~=0 % don't bother if the constant term is zero
            for i=1:n
                y(i)=polyval(bc(i,1:i+1).*v(1:i+1),bb);
            end
        end
        if il==1 % convert unscaled R -> C
            c(:)=y;
        else  % convert C -> R or unscaled R -> R
            r(:)=y;
        end
    end
    % now convert cumulants to/from moments
    if il==1 % convert K -> C
        x=k(:)';
        doit=tin==3 && (tout(1) || tout(2));
    else  % convert C -> K
        x=c(:)';
        doit=(tin<3) && tout(3);
    end
    if doit
        y=x;
        for i=4:n
            mki=mk{i-1}; % get coefficient matrix
            y(i)=mki(:,i-1+il)'*prod(repmat(x(2:i),size(mki,1),1).^mki(:,1:i-1),2); % calculate moment/cumulant (neat but not efficient)
        end
        if il==1 % converted K -> C
            c(:)=y;
        else % converted C -> K
            k(:)=y;
        end
    end
end
c(1)=mu; % restore the means
k(1)=mu;
if any(t=='R')
    c=r;
elseif any(t=='K')
    c=k;
end
