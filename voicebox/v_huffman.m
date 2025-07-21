function [cc,ll,l]=v_huffman(p,a)
%V_HUFFMAN calculates a D-ary v_huffman code [CC,LL]=(P,A)
%
%  Inputs:  P        is a vector or matrix of probabilities
%           A(D)     is a vector of alphabet characters either integers of chars [default: '01']
%                    the length of A determines the order of the code
%
% Outputs:  CC       is a cell array containing the code for each symbol with the sme shape as P
%           LL       is a vector or matrix of code lengths with the sme shape as P
%           L        is the average code length

%	   Copyright (C) Mike Brookes 1995
%      Version: $Id: v_huffman.m 10865 2018-09-21 17:22:45Z dmb $
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

np=length(p(:));
if nargin <2
    a='01';
end
d=length(a);

% first append additional zeros-probability symbols to ensure a full code tree

nx=np+mod(1-np,d-1);
px=zeros(nx,1);
px(1:np)=p(:);

cl=(nx-1)/(d-1);        % max potential code length
cd=zeros(nx,cl);        % code array
qx=px;
ix=(1:nx)';
dd=(d:-1:1)';
kx=zeros(nx,1);
for i=cl:-1:1
    nc=1+i*(d-1);
    [rx,jx]=sort(qx);   % find the D smallest probabilities
    kx(jx)=(1:nc)';          % create a reverse index
    cd(:,i)=kx(ix);     
    ix=max(kx(ix)-d+1,1);
    rx(d)=sum(rx(1:d));
    qx=rx(d:end);
end
cc=cell(size(p));
ll=zeros(size(p));
for i=1:np
    ci=cd(i,cd(i,:)<=d);
    ll(i) = length(ci);
    cc{i}=a(ci);
end
l=p(:)'*ll(:)/sum(p(:));      % calculate average length