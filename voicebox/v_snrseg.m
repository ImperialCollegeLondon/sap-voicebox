function [seg,glo,tc,snf,vf]=v_snrseg(s,r,fs,m,tf)
%V_SNRSEG Measure segmental and global SNR [SEG,GLO]=(S,R,FS,M,TF)
%
%Usage: (1) seg=v_snrseg(s,r,fs);                  % s & r are noisy and clean signal
%       (2) seg=v_snrseg(s,r,fs,'wz');             % no VAD or inerpolation used ['Vq' is default]
%       (3) [seg,glo]=v_snrseg(s,r,fs,'Vq',0.03);  % 30 ms frames
%
% Inputs:    s  test signal
%            r  reference signal
%           fs  sample frequency (Hz)
%            m  mode [default = 'Vq']
%                 w = No VAD - use whole file
%                 v = use sohn VAD to discard silent portions
%                 V = use P.56-based VAD to discard silent portions [default]
%                 a = A-weight the signals
%                 b = weight signals by BS-468
%                 q = use linear interpolation to remove delays +- 1 sample [default]
%                 z = do not do any alignment
%                 p = plot results
%           tf  frame increment [0.01]
%
% Outputs: seg = Segmental SNR in dB
%          glo = Global SNR in dB (typically 7 dB greater than SNR-seg)
%          tc  = time at centre of each frame (seconds)
%          snf = Segmental SNR in dB in each frame
%          vf  = Boolean mask indicating frames that valid (from VAD)
%
% This function compares a noisy signal, S, with a clean reference, R, and
% computes the segemntal signal-to-noise ratio (SNR) in dB. The signals,
% which must be of the same length, are split into non-overlapping frames
% of length TF (default 10 ms) and the SNR of each frame in dB is calculated.
% The segmental SNR is the average of these values, i.e.
%         SEG = mean(10*log10(sum(Ri^2)/sum((Si-Ri)^2))
% where the mean is over frames and the sum runs over one particular frame.
% Two optional modifications can be made to this basic formula:
%
%    (a) Frames are excluded if there is no significant energy in the R
%        signal. The idea is to limit the calculation to frames in which
%        speech is active. By default, the v_voicebox function "v_activlev" is
%        used to detect the inactive frames (the 'V' mode option).
%
%    (b) In each frame independently, the reference signal is shifted by up
%        to +- 1 sample to find the alignment than minimizes the noise
%        component (S-R)^2. This shifting accounts for small misalignments
%        and/or sample frequency differences between the two signals. For
%        larger shifts, you can use the v_voicebox function "v_sigalign".
%        Accurate alignemnt is especially important at high SNR values.
%
% If no M argument is specified, both these modifications will be applied;
% this is equivalent to specifying M='Vq'.

% Bugs/suggestions
% (1) Optionally restrict the bandwidth to the smaller of the two
%     bandwidths either with an extra parameter or automatically determined
% (2) Optionally apply a gain to the s signal to maximize the SNR and
%     output the gain as an additional parameter

%      Copyright (C) Mike Brookes 2011
%      Version: $Id: v_snrseg.m 10865 2018-09-21 17:22:45Z dmb $
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

if nargin<4 || ~ischar(m)
    m='Vq';
end
if nargin<5 || ~numel(tf)
    tf=0.01;                                            % default frame length is 10 ms
end
snmax=100;                                              % clipping limit for SNR

% filter the input signals if required

if any(m=='a')                                          % A-weighting
    [b,a]=v_stdspectrum(2,'z',fs);                      % create bandpass filter
    s=filter(b,a,s);                                    % filter test signal
    r=filter(b,a,r);                                    % filter reference signal
elseif any(m=='b')                                      %  BS-468 weighting
    [b,a]=v_stdspectrum(8,'z',fs);                      % create bandpass filter
    s=filter(b,a,s);                                    % filter test signal
    r=filter(b,a,r);                                    % filter reference signal
end

mq=~any(m=='z');                                        % flag indicating we need to do alignment
nr=min(length(r), length(s));                           % signal length to align
kf=round(tf*fs);                                        % length of frame in samples
ifr=kf+mq:kf:nr-mq;                                     % ending sample of each frame (allowing +-mq at each end)
ifl=ifr(end);                                           % end sample of last frame
nf=numel(ifr);                                          % number of frames
if mq                                                   % perform linear interpolation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Consider the linearly interpolated signal sm(i)=(1-am)*s(i)+am*s(i+1) where 0<=am<=1.     %
    % For each frame we calculate the value of am that minimizes the error sum((sm(i)-r(i))^2). %
    % The solution is am = sum((s(i)-r(i)).*(s(i)-s(i+1))) / sum((s(i)-s(i+1))^2).              %
    % Similarly, we calculate the optimum ap in sp(i)=(1-ap)*s(i)+ap*s(i-1) and then            %
    % finally, we select whichever of sm(i) and sp(i) with the lowest error.                    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ssm=reshape(s(2:ifl)-s(3:ifl+1),kf,nf);
    ssp=reshape(s(2:ifl)-s(1:ifl-1),kf,nf);
    sr=reshape(s(2:ifl)-r(2:ifl),kf,nf);                % enframed error: test-ref (one frame per column)
    am=min(max(sum(sr.*ssm,1)./sum(ssm.^2,1),0),1);     % optimum dist between s(2:ifl) and s(3:ifl+1)
    ap=min(max(sum(sr.*ssp,1)./sum(ssp.^2,1),0),1);     % optimum dist between s(2:ifl) and s(1:ifl-1)
    ef=min(sum((sr-repmat(am,kf,1).*ssm).^2,1),sum((sr-repmat(ap,kf,1).*ssp).^2,1)); % select the best for each frame
else                                                    % no interpolation
    ef=sum(reshape((s(1:ifl)-r(1:ifl)).^2,kf,nf),1);    % sum of squared errors in each frame
end
rf=sum(reshape(r(mq+1:ifl).^2,kf,nf),1);                % sum of sqared reference signal in each frame
em=ef==0;                                               % mask for zero noise frames
rm=rf==0;                                               % mask for zero reference frames
snf=10*log10((rf+rm)./(ef+em));
snf(rm)=-snmax;
snf(em)=snmax;

% select the frames to include

if any(m=='w')                                          % 'w' option: do not discard silent frames
    vf=true(1,nf);                                      % include all frames
elseif any(m=='v')                                      % 'v' option: use Sohn VAD to discard silent frames
    vs=v_vadsohn(r,fs,'na');
    nvs=length(vs);
    [vss,vix]=sort([ifr'; vs(:,2)]);
    vjx=zeros(nvs+nf,5);
    vjx(vix,1)=(1:nvs+nf)';                             % sorted position
    vjx(1:nf,2)=vjx(1:nf,1)-(1:nf)';                    % prev VAD frame end (or 0 or nvs+1 if none)
    vjx(nf+1:end,2)=vjx(nf+1:end,1)-(1:nvs)';           % prev snr frame end (or 0 or nvs+1 if none)
    dvs=[vss(1)-mq; vss(2:end)-vss(1:end-1)];           % number of samples from previous frame boundary
    vjx(:,3)=dvs(vjx(:,1));                             % number of samples from previous frame boundary
    vjx(1:nf,4)=vs(min(1+vjx(1:nf,2),nvs),3);           % VAD result for samples between prev frame boundary and this one
    vjx(nf+1:end,4)=vs(:,3);                            % VAD result for samples between prev frame boundary and this one
    vjx(1:nf,5)=1:nf;                                   % SNR frame to accumulate into
    vjx(vjx(nf+1:end,2)>=nf,3)=0;                       % zap any VAD frame beyond the last snr frame
    vjx(nf+1:end,5)=min(vjx(nf+1:end,2)+1,nf);          % SNR frame to accumulate into
    vf=full(sparse(1,vjx(:,5),vjx(:,3).*vjx(:,4),1,nf))>kf/2; % accumulate into SNR frames and compare with threshold
else                                                    % default is 'V': use P.56 VAD to discard silent frames
    [lev,af,fso,vad]=v_activlev(r,fs);                  % do VAD on reference signal
    vf=sum(reshape(vad(mq+1:ifl),kf,nf),1)>kf/2;        % find frames that are mostly active
    tc=((1:nf)*kf+(1-kf)/2)/fs;                         % time at centre of frame
end
seg=mean(snf(vf));
glo=10*log10(sum(rf(vf))/sum(ef(vf)));
if ~nargout || any (m=='p')
    subplot(312);                                       % plot reference signal
    plot((1:length(r))/fs,r);
    ylabel('Reference');
    axh(2)=gca;
    subplot(313);                                       % plot SNR + global and segmental means
    snv=snf;
    snv(~vf)=NaN;                                       % plot valid frames in blue
    snu=snf;
    snu(vf>0)=NaN;                                      % plot invalid frames in red
    plot([1 nr]/fs,[glo seg; glo seg],':k',tc,snv,'-b',tc,snu,'-r');
    ylabel('Frame SNR');
    xlabel('Time (s)');
    set(gca,'ylim',min([snv(:);snu(:)])+[-3 60]);       % restrict displayed SNR range
    axh(3)=gca;
    subplot(311);                                       % plot test signal
    plot((1:length(s))/fs,s);
    ylabel('Signal');
    title(sprintf('SNR = %.1f dB, SNR_{seg} = %.1f dB',glo,seg));
    axh(1)=gca;
    linkaxes(axh,'x');                                  % link time axes
    linkaxes(axh(1:2),'y');                             % link signal amplitude axes
    set(gca,'xlim',[1 nr]/fs);
end