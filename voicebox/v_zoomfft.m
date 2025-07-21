function [y,f]=v_zoomfft(x,n,m,s,d)
%V_ZOOMFFT    DTFT evaluated over a linear frequency range Y=(X,N,M,S,D)
% Inputs:
%    x    vector (or matrix)
%    n    reciprocal of normalized frequency increment (can be non-integer).
%         The frequency increment is fs/n where fs is the sample frequency
%         [default n=size(x,d)]
%    m    mumber of output points is floor(m) [default m=n]
%    s    starting frequency index (can be non-integer).
%         The starting frequency is s*fs/n [default s=0]
%    d    dimension along which to do fft [default d=first non-singleton]
%
% Outputs:
%    y       Output dtft coefficients. y has the same dimensions as x except
%            that size(y,d)=floor(m).
%    f(1,m)  normalized frequencies (1 corresponds to fs)
%
% This routine allows the evaluation of the DFT over an arbitrary range of
% frequencies; as its name implies this lets you zoom into a narrow portion
% of the spectrum.
% The DTFT of X will be evaluated along dimension D at the M frequencies
% f=fs*(s+(0:m-1))/n where fs is the sample frequency. Note that N and S
% need not be integers although M will be rounded down to an integer.
% Thus v_zoomfft(x,n,n,0,d) is equivalent to fft(x,n,d) for n>=length(x).

% [1] L.R.Rabiner,  R.W.Schafer and C.M.Rader, "The chirp z-transform algorithm"
%     IEEE Trans. Audio Electroacoustics 17 (2), 86�92 (1969). 

%      Copyright (C) Mike Brookes 2007
%      Version: $Id: v_zoomfft.m 10865 2018-09-21 17:22:45Z dmb $
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
persistent n0 k0 s0 m0 b c h g
e=size(x);
p=prod(e);
if nargin<5
    d=find(e>1);
    if ~isempty(d)
        d=d(1);
    else
        d=1;
    end
end
k=e(d);
q=p/k;
if d==1
    z=reshape(x,k,q);
else
    z=shiftdim(x,d-1);
    r=size(z);
    z=reshape(z,k,q);
end
if nargin<2 || isempty(n)
    n=k;
end
if nargin<3 || isempty(m)
    m=floor(n);
else
    m=floor(m);
end
if nargin<4 || isempty(s)
    s=0;
end
l=pow2(nextpow2(m+k-1));    % round up to next power of 2
if n==fix(n) && s==fix(s) && n<2*l && n>=k
    a=fft(z,n,1);           % quickest to do a normal fft
    y=a(1+mod(s:s+m-1,n),:);
else
    % can precaluclate all this for fixed n, k, s and m
    if isempty(b) || n~=n0 || k~=k0 || s~=s0 || m~=m0
        n0=n;
        k0=k;
        s0=s;
        m0=m;
        b=exp(1i*pi*mod((s+(1-k:m-1)').^2,2*n)/n);
        c=conj(b(k:k+m-1));
        h=fft(b,l,1);
        g=exp(-1i*pi*mod(((0:k-1)').^2,2*n)/n);
    end
    a=ifft(fft(z.*repmat(g,1,q),l,1).*repmat(h,1,q)); % calculate correlation
    y=a(k:k+m-1,:).*repmat(c,1,q);
end
if d==1
    e(d)=m;
    y=reshape(y,e);
else
    r(1)=m;
    y=shiftdim(reshape(y,r),length(e)+1-d);
end
f=(s+(0:m-1))/n;