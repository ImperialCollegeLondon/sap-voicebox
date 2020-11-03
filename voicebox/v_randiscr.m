function x=v_randiscr(p,n,a)
%V_RANDISCR Generate discrete random numbers with specified probabiities [X]=(P,N,A)
%
% Usage: (1) v_randiscr([],10)        % generate 10 uniform random binary values
%        (2) v_randiscr(2:6,10)       % generate 10 random numbers in the range 1:5
%                                       with probabilities [2 3 4 5 6]/20
%        (3) v_randiscr([],10,'abcd') % generate a string of 10 random
%                                       characters equiprobable from 'abcd'
%        (4) v_randiscr([],-3,'abcd') % generate a string of 3 distinct random
%                                       characters equiprobable from 'abcd'
%
% Inputs: P  vector or n-D array of probabilities (not necessarily normalized) [default = uniform]
%         N  number of random values to generate: +ve=with and -ve=without replacement [default = 1]
%         A  output alphabet [default = 1:length(p) or 0:1 if p is empty]
%
% Outputs: X  vector of not necessarily distinct values taken from alphabet A
%             If A is omitted and P is a matrix, each row of X(N,M) will contain the M coordinates
%             of a random element of P.
%
% The vector P is internally normalized by dividing by its sum.

% Somewhat similar in function to RANDSRC in the comms toolbox

% Revisions:
%   2020-08-01 Fixed error when n=-(alphabet size)
%   2020-11-03 Clarified comments and speeded up non-replacement sampling
%              with uniform probabilities
%
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
if gota && d~=numel(a)
    error('sizes of alphabet and probability vector/matrix must match');
end
if n>1                          % sample with replacement
    dn=d+n-1;
    z=zeros(dn,1);            	% array to hold random numbers
    z(1:d)=cumsum(q/sum(q));   	% last value is overwritten in the next line
    z(d:end)=rand(n,1);         % create a random number for each sample
    [y,iy]=sort(z);             % the original entries z(1:d-1) now divide the samples into bins for each possible value
    y(iy)=(1:dn)';             	% create inverse index
    m=zeros(dn,1);
    m(y(1:d-1))=1;             	% set original initial d-1 values to 1
    m(1)=m(1)+1;                % and also the first value
    m=cumsum(m);                % label each of the random nuumbers with its corresponding value in 1:d
    x=m(y(d:dn));               % find the partitions of the n random numbers
else                            % sample without replacement
    n=abs(n);                   % number of samples needed
    if n>d
        error('Number of output samples exceeds alphabet size');
    end
    if all(q==q(1))             % if all probabilities are equal
        [y,iy]=sort(rand(d,1)); % iy is a random permutation of 1:d
        x=iy(1:n);              % select the first n values
    else
        f=(1:d)';               % initialize the alphabet to 1:d
        x=zeros(n,1);           % space for the output samples
        nn=n;                   % number of samples remaining
        while nn>0              % number of samples remaining
            dd=numel(f);        % alphabet size (always >=nn)
            if dd==1            % singleton alphabet
                x(n)=f;         % set remaining sample to the only remaining value
                nn=0;           % and set remaining value count to zero
            else
                qq=q(f);                        % remaiing alphabet probabilities
                dn=dd+nn-1;
                z=zeros(dn,1);                  % array to hold random numbers
                z(1:dd)=cumsum(qq/sum(qq));     % last value is overwritten in the next line
                z(dd:dn)=rand(nn,1);            % create a random number for each sample
                [y,iy]=sort(z);                 % the original entries z(1:dd-1) now divide the samples into bins for each possible value
                y(iy)=(1:dn)';                  % create inverse index
                m=zeros(dn,1);
                m(y(1:dd-1))=1;               	% set original initial dd-1 values to 1
                m(1)=m(1)+1;                    % and also the first value
                m=cumsum(m);                    % label each of the random nuumbers with its corresponding value in 1:dd
                z=m(y(dd:dn));                  % find the partitions of the nn random numbers
                [y,iy]=sort(z);                 % sorts the positions within each partition
                z(iy(1+find(y(1:nn-1)==y(2:nn))))=[];          % keep only the first sample from each partition
                k=numel(z);                     % number of new samples
                x(n-nn+1:n-nn+k)=f(z);          % add new samples into output array
                nn=nn-k;                        % number of remaining samples
                f(z)=[];                        % remove used entries from alphabet
            end
        end
    end
end
if gota
    x=a(x);                                     % select from output alphabet
elseif length(q)>length(p)                      % need multiple dimensions
    v=x-1;
    s=cumprod(size(p));
    m=length(s);
    s(2:end)=s(1:end-1);
    s(1)=1;
    x=zeros(n,m);
    for i=m:-1:1
        x(:,i)=1+floor(v/s(i));                 % find indices starting with the last
        v=rem(v,s(i));
    end
end