function [h,l,alg]=v_hypergeom1f1(a,b,z,tol,maxj,th)
%V_HYPERGEOM1F1 Confluent hypergeometric function, 1F1 a.k.a Kummer's M function [h,l]=(a,b,z,tol,maxj)
%
%  Inputs: a,b,z  input arguments
%                 a and b must be real scalars, z can be a real matrix
%                 The function is undefined if b is a non-positive integer
%          tol    Optional tolerance [default 1e-10]
%          maxj   Optional iteration limit [default 500]
%          th    Threshold for choice of algorithm [default 30]
%
% Outputs: h      output result (size of z): 1F1(a;b;z) = M(a;b;z)
%          l      actual number of iterations (size of z)
%          alg     algorithm used
%
% This routine is functionally equivalent to the symbolic toolbox function hypergeom(a,b,z) but much faster.
% The function calculated is the solution to z M'' + (b-z) M' - a M = 0 where
% M' and M'' are 1st and 2nd derivatives of M with respect to z.
% This routine is closely based on taylorb1f1.m from [4] which is explained in Sec 3.2 of [3].
%
% Special cases and relations [2]:
%        M(a;b;z) = Inf for integer b<=0
%        M(a;b;0) = 1
%        M(0;b;z) = 1
%        M(a;a;z) = exp(z)
%        M(1;2;2z) = exp(z)*sinh(z)/z
%        M(a;b;z) = exp(z)*M(b-a;b;-z)    (13.2.39 from [2])
%        M(a;a+1;-z) = exp(z)*M(1;a+1;z) = a*gamma(z,a)/z^a
%        M(a;b;z) = M(a-1;b;z) + M(a;b+1;z)*z/b
%        (b-a)M(a-1,b,z)+(2a-b+z)M(a,b,z)-aM(a+1,b,z)=0     [1] 13.4.1
%        b(b-1)M(a,b-1,z)+b(1-b-z)M(a,b,z)+z(b-a)(a,b+1,z)=0     [1] 13.4.2
%
% References:
% [1]	M. Abramowitz and I. A. Stegun, editors.
%       Handbook of Mathematical Functions with Formulas, Graphs, and Mathematical Tables.
%       Dover, New York, 9 edition, 1964. ISBN 0-486-61272-4.
% [2]	F. W. J. Olver, D. W. Lozier, R. F. Boisvert, and C. W. Clark, editors.
%       NIST Handbook of Mathematical Functions. CUP, 2010. ISBN 978-0-521-14063-8.
% [3]	J. Pearson. Computation of hypergeometric functions. Master's thesis, Oxford University, 2009.
%       URL http://people.maths.ox.ac.uk/porterm/research/-pearson_final.pdf.
% [4]	J. Pearson. Computation of hypergeometric functions. Matlab code, Oxford University, 2009.
%       URL http://people.maths.ox.ac.uk/porterm/research/-hypergeometricpackage.zip.
%

%      Copyright (C) Mike Brookes 2016
%      Version: $Id: v_hypergeom1f1.m 10865 2018-09-21 17:22:45Z dmb $
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
if nargin<4 || isempty(tol)
    tol=1e-10;
end
if nargin<5 || isempty(maxj)
    maxj=500;
end
if nargin<6 || isempty(th)
    th=30;
end
a1=a-1; % define some useful constants
b1=b-1;
ba=b-a;
h=zeros(size(z));
l=zeros(size(z));
nz=numel(z);
for i=1:nz
    y=z(i);
    q=0;  % break criterion initially false
    if abs(y)<th            % small |y|
        % compute using the series from 13.2.2 in [2]
        % sum(j=0:inf,prod(a+(0:j-1)) y^j /(prod(b+(0:j-1)) j!))
        alg=1;
        d=1;
        g=1;
        jlim=0;             % find j beyond which terms definitely decrease
        k=(b1+y)^2-4*(a1)*y;
        if k>=0
            jlim=max(jlim,0.5*(sqrt(k)-(b1+y)));
        end
        k=(b1-y)^2+4*(a1)*y;
        if k>=0
            jlim=max(jlim,0.5*(sqrt(k)-(b1-y)));
        end
        jlim=min(maxj,jlim);
        for j=1:maxj
            d=d*y*(a1+j)/(j*(b1+j));  % d = A(j)-A(j-1) = (A(j-1)-A(j-2))*r(j)*z from [4]
            g=g+d;                      % g = A(j) from [4]
            p=abs(d)<tol*abs(g);
            if q && p && j>=jlim
                break
            end
            q=p;
        end
    elseif y>0 % big positive y
        % see 13.7.1 combined with 13.2.3 [2]. Valid for large y unless a is a non-positive integer
        alg=2;
        d=1;
        g=1;
        jlim=1;             % find j beyond which terms definitely increase
        k=(ba-1-a+y)^2+4*a*(ba-1);
        if k>=0
            jlim=max(jlim,0.5*(sqrt(k)-(ba-a-1+y)));
        end
        k=(ba-a-1-y)^2+4*a*(ba-1);
        if k>=0
            jlim=max(jlim,0.5*(sqrt(k)-(ba-a-1-y)));
        end
        jlim=min(maxj,jlim);
        for j=1:jlim
            d=d*(ba-1+j)*(j-a)/(j*y);
            g=g+d;
            p=abs(d)<tol*abs(g);
            if q && p
                break
            end
            q=p;
        end
        [gl,gs]=v_gammalns([a b]);
        g=gs(1)*gs(2)*exp(y+gl(2)-gl(1)+(a-b)*log(y))*g;
    else   % big negative y
        % Combine M(a;b;z) = exp(z)*M(b-a;b;-z) (13.2.39 from [2]) with algorithm 2
        alg=3;
        d=1;
        g=1;
                jlim=1;             % find j beyond which terms definitely increase
        k=(a1-ba+y)^2+4*a1*ba;
        if k>=0
            jlim=max(jlim,0.5*(sqrt(k)-(a1-ba+y)));
        end
        k=(a1-ba-y)^2+4*a1*ba;
        if k>=0
            jlim=max(jlim,0.5*(sqrt(k)-(a1-ba-y)));
        end
        jlim=min(maxj,jlim);
        for j=1:jlim
            d=d*(a1+j)*(ba-j)/(j*y);
            g=g+d;
            p=abs(d)<tol*abs(g);
            if q && p
                break
            end
            q=p;
        end
        [gl,gs]=v_gammalns([ba b]);
        g=gs(1)*gs(2)*exp(gl(2)-gl(1)-a*log(-y))*g;
    end
    h(i)=g;
    l(i)=j;
end