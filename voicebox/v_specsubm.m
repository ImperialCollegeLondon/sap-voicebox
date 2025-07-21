function [ss,po]=v_specsubm(s,fs,p)
%V_SPECSUBM obsolete speech enhancement algorithm - use v_specsub instead
%
% implementation of spectral subtraction algorithm by R Martin (rather slow)
% algorithm parameters: t* in seconds, f* in Hz, k* dimensionless
% 1: tg = smoothing time constant for signal power estimate (0.04): high=reverberant, low=musical
% 2: ta = smoothing time constant for signal power estimate
%        used in noise estimation (0.1)
% 3: tw = fft window length (will be rounded up to 2^nw samples)
% 4: tm = length of minimum filter (1.5): high=slow response to noise increase, low=distortion
% 5: to = time constant for oversubtraction factor (0.08)
% 6: fo = oversubtraction corner frequency (800): high=distortion, low=musical
% 7: km = number of minimisation buffers to use (4): high=waste memory, low=noise modulation
% 8: ks = oversampling constant (4)
% 9: kn = noise estimate compensation (1.5)
% 10:kf = subtraction floor (0.02): high=noisy, low=musical
% 11:ko = oversubtraction scale factor (4): high=distortion, low=musical
%
% Refs:
%    (a) R. Martin. Spectral subtraction based on minimum statistics. In Proc EUSIPCO, pages 1182-1185, Edinburgh, Sept 1994.
%    (b) R. Martin. Noise power spectral density estimation based on optimal smoothing and minimum statistics.
%        IEEE Trans. Speech and Audio Processing, 9(5):504-512, July 2001.


%      Copyright (C) Mike Brookes 2004
%      Version: $Id: v_specsubm.m 10865 2018-09-21 17:22:45Z dmb $
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

if nargin<3 po=[0.04 0.1 0.032 1.5 0.08 400 4 4 1.5 0.02 4].'; else po=p; end
ns=length(s);
ts=1/fs;
ss=zeros(ns,1);

ni=pow2(nextpow2(fs*po(3)/po(8)));
ti=ni/fs;
nw=ni*po(8);
nf=1+floor((ns-nw)/ni);
nm=ceil(fs*po(4)/(ni*po(7)));

win=0.5*hamming(nw+1)/1.08;win(end)=[];
zg=exp(-ti/po(1));
za=exp(-ti/po(2));
zo=exp(-ti/po(5));

px=zeros(1+nw/2,1);
pxn=px;
os=px;
mb=ones(1+nw/2,po(7))*nw/2;
im=0;
osf=po(11)*(1+(0:nw/2).'*fs/(nw*po(6))).^(-1);

imidx=[13 21]';
x2im=zeros(length(imidx),nf);
osim=x2im;
pnim=x2im;
pxnim=x2im;
qim=x2im;

for is=1:nf
   idx=(1:nw)+(is-1)*ni;
   x=v_rfft(s(idx).*win);
   x2=x.*conj(x);
   
   pxn=za*pxn+(1-za)*x2;
   im=rem(im+1,nm);
   if im
      mb(:,1)=min(mb(:,1),pxn);
   else
      mb=[pxn,mb(:,1:po(7)-1)];
   end
   pn=po(9)*min(mb,[],2);
   %os= oversubtraction factor
   os=zo*os+(1-zo)*(1+osf.*pn./(pn+pxn));
   
   px=zg*px+(1-zg)*x2;
   q=max(po(10)*sqrt(pn./x2),1-sqrt(os.*pn./px)); 
   ss(idx)=ss(idx)+v_irfft(x.*q);
   
end
if nargout==0
   soundsc([s; ss],fs);
end




