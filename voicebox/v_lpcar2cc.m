function [cc,c0]=v_lpcar2cc(ar,np)
%V_LPCAR2CC LPC: Convert AR filter to complex cepstrum [CC,C0]=(AR,NP)
%
%  Inputs: ar(nf,n+1)   AR coefficients, one frame per row
%          np           Number of cepstral coefficients to calculate [n]
%
% Outputs: cc(nf,np)    Complex cepstral coefficients, excluding c(0)
%          c0(nf,1)     Coefficient c(0)
%
% The "complex cepstral coefficients", cc(n), are the inverse discrete-time Fourier transform
% of the log of the complex-valued spectrum. The cc(n) are real-valued and, for n<0, cc(n)=0.
% The "real cepstral coeffcients", rc(n), are the inverse discrete-time Fourier transform
% of the log of the magnitude spectrum; rc(0)=cc(0) and rc(n)=0.5*cc(n) for n~=0.

%      Copyright (C) Mike Brookes 1998-2014
%      Version: $Id: v_lpcar2cc.m 10865 2018-09-21 17:22:45Z dmb $
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
%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[nf,p1]=size(ar);
p=p1-1;
if (nargin<2) np=p; end
cc=zeros(nf,np);
if any(ar(:,1)~=1)
    c0=-log(ar(:,1));
    ar=ar./ar(:,ones(1,p1));
else
    c0=zeros(nf,1);
end
cm=(1:np).^(-1);
if np>p
    xm=-(1:p);
    nz=np-p;
    for k=1:nf
        cc(k,:)=filter(1,ar(k,:),[ar(k,2:p1).*xm zeros(1,nz)]).*cm;
    end
else
    p1=np+1;
    xm=-(1:np);
    for k=1:nf
        cc(k,:)=filter(1,ar(k,:),ar(k,2:p1).*xm).*cm;
    end
end
if ~nargout
    v_lpccc2pf(cc,[],[],c0);
end
