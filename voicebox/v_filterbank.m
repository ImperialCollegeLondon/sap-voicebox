function [y,zo]=v_filterbank(b,a,x,gd)
%V_FILTERBANK appply v_filterbank to a signal: [y,zo]=(b,a,x,gd)
%
% Inputs:
%    b    numerator coefficients, one row per filter
%    a    denominator coefficients, one row per filter
%    x    input signal
%    gd   group delay of each filter in samples [default=0]. The filter
%         outputs will be advanced to compensate for the group delays.
%         Alternatively, this input can be the zo output from a previous call.
%
% Outputa:
%    y    output signals, one column per filter
%    zo   output filter state

%      Copyright (C) Mike Brookes 2009-2010
%      Version: $Id: v_filterbank.m 10865 2018-09-21 17:22:45Z dmb $
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
nf=size(b,1);           % number of filters
nz=max(size(b,2),size(a,2))-1;  % size of state  needed
zzo=zeros(nz,nf);
nx=length(x);           % number of input samples
xx=x(:);
if nargin<4 || ~numel(gd)
    gd=zeros(nf,1);
end
if isstruct(gd)
    zi=gd.zzo;          % get filter state
    qd=gd.qd;
    sd=qd(2)-qd(1);     % number of output samples we need to save
    qd(3)=qd(3)+nx;
    rd=gd.rd;
    yy=zeros(nx+sd,nf);
    yy(1:sd,:)=gd.sy;
    for i=1:nf
        [yy(sd+1:end,i),zzo(:,i)]=filter(b(i,:),a(i,:),xx,zi(:,i));
    end
else
    qd=zeros(1,3);      % [min-delay max-delay #samples]
    rd=round(gd);
    qd(1)=min(rd);
    qd(2)=max(rd);      % find the largest delay
    qd(3)=nx;           % number of filtered samples
    sd=qd(2)-qd(1);     % number of output samples we need to save
    yy=zeros(nx+sd,nf);
    for i=1:nf
        [yy(sd+1:end,i),zzo(:,i)]=filter(b(i,:),a(i,:),xx);
    end
end
ny=max(0,min(nx,qd(3)-qd(2)));    % numer of output samples
y=zeros(ny,nf);
if ny>0
    for i=1:nf
        off=rd(i)-qd(1);
        y(:,i)=yy(off+1:off+ny,i);
    end
end
if nargout>1
    zo.zzo=zzo;  % filter state
    zo.qd=qd;    % offsets
    zo.rd=rd; % rounded group delays
    zo.sy=yy(end-sd+1:end,:);  % save old outputs
end
if ~nargout   % plot pseudo spectrogram
    ng=300;         % target number of columns in image
    kd=max(1,floor(ny/ng));     % decimation factor
    jm=floor(ny/kd);  % % number f frames
yd=reshape(sum(reshape(y(1:kd*jm,:).^2,kd,nf*jm),1),jm,nf)/kd;
    ydm=max(yd(:));
    imagesc((1:jm)*kd+qd(3)-ny-(kd-1)/2,1:nf,10*log10(max(yd,ydm/1e4))');
    axis('xy');
    colorbar;
    v_cblabel('dB');
    xlabel('Sample Number');
    ylabel('Filter Channel');
    title('Filterbank output');
end
