function [y,ty]=v_correlogram(x,inc,nw,nlag,m,fs)
%V_CORRELOGRAM calculate correlogram [y,ty]=(x,inc,nw,nlag,m,fs)
% Usage:
%        do_env=1; do_hp=1;                            % flags to control options
%        [b,a,fx,bx,gd]=v_gammabank(25,fs,'',[80 5000]); % determine v_filterbank
%        y=v_filterbank(b,a,s,gd);                       % filter signal s
%        if do_env
%            [bl,al]=butter(3,2*800/fs);
%            y=filter(bl,al,v_teager(y,1),[],1);           % low pass envelope @ 800 Hz
%        end
%        if do_hp
%            y=filter(fir1(round(16e-3*fs),2*64/fs,'high'),1,y,[],1);  % HP filter @ 64 Hz
%        end
%        v_correlogram(y,round(10e-3*fs),round(16e-3*fs),round(12e-3*fs),'',fs);
%
% Inputs:
%        x(*,chan)  is the output of a filterbank (e.g. v_filterbank)
%                   with one column per filter channel
%        inc        frame increment in samples
%        nw         window length in samples [or window function]
%        nlag       number of lags to calculate
%        m          mode string:
%               'h' = Hamming window
%        fs         sample freq (affects only plots)
%
% Outputs:
%        y(lag,chan,frame) is v_correlogram. Lags are 1:nlag samples
%        ty                is time of the window energy centre for each frame
%                            x(n) is at time n
%
% For each channel, the calculated correlation for frame n comprises
%       y(t+1,*,n+1)=(win.*x(n*inc+(1:nw))'*x(n*inc+t+(1:nw))/sqrt(win'*abs(x(n*inc+(1:nw))).^2 * win'*abs(x(n*inc+t+(1:nw))).^2)
% This corresponds to the expression in (1.7) of [1] but incorporating the normalization from (1) of [2].
%
% Future planned mode options:
%       'd' = subtract DC component
%       'n' = unnormalized
%       'v' = variable analysis window proportional to lag
%       'p' = output the peaks only
%
% Refs:
% [1]	D. Wang and G. J. Brown. Fundamentals of computational auditory scene analysis.
%       In D. Wang and G. Brown, editors, Computational Auditory Scene Analysis: Principles,
%       Algorithms, and Applications, chapter 1. Wiley, Oct. 2006. doi: 10.1109/9780470043387.ch1
% [2]	S. Granqvist and B. Hammarberg. The correlogram: a visual display of periodicity. J. Acoust. Soc. Amer., 114: 2934, 2003.

%      Copyright (C) Mike Brookes 2011-2018
%      Version: $Id: v_correlogram.m 10867 2018-09-21 17:35:59Z dmb $
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
memsize=v_voicebox('memsize'); 	% set memory size to use
[nx,nc]=size(x);                % number of sampes and channels
if nargin<6
    fs=1;                       % default sample frequency is 1 Hz
    if nargin<5
        m='h';                  % default analysis window is Hamming
        if nargin<4
            nlag=[];
            if nargin<3
                nw=[];
                if nargin<2
                    inc=[];
                end
            end
        end
    end
end
if ~numel(inc)
    inc=128;                    % default frame hop is 128 samples
end
if ~numel(nw)
    nw=inc;                     % default analysis window length is the fame increment
end
nwin=length(nw);
if nwin>1                       % nw specifies the window function explicitly
    win=nw(:);
else                            % nw gives the window length
    nwin=nw;
    if any(m=='h')
        win=v_windows(3,nwin)'; % Hamming window
    else
        win=ones(nwin,1);       % window function
    end
end
if ~numel(nlag)
    nlag=nwin;
end
nwl=nwin+nlag-1;
nt=pow2(nextpow2(nwl));         % transform length
nf=floor((nx-nwl+inc)/inc);     % number of frames
i1=repmat((1:nwl)',1,nc)+repmat(0:nx:nx*nc-1,nwl,1);
nb=min(nf,max(1,floor(memsize/(16*nwl*nc))));    % chunk size for calculating
nl=ceil(nf/nb);                  % number of chunks
jx0=nf-(nl-1)*nb;                % size of first chunk in frames
wincg=(1:nwin)*win.^2/(win'*win); % determine window centre of energy
fwin=conj(fft(win,nt,1));       % conjugate fft of window
y=zeros(nlag,nc,nf);
% first do partial chunk
jx=jx0;
x2=zeros(nwl,nc*jx);
x2(:)=x(repmat(i1(:),1,jx)+repmat((0:jx-1)*inc,nwl*nc,1));
% the next line was previously: v=ifft(conj(fft(x2(1:nwin,:),nt,1)).*fft(x2,nt,1));
v=ifft(conj(fft(x2(1:nwin,:).*repmat(win(:),1,nc*jx),nt,1)).*fft(x2,nt,1));                 % v(1:nlag,:) contains second half of xcorr(x2) output
w=max(real(ifft(fwin(:,ones(1,nc*jx)).*fft(x2.*conj(x2),nt,1))),0); % v(1:nlag,:) contains second half of xcorr(|x2|^2,win) output
w=sqrt(w(1:nlag,:).*w(ones(nlag,1),:));
if isreal(x)
    y(:,:,1:jx)=reshape(real(v(1:nlag,:))./w,nlag,nc,jx); % note: some values may be NaN is x=0 throughout the window
else
    y(:,:,1:jx)=reshape(conj(v(1:nlag,:))./w,nlag,nc,jx);
end
% now do remaining chunks
x2=zeros(nwl,nc*nb);
for il=2:nl
    ix=jx+1;            % first frame in this chunk
    jx=jx+nb;           % last frame in this chunk
    x2(:)=x(repmat(i1(:),1,nb)+repmat((ix-1:jx-1)*inc,nwl*nc,1));
    % the next line was previously: v=ifft(conj(fft(x2(1:nwin,:),nt,1)).*fft(x2,nt,1));
    v=ifft(conj(fft(x2(1:nwin,:).*repmat(win(:),1,nc*nb),nt,1)).*fft(x2,nt,1));
    w=max(real(ifft(fwin(:,ones(1,nc*nb)).*fft(x2.*conj(x2),nt,1))),0);
    w=sqrt(w(1:nlag,:).*w(ones(nlag,1),:));
    if isreal(x)
        y(:,:,ix:jx)=reshape(real(v(1:nlag,:))./w,nlag,nc,nb);
    else
        y(:,:,ix:jx)=reshape(conj(v(1:nlag,:))./w,nlag,nc,nb);
    end
end
ty=(0:nf-1)'*inc+wincg;       % calculate times of window centres
if ~nargout
    imagesc(ty/fs,(1:nlag)/fs,squeeze(mean(abs(y),2)));
    if nargin<6
        us='samp';
    else
        us='s';
    end
    xlabel(['Time (' v_xticksi us ')']);
    ylabel(['Lag (' v_yticksi us ')']);
    axis 'xy';
    v_colormap('v_thermliny');
    colorbar;
    v_cblabel('Mean Correlation');
    title('Summary Correlogram');
end


