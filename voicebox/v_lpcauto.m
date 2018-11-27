function [ar,e,k]=v_lpcauto(s,p,t,w,m)
%V_LPCAUTO  performs autocorrelation LPC analysis [AR,E,K]=(S,P,T)
% Usage: (1) [ar,e]=v_lpcauto(x,p,[],'r','e'); same as lpc(x,p);

%  Inputs:
%     s(ns,nch)  is the input signal (ns samples, nch channels)
%	  p          is the order (default: 12)
%	  t(nf,3)    specifies the frames size details: each row specifies
%	             up to three values per frame: [len anal skip] where:
%		           len     is the length of the frame (default: length(s))
%		           anal    is the analysis length (default: len)
%		           skip    is the number of samples to skip at the beginning (default: 0)
%	             If t contains only one row, it will be used repeatedly
%	             until there are no more samples left in s.
%     w          window or window type (see v_windows)
%                  Code Window     Sidelobe  3dB-BW  6dB-BW
%                  'c'   cos        -23dB     1.2     1.6  used in MP3
%                  'k'   kaiser(5)  -23dB     1.2     1.7  used in AAC
%                  'm'   hamming    -43dB     1.3     1.8  low sidelobes [default]
%                  'n'   hanning    -31dB     1.4     2.0  rapid falloff
%                  'r'   rectangle  -13dB     0.87    1.2  narrow main lobe
%                  'w'   rsqvorbis  -26dB     1.1     1.5  sqrt Vorbis
%                  's'   hamming    -24dB     1.1     1.5  sqrt Hamming
%                  'v'   vorbis     -21dB     1.3     1.8  used in Vorbis
%     m          set of mode options:
%                  'e'   scale window to make sum of squares = 1
%                  'j'   find a single set of LPC coefficients for all channels
%
% Outputs:
%     ar(nf,p+1,nch) are the AR coefficients with ar(:,1,:) = 1
%     e(nf,nch)      is the energy in the residual.
%                      sqrt(e) is often called the 'gain' of the filter.
%     k(nf,2)        gives the first and last sample of the analysis intervals

% Notes:
%
% (1) The first frame always starts at sample s(1) and the analysis window starts at s(t(1,3)+1).
% (2) The elements of t need not be integers; window parameters will be rounded to the nearest integers.
% (3) The analysis interval is always multiplied by a hamming window
% (4) As an example, if p=3 and t=[10 5 2], then the illustration below shows
%     successive frames labelled a, b, c, ... with capitals for the
%     analysis regions.
%
%	  a a A A A A A a a a b b B B B B B b b b c c C C C C C c c c d ...
%
%     The first frame starts at s(1) and the first analysis interval is t(1,3)+(1:t(1,2)).
%
% (5) Frames can overlap: e.g. t=[5 20] will use analysis frames of
%     length 20 overlapped by 15 samples.
% (6) For speech processing p should be at least 2*f*l/c where f is the sampling
%     frequency, l the vocal tract length and c the speed of sound. For a typical
%     male (l=17 cm) this gives f/1000.

%      Copyright (C) Mike Brookes 1997-2018
%      Version: $Id: v_lpcauto.m 10865 2018-09-21 17:22:45Z dmb $
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
persistent wnam wtypes
if isempty(wnam)
    wnam={'c','k','m','n','r','w','s','v'};
    wtypes=[10 11 3 2 1 8 3 7];
end
[ns,nch]=size(s);
if ns==1
    s = s(:); % transpose if a row vector
    [ns,nch]=size(s);
end
if nargin < 2 || isempty(p)
    p=12;
end
if nargin < 3 || isempty(t)
    t=ns; % default frame is entire signal
end
if nargin <4 || isempty(w)
    w='m'; % default to Hamming window
end
if nargin<5 || isempty(m)
    m='';
end
modee=any(m=='e'); % normalize window to unit energy
modej=any(m=='j'); % do LPC jointly for all channels
wch=ischar(w);
if wch
    if modee
        wopt='e';
    else
        wopt='';
    end
    wch=find(strcmp(w,wnam),1);
else
    w=w(:);
    if modee
        w=w/sqrt(w'*w); % make sum of squares equal to 1
    end
end
[nf,ng]=size(t);
if ng==1
    t=[t t zeros(nf,1)];
elseif ng==2
    t=[t zeros(nf,1)];
end
if nf==1
    nf=floor(1+(ns-t(2)-t(3))/t(1));
    t=repmat(t,nf,1); % repeat t for each frame
end
k=round(repmat(cumsum([0;t(1:nf-1,1)])+t(:,3),1,2)+[ones(nf,1) t(:,2)]); % integer start and end of each analysis frame
kd=k*[-1; 1]+1; % frame lengths
ku=unique(kd);
nk=length(ku); % number of unique frame lengths
if modej % do jointly over all channels
    ar=zeros(p+1,nf); % space for LPC coefficients
    e=zeros(nf,1); % space for residual energy
    for ik=1:nk % loop for each unique frame length
        kui=ku(ik); % analysis frame length
        if wch
            w = v_windows(wtypes(wch),kui,wopt,5)'; % only Kaiser needs a parameter; hence always = 5
        end
        pk=min(p,kui); % actual LPC order for these frames
        km=kd==kui; % mask of frames with this length
        nkm=sum(km); % number of frame with this length
        sk=zeros(kui,nkm,nch); % space for data
        sk(:)=s(repmat(repmat(k(km,1)',kui,1)+repmat((0:kui-1)',1,nkm),[1,1,nch])+reshape(repmat(ns*(0:nch-1),kui*nkm,1),[kui,nkm,nch])).*repmat(w(1:kui),[1,nkm,nch]);
        rr=zeros(pk+1,nkm); % space for autocorrelation coefs
        ark=rr;
        rr(1,:)=sum(sum(sk.^2,1),3); % zero-lag autocorrelation
        rr(2,:)=sum(sum(sk(1:kui-1,:,:).*sk(2:kui,:,:),1),3);
        ark(1,:)=1; % first LPC coefficient is always 1
        ark(2,:)=-rr(2,:)./rr(1,:);
        ek=rr(1,:).*(ark(2,:).^2-1); % **** maybe force non-negative
        for n=2:pk
            rr(n+1,:)=sum(sum(sk(1:kui-n,:,:).*sk(n+1:kui,:,:),1),3); % calculate new autocorrelation term
            ka=(rr(n+1,:)+sum(rr(n:-1:2,:).*ark(2:n,:),1))./ek; % ***** what if ek is zero, could limit to +-1
            % mka=abs(ka)>=1; ka(mka)=sign(ka(mka));
            ark(2:n,:)=ark(2:n,:)+repmat(ka,n-1,1).*ark(n:-1:2,:);
            ark(n+1,:)=ka;
            ek=ek.*(1-ka.^2);
        end
        ar(1:pk+1,km)=ark;
        e(km)=-ek;
    end
    ar=permute(ar,[2 1 3]);
else                            % do each channel independently
    ar=zeros(p+1,nf,nch);       % space for LPC coefficients
    e=zeros(nf,nch);            % space for residual energy
    for ik=1:nk                 % loop for each unique frame length
        kui=ku(ik);             % analysis frame length
        if wch
            w = v_windows(wtypes(wch),kui,wopt,5)'; % only Kaiser needs a parameter; hence always = 5
        end
        pk=min(p,kui);          % actual LPC order for these frames
        km=kd==kui;             % mask of frames with this length
        nkm=sum(km);            % number of frame with this length
        sk=zeros(kui,nkm*nch);  % space for data
        sk(:)=s(repmat(repmat(k(km,1)',kui,1)+repmat((0:kui-1)',1,nkm),1,nch)+reshape(repmat(ns*(0:nch-1),kui*nkm,1),kui,nkm*nch)).*repmat(w(1:kui),1,nkm*nch);
        rr=zeros(pk+1,nkm*nch);	% space for autocorrelation coefs
        ark=rr;
        rr(1,:)=sum(sk.^2,1);   % zero-lag autocorrelation
        rr(2,:)=sum(sk(1:kui-1,:).*sk(2:kui,:),1);
        ark(1,:)=1;             % first LPC coefficient is always 1
        ark(2,:)=-rr(2,:)./rr(1,:);
        ek=rr(1,:).*(ark(2,:).^2-1); % **** maybe force non-negative
        for n=2:pk
            rr(n+1,:)=sum(sk(1:kui-n,:).*sk(n+1:kui,:),1);      % calculate new autocorrelation term
            ka=(rr(n+1,:)+sum(rr(n:-1:2,:).*ark(2:n,:),1))./ek; 
            % could limit to +-1 by doing: mka=abs(ka)>=1; ka(mka)=sign(ka(mka));
            ark(2:n,:)=ark(2:n,:)+repmat(ka,n-1,1).*ark(n:-1:2,:);
            ark(n+1,:)=ka;
            ek=ek.*(1-ka.^2);
        end
        ar(1:pk+1,km,:)=reshape(ark,[pk+1,nkm,nch]);    % insert into output array
        e(km,:)=reshape(-ek,nkm,nch);                   % insert into output array
    end
    ar=permute(ar,[2 1 3]);
end