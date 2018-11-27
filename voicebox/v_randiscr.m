function x=v_randiscr(p,n,a)
%V_RANDISCR Generate discrete random numbers with specified probabiities [X]=(P,N,A)
%
% Usage: (1) v_randiscr([],10)        % generate 10 uniform random binary values
%        (2) v_randiscr(2:6,10)       % generate 10 random numbers in the range 1:5
%                                     with probabilities [2 3 4 5 6]/20
%        (3) v_randiscr([],10,'abcd') % generate a string of 10 random
%                                     characters equiprobable from 'abcd'
%        (4) v_randiscr([],-3,'abcd') % generate a string of 3 distinct random
%                                     characters equiprobable from 'abcd'
%
% Inputs: P  vector or n-D array of probabilities (not necessarily normalized) [default = uniform]
%         N  number of random values to generate: +ve=with and -ve=without replacement [default = 1]
%         A  output alphabet [default = 1:length(p) or 0:1 if p is empty]
%
% Outputs: X  vector of not necessarily distinct values taken from alphabet A
%             If P is not a vector, each row of X will contain the coordinates
%             of an element of P
%
% The vector P is internally normalized by dividing by its sum.
% If P is an M-dimensional matrix (and A is unspecified), then X will
% have dimensions (N,M) with the corresponding indices for each dimension.

% Somewhat similar in function to RANDSRC in the comms toolbox

%   Copyright (c) 2005-2012 Mike Brookes,  mike.brookes@ic.ac.uk
%      Version: $Id: v_randiscr.m 10865 2018-09-21 17:22:45Z dmb $
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
gota=nargin>2;
if nargin<1 || ~numel(p)
    if gota
        p=ones(1,length(a));
    else
        p=ones(1,2);
        a=(0:1)';
        gota=1;
    end
end
if nargin<2 || ~numel(n)
    n=1;
end
q=p(:);
d=length(q);                    % size of output alphabet
if n>1                          % sample with replacement
    dn=d+n-1;
    z=zeros(dn,1);               % array to hold random numbers
    z(1:d)=cumsum(q/sum(q));        % last value is actually overwritten in the next line
    z(d:end)=rand(n,1);
    [y,iy]=sort(z);
    y(iy)=(1:dn)';               % create inverse index
    m=zeros(dn,1);
    m(y(1:d-1))=1;                  % set original initial d-1 values to 1
    m(1)=m(1)+1;
    m=cumsum(m);
    x=m(y(d:dn));               % find the positions of the random numbers
else                            % sample without replacement
    n=abs(n);
    f=(1:d)'; % list of possible outputs
    if n>d
        error('Number of output samples exceeds alphabet size');
    end
    
    nn=n; % number of samples remaining
    x=zeros(nn,1); % space for the output samples
    while nn>0
        dd=numel(f); % alphabet size
        qq=q(f); % alphabet probabilities
        if dd==1 % singleton alphabet
            x(n)=f;
        else
            dn=dd+nn-1;
            z=zeros(dn,1);               % array to hold random numbers
            z(1:dd)=cumsum(qq/sum(qq));        % last value is actually overwritten in the next line
            z(dd:dn)=rand(nn,1);
            [y,iy]=sort(z);
            y(iy)=(1:dn)';               % create inverse index
            m=zeros(dn,1);
            m(y(1:dd-1))=1;                  % set original initial d-1 values to 1
            m(1)=m(1)+1;
            m=cumsum(m);
            z=m(y(dd:dn));               % find the positions of the random numbers
            [y,iy]=sort(z);
            z(iy(1+find(y(1:nn-1)==y(2:nn))))=[];          % remove non-unique values
            k=numel(z); % number of new values
            x(n-nn+1:n-nn+k)=f(z);
            nn=nn-k;  % number of remaining samples
            f(z)=[]; % remove from alphabet
        end
    end
end
if gota
    x=a(x);                     % select from output alphabet
elseif length(q)>length(p)      % need multiple dimensions
    v=x-1;
    s=cumprod(size(p));
    m=length(s);
    s(2:end)=s(1:end-1);
    s(1)=1;
    x=zeros(n,m);
    for i=m:-1:1
        x(:,i)=1+floor(v/s(i)); % find indices starting with the last
        v=rem(v,s(i));
    end
end