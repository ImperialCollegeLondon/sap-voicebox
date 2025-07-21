function y=v_logsum(x,d,k)
%V_LOGSUM v_logsum(x,d,k)=log(sum(k.*exp(x),d))
%
% Usage: (1) y=v_logsum(x)                      % log(sum(exp(x)))
%        (2) f=0.1*log(10); y=logsm(x*f)/f;     % add powers expressed in dB
%
% Identities: (1) v_logsum(x+c)=v_logsum(x)+c   % where c is a constant
%             (2) sum(exp(x-logsum(x)))=1       % normalize to make exp(x) sum to 1
%
% Inputs:  X(M,N,...) data matrix to sum
%          D          optional dimension to sum along [1st non-singular dimension]
%          K(M,N,...) optional scaling matrix. It must either be idential
%                     in size to X, or else be a vector whose length is
%                     equal to the size of dimension D of X
%
% Outputs: Y(1,N,...) = log(sum(exp(X).*K,D))
%
% This routine evaluates the given expression for Y but takes care to avoid
% overflow or underflow.

%      Copyright (C) Mike Brookes 1998
%      Version: $Id: v_logsum.m 10865 2018-09-21 17:22:45Z dmb $
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

if nargin==1 || ~numel(d)
    d=[find(size(x)-1) 1];
    d=d(1);
end
n=size(x,d);
if n<=1,            % use efficient computation if only one term in the sum
    if nargin<3
        y=x;
    else
        y=x+log(k);
    end
    return;
end
s=size(x);
p=[d:ndims(x) 1:d-1];
z=reshape(permute(x,p),n,prod(s)/n);
q=max(z,[],1);              % we subtract y from each row to avoid dynamic range problems
a=(q==Inf)|(q==-Inf);       % check for infinities
if nargin<3
    y=q+log(sum(exp(z-q(ones(n,1),:)),1));
elseif numel(k)==n
    y=q+log(sum(exp(z-q(ones(n,1),:)).*repmat(k(:),1,prod(s)/n),1));
else
    y=q+log(sum(exp(z-q(ones(n,1),:)).*reshape(permute(k,p),n,prod(s)/n),1));
end
y(a)=q(a);                  % correct any column whose max is +-Inf
s(d)=1;                     % update the dimension of the summed component
y=ipermute(reshape(y,s(p)),p);

