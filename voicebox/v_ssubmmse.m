function [ss,gg,tt,ff,zo]=v_ssubmmse(si,fsz,pp)
%V_SSUBMMSE performs speech enhancement using mmse estimate of spectral amplitude or log amplitude [SS,ZO]=(S,FSZ,PP)
%
% Usage:
%    (1) %%%%%%%%%%%% Simple Enhancement %%%%%%%%%%%%
%        y=v_ssubmmse(x,fs);               % enhance the noisy speech using default parameters
%
%    (2) %%%%%%%%%%%% Reading input signal in chunks %%%%%%%%%%%%
%        [y1,zo]=v_ssubmmse(x(1:1000,fs);       % enhance the first chunck of x
%        [y2,zo]=v_ssubmmse(x(1001:2000),zo);   % enhance the second  chunck of x
%        y3=v_ssubmmse(x(1001:2000),zo);        % enhance the remainder of x outputting all samples
%        y=[y1; y2; y3];                      % reassembling the chunks gives same y as example (1)
%
%    (3) %%%%%%%%%%%% Multiple channels using the same gain %%%%%%%%%%%%
%        y=v_ssubmmse([s+n s n],fs);       % enhance the noisy speech, s+n, and
%                                          also apply the same gain to s and n separately
%
%    (4) %%%%%%%%%%%% Multiple channels using maximum of gains %%%%%%%%%%%%
%        pp.gw=[0 0 0 0 1];              % find the maximum of the calculated time-frequency gains
%        y=v_ssubmmse([x1 x2 x3],fs,pp);   % and apply this maximum gain to each of the signals
%
%    (5) %%%%%%%%%%%% Plot gain function %%%%%%%%%%%%
%        [y,g,t,f]=v_ssubmmse(x,fs);       % save the time-frequency gain function
%        imagesc(t,f,20*log10(g'));      % display the time-frequency gain
%        axis 'xy';                      % origin at bottom left
%        xlabel('Time (s)');             % time axis
%        ylabel('Frequency (Hz)');       % frequency axis
%        colorbar;                       % show a color bar
%        v_cblabel('Gain dB');             % label the color bar
%        set(gca,'clim',[-30,5]);        % limit the displayed range to [-30,5] dB
%
%
% Inputs:
%   si(n,c,p) input speech signal with n samples in each of c channels where each channel has p planes.
%             All planes will use the same set of gain functions.
%   fsz       sample frequency in Hz
%             Alternatively, the input state from a previous call (see below)
%   pp        algorithm parameters [optional]
%
% Outputs:
%   ss(n,c,p)   output enhanced speech. Same number of samples as si unless
%               zo output is given in which case incomplete frames will be retained
%   gg(t,f,c,p,length(pp.tf)) selected time-frequency values (see pp.tf below)
%               note that multiple planes will only be included if pp.tf  includes 'i', 'I', 'o' or 'O'
%               Note also that the tt output MUST also be specified
%   tt          centre of frames (in seconds)
%   ff          centre of frequency bins (in Hz)
%   zo          output state (or the 2nd argument if gg,tt,ff are omitted)
%
% The algorithm operation is controlled by a small number of parameters:
%
%        pp.of          % overlap factor = (fft length)/(frame increment) [2]
%        pp.ti          % desired frame increment [0.016 seconds]
%        pp.ri          % set to 1 to round ti to the nearest power of 2 samples [0]
%        pp.ta          % time const for smoothing SNR estimate [0.396 seconds]
%        pp.gx          % maximum posterior SNR as a power ratio [1000 = +30dB]
%        pp.gn          % min posterior SNR as a power ratio when estimating prior SNR [1 = 0dB]
%        pp.gz          % min posterior SNR as a power ratio [0.001 = -30dB]
%        pp.xn          % minimum prior SNR [0]
%        pp.xb          % bias compensation factor for prior SNR [1]
%        pp.lg          % MMSE target: 0=amplitude, 1=log amplitude, 2=perceptual Bayes [1]
%        pp.ne          % noise estimation: 0=min statistics, 1=MMSE [1]
%        pp.bt          % threshold for binary gain or -1 for continuous gain [-1]
%        pp.mx          % input mixture gain [0]
%        pp.gc          % maximum amplitude gain [10 = 20 dB]
%        pp.rf          % round output signal to an exact number of frames [0]
%        pp.gw          % multichannel gain weights: [chan-n chan-1 ave min max] default:[0 1 0 0 0]
%        pp.tf          % selects one or more time-frequency planes to output in the gg() variable ['g']
%                           'i' = input power spectrum
%                           'I' = input complex spectrum
%                           'n' = noise power spectrum
%                           'z' = "posterior" SNR (i.e. (S+N)/N )
%                           'x' = "prior" SNR (i.e. S/N )
%                           'G' = raw gain (before clipping and multichannel weighting)
%                           'g' = final gain
%                           'o' = output power spectrum
%                           'O' = output complex spectrum
%
% The applied gain is mx+(1-mx)*optgain where optgain is calculated according to [1] or [2].
% If pp.bt>=0 then optgain is first thresholded with pp.bt to produce a binary gain 0 or 1.
%
% The default parameters implement the original algorithm in [1,2].
%
% Several parameters relate to the estimation of xi, the so-called "prior SNR",
%
%             xi=max(a*pp.xb*xu+(1-a)*max(gami-1,pp.gn-1),pp.xn);
%
% This is estimated as a smoothed version of 1 less than gami, the "posterior SNR"
% which is the noisy speech power divided by the noise power. This is
% clipped to a min of (pp.gn-1), smoothed using a factor "a" which corresponds to a
% time-constant of pp.ta and then clipped to a minimum of pp.xn. The
% previous value is taken to be pp.xb*xu where xu is the ratio of the
% estimated speech amplitude squared to the noise power.
%
% In addition it is possible to specify parameters for the noise estimation algorithm
% which implements reference [3] or [7] according to the setting of pp.ne
%
% Minimum statistics noise estimate [3]: pp.ne=0
%        pp.taca      % (11): smoothing time constant for alpha_c [0.0449 seconds]
%        pp.tamax     % (3): max smoothing time constant [0.392 seconds]
%        pp.taminh    % (3): min smoothing time constant (upper limit) [0.0133 seconds]
%        pp.tpfall    % (12): time constant for P to fall [0.064 seconds]
%        pp.tbmax     % (20): max smoothing time constant [0.0717 seconds]
%        pp.qeqmin    % (23): minimum value of Qeq [2]
%        pp.qeqmax    % max value of Qeq per frame [14]
%        pp.av        % (23)+13 lines: fudge factor for bc calculation  [2.12]
%        pp.td        % time to take minimum over [1.536 seconds]
%        pp.nu        % number of subwindows to use [3]
%        pp.qith      % Q-inverse thresholds to select maximum noise slope [0.03 0.05 0.06 Inf ]
%        pp.nsmdb     % corresponding noise slope thresholds in dB/second   [47 31.4 15.7 4.1]
%
% MMSE noise estimate [7]: pp.ne=1
%        pp.tax      % smoothing time constant for noise power estimate [0.0717 seconds](8)
%        pp.tap      % smoothing time constant for smoothed speech prob [0.152 seconds](23)
%        pp.psthr    % threshold for smoothed speech probability [0.99] (24)
%        pp.pnsaf    % noise probability safety value [0.01] (24)
%        pp.pspri    % prior speech probability [0.5] (18)
%        pp.asnr     % active SNR in dB [15] (18)
%        pp.psini    % initial speech probability [0.5] (23)
%        pp.tavini   % assumed speech absent time at start [0.064 seconds]
%
% If convenient, you can call v_specsub in chunks of arbitrary size. Thus the following are equivalent:
%
%                   (a) y=v_ssubmmse(s,fs);
%
%                   (b) [y1,z]=v_ssubmmse(s(1:1000),fs);
%                       [y2,z]=v_ssubmmse(s(1001:2000),z);
%                       y3=v_ssubmmse(s(2001:end),z);
%                       y=[y1; y2; y3];
%
% If the number of output arguments is either 2 or 5, the last partial frame of samples will
% be retained for overlap adding with the output from the next call to v_ssubmmse().
%
% See also v_specsub() for an alternative gain function
%
% Refs:
%    [1] Ephraim, Y. & Malah, D.
%        Speech enhancement using a minimum-mean square error short-time spectral amplitude estimator
%        IEEE Trans Acoustics Speech and Signal Processing, 32(6):1109-1121, Dec 1984
%    [2] Ephraim, Y. & Malah, D.
%        Speech enhancement using a minimum mean-square error log-spectral amplitude estimator
%        IEEE Trans Acoustics Speech and Signal Processing, 33(2):443-445, Apr 1985
%    [3] Rainer Martin.
%        Noise power spectral density estimation based on optimal smoothing and minimum statistics.
%        IEEE Trans. Speech and Audio Processing, 9(5):504-512, July 2001.
%    [4] O. Cappe.
%        Elimination of the musical noise phenomenon with the ephraim and malah noise suppressor.
%        IEEE Trans Speech Audio Processing, 2 (2): 345-349, Apr. 1994. doi: 10.1109/89.279283.
%    [5] J. Erkelens, J. Jensen, and R. Heusdens.
%        A data-driven approach to optimizing spectral speech enhancement methods for various error criteria.
%        Speech Communication, 49: 530-541, 2007. doi: 10.1016/j.specom.2006.06.012.
%    [6] R. Martin.
%        Statistical methods for the enhancement of noisy speech.
%        In J. Benesty, S. Makino, and J. Chen, editors,
%        Speech Enhancement, chapter 3, pages 43-64. Springer-Verlag, 2005.
%    [7] Gerkmann, T. & Hendriks, R. C.
%        Unbiased MMSE-Based Noise Power Estimation With Low Complexity and Low Tracking Delay
%        IEEE Trans Audio, Speech, Language Processing, 2012, 20, 1383-1393
%    [8] Loizou, P.
%        Speech enhancement based on perceptually motivated Bayesian estimators of the speech magnitude spectrum.
%        IEEE Trans. Speech and Audio Processing, 13(5), 857-869, 2005.

% Bugs/suggestions:
%   (1) sort out behaviour when si() is a matrix rather than a vector
%
%      Copyright (C) Mike Brookes 2004-2017
%      Version: $Id: v_ssubmmse.m 10865 2018-09-21 17:22:45Z dmb $
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
persistent cc kk
if ~numel(kk)           % if precomputed constants don't exist yet
    kk=sqrt(2*pi);      % sqrt(8)*Gamma(1.5)
    cc=sqrt(2/pi);      % sqrt(2)/Gamma(0.5)
end
szs=size(si);
if szs(1)==1 && szs(2)>1 && (~isstruct(fsz) || ~size(fsz.si,1) || size(fsz.si,2)==1)
    si=si'; % flip if only one channel and size(si,1)==1
    szs=size(si);
end
nc=szs(2);    % number of channels
if length(szs)>2
    np=szs(3);  % number of planes
else
    np=1;
end
ncp=nc*np;
if isstruct(fsz)
    fs=fsz.fs;          % sample frequency
    qq=fsz.qq;          % parameter structure
    qp=fsz.qp;
    ze=fsz.ze;          % saved structure for noise estimation
    nrs=size(fsz.si,1);         % number of samples saved from last time
    s=zeros(nrs+szs(1),nc*np);     % allocate space for speech
    s(1:nrs,:)=fsz.si;          % preappend the saved samples
    s(nrs+1:end,:)=reshape(si,[],ncp);  % append the new samples
else
    fs=fsz;     % sample frequency
    s=si;
    % default algorithm constants
    
    qq.of=2;        % overlap factor = (fft length)/(frame increment)
    qq.ti=16e-3;    % desired frame increment (16 ms)
    qq.ri=0;        % round ni to the nearest power of 2
    qq.ta=0.396;    % Time const for smoothing SNR estimate = -tinc/log(0.98) from [1]
    qq.gx=1000;     % maximum posterior SNR = 30dB
    qq.gn=1;        % min posterior SNR as a power ratio when estimating prior SNR [1]
    qq.gz=0.001;    % min posterior SNR as a power ratio [0.001 = -30dB]
    qq.xn=0;        % minimum prior SNR = -Inf dB
    qq.xb=1;        % bias compensation factor for prior SNR [1]
    qq.lg=1;        % use log-domain estimator by default
    qq.ne=1;        % noise estimation: 0=min statistics, 1=MMSE [1]
    qq.bt=-1;       % suppress binary masking
    qq.mx=0;        % no input mixing
    qq.gc=10;       % maximum amplitude gain [10 = 20 dB]
    qq.gw=[0 1 0 0 0];  % multichannel gain weights: [chan-n chan-1 ave min max]
    qq.tf='g';      % output the gain time-frequency plane by default
    qq.rf=0;
    if nargin>=3 && ~isempty(pp)
        qp=pp;      % save for v_estnoisem call
        qqn=fieldnames(qq);
        for i=1:length(qqn)
            if isfield(pp,qqn{i})
                qq.(qqn{i})=pp.(qqn{i});
            end
        end
        if length(qq.gw)<5
            qq.gw(5)=0;
        end
        qq.gw=qq.gw(1:5)/sum(qq.gw(1:5)); % ensure gain weights are normaized and trim to length 5
    else
        qp=struct;  % make an empty structure for v_estnoisem
    end
end
% derived algorithm constants
if qq.ri
    ni=pow2(nextpow2(qq.ti*fs*sqrt(0.5)));
else
    ni=round(qq.ti*fs);    % frame increment in samples
end
tinc=ni/fs;         % true frame increment time
a=exp(-tinc/qq.ta); % SNR smoothing coefficient
gx=qq.gx;           % max posterior SNR as a power ratio
gz=qq.gz;           % min posterior SNR as a power ratio
xn=qq.xn;           % floor for prior SNR, xi
ne=qq.ne;           % noise estimation: 0=min statistics, 1=MMSE [0]
gn1=max(qq.gn-1,0); % floor for posterior SNR when estimating prior SNR
xb=qq.xb;
tf=qq.tf;

% calculate power spectrum in frames

no=round(qq.of);                  	% integer overlap factor
nf=ni*no;                           % fft length
w=sqrt(hamming(nf+1))'; w(end)=[];  % for now always use sqrt hamming window
w=w/sqrt(sum(w(1:ni:nf).^2));       % normalize to give overall gain of 1
rf=qq.rf || nargout==2 || nargout==5;   % rf=1 if we need to round down to an exact number of frames
if rf>0                             % set flag for call to v_enframe
    rfm='';                         % truncate input to an exact number of frames
else
    rfm='r';                        % reflect final few input samples to fill up final frame
end
[y,tt]=v_enframe(s(:,1),w,ni,rfm);    % v_enframe channel 1
tt=tt/fs;                           % frame times
yf=v_rfft(y,nf,2);                    % complex spectrum of input speech
[nr,nf2]=size(yf);                  % nr = number of frames in this chunk
nf2nc=nf2*nc;                       % number of gains to calculate per frame
nf2ncp=nf2*ncp;                     % number of STFT values per frame
yf(1,1,ncp)=yf(1,1);                % enlarge yf to cope with nc*np channels
for ic=2:ncp                        % loop for each additional channel
    yf(:,:,ic)=v_rfft(v_enframe(s(:,ic),w,ni,rfm),nf,2);   % complex spectrum of channel ic
end
yf=reshape(yf,nr,nf2ncp);           % concatenate all the channels
tfe='nzxG';                         % tf entries that require enhancement on all channels
nzxG=nargout>2 && ~isempty(tf) && any(any(tf(ones(length(tfe),1),:) == tfe(ones(length(tf),1),:)')); % tf parameter includes 'n','z','x' or 'G'
nce= 1 + (nc-1)*(qq.gw(2)<1 || nzxG); % channels to enhance
nf2nce=nf2*nce;                     % total number of frequency bins for enhancement
if nc > nce                         % only need the gain from channel 1
    yp=yf(:,1:nf2).*conj(yf(:,1:nf2));  % power spectrum of channel 1 of input speech
else
    yp=yf(:,1:nf2nc).*conj(yf(:,1:nf2nc));  % power spectrum of all channels but only plane 1 of input speech
end
ff=(0:nf2-1)*fs/nf;                 % frequency axis
if isstruct(fsz)                    % check if we are following a previous call
    if ne>0                         % check noise estimation method
        [dp,ze]=v_estnoiseg(yp,ze);   % estimate the noise using MMSE in all frequency bins of nce channels
    else
        [dp,ze]=v_estnoisem(yp,ze);   % estimate the noise using minimum statistics
    end
    ssv=fsz.ssv;                    % saved output samples from previous call for overlap adding
    xu=fsz.xu;                      % saved unsmoothed SNR
else
    if ne>0                         % check noise estimation method
        [dp,ze]=v_estnoiseg(yp,tinc,qp);	% estimate the noise using MMSE
    else
        [dp,ze]=v_estnoisem(yp,tinc,qp);	% estimate the noise using minimum statistics
    end
    ssv=zeros(ni*(no-1),ncp);       % dummy saved output samples from previous call for overlap adding
    xu=1;                           % dummy unsmoothed SNR from previous frame %%%%%%%%%%% check dimensions
end

ss=[]; % in case of no data frames
gg=[]; % in case of no data frames or empty tf
if nr>0
    gam=max(min(yp./dp,gx),gz);    	% gamma = posterior SNR
    g=zeros(nr,nf2nce);             	% create space for gain matrix
    x=zeros(nr,nf2nce);             	% create space for prior SNR
    switch qq.lg
        case 0                      % use amplitude domain estimator from [1]
            for i=1:nr              % loop for each frame
                gami=gam(i,:);
                xi=max(a*xb*xu+(1-a)*max(gami-1,gn1),xn);  % prior SNR
                v=0.5*xi.*gami./(1+xi);	% note that this equals 0.5*vk in [1]
                gi=(0.277+2*v)./gami; 	% accurate to 0.02 dB for v>0.5
                mv=v<0.5;
                if any(mv)
                    vmv=v(mv);
                    gi(mv)=kk*sqrt(vmv).*((0.5+vmv).*besseli(0,vmv)+vmv.*besseli(1,vmv))./(gami(mv).*exp(vmv));
                end
                g(i,:)=gi;       	% save gain for later
                x(i,:)=xi;      	% save prior SNR
                xu=gami.*gi.^2;   	% unsmoothed prior SNR
            end
        case 2                    	% perceptually motivated estimator from [8]
            for i=1:nr              % loop for each frame
                gami=gam(i,:);
                xi=max(a*xb*xu+(1-a)*max(gami-1,gn1),xn);  % prior SNR
                v=0.5*xi.*gami./(1+xi);	% note that this is 0.5*vk in [8]
                gi=cc*sqrt(v).*exp(v)./(gami.*besseli(0,v));
                g(i,:)=gi;              % save gain for later
                x(i,:)=xi;              % save prior SNR
                xu=gami.*gi.^2;         % unsmoothed prior SNR
            end
        otherwise                       % use log domain estimator from [2]
            for i=1:nr              % loop for each frame
                gami=gam(i,:);
                xi=max(a*xb*xu+(1-a)*max(gami-1,gn1),xn);  % prior SNR
                xir=xi./(1+xi);
                gi=xir.*exp(0.5*expint(xir.*gami));
                g(i,:)=gi;             	% save gain for later
                x(i,:)=xi;              % save prior SNR
                xu=gami.*gi.^2;         % unsmoothed prior SNR
            end
    end
    if nc>nce                           % only calculated the gain from channel 1
        g=repmat(g,1,nc);               % replicate channel 1 gain for all channels
    else
        gr=g;                           % save raw gain in case we need to output it
        gwx=find(qq.gw(2:end));         % find which channel-independent gain terms to include
        if nc>1 && ~isempty(gwx)
            g3=reshape(g,[nr,nf2,nc]);
            gx=zeros(nr,nf2);          	% space for channel-independent gain component
            for ig=gwx                  % loop for each gain component with a non-zero weight
                switch ig
                    case 1                      % chan 1
                        gx=g3(:,:,1)*qq.gw(2);
                    case 2                      % average
                        gx=gx+mean(g3,3)*qq.gw(3);
                    case 3                      % min
                        gx=gx+min(g3,[],3)*qq.gw(4);
                    case 4                      % max
                        gx=gx+max(g3,[],3)*qq.gw(5);
                end
            end
            g=g*qq.gw(1)+repmat(gx,1,nc); % add in the channel-independent gain components
        end
    end
    g=min(qq.mx+(1-qq.mx)*g,qq.gc);                 % mix in some of the input and clip to qq.gc
    if qq.bt>=0
        g=g>qq.bt;                      % apply binary masking threshold
    end
    se=v_irfft(reshape(yf.*repmat(g,1,np),[nr nf2 nc*np]),nf,2).*repmat(w,[nr 1 nc*np]);     % inverse dft and apply output window
    ss=zeros(ni*(nr+no-1),nc*np,no);                % space for overlapped output speech
    ss(1:ni*(no-1),:,end)=ssv;                      % insert saved output speech (already overlap-added)
    for i=1:no                                      % insert frames into no columns for overlap-adding
        nm=nf*(1+floor((nr-i)/no));                 % number of samples in this column
        ss(1+(i-1)*ni:nm+(i-1)*ni,:,i)=reshape(permute(se(i:no:nr,:,:),[2 1 3]),nm,nc*np); % concatenate every no'th frame
    end
    ss=reshape(sum(ss,3),[],nc,np);                 % perform overlap add and split into planes
    if nargout>2 && ~isempty(tf)
        if (any(lower(tf)=='i') || any(lower(tf)=='o'))                         % tf entries that require all planes
            npg=np;  % number of planes in gg array
        else
            npg=1;
        end
        gg=zeros(nr,nf2nc*npg,length(tf));  % make space
        if ncp>nce && (any(tf=='i') || any(tf=='o'))
            yp=yf.*conj(yf);        % calculate power spectrum for all channels/planes
        end
        for i=1:length(tf)
            switch tf(i)
                case 'i'            % 'i' = input power spectrum (nc*np)
                    gg(:,:,i)=yp;
                case 'I'            % 'I' = input complex spectrum (nc*np)
                    gg(:,:,i)=yf;
                case 'n'            % 'n' = noise power spectrum (nc)
                    gg(:,:,i)=repmat(dp,1,npg);
                case 'z'            % 'z' = posterior SNR (i.e. (S+N)/N ) (nc)
                    gg(:,:,i)=repmat(gam,1,npg);
                case 'x'            % 'x' = prior SNR (nc)
                    gg(:,:,i)=repmat(x,1,npg);
                case 'g'            % 'G' = raw gain (nc)
                    gg(:,:,i)=repmat(gr,1,npg);
                case 'g'            % 'g' = final gain (nc)
                    gg(:,:,i)=repmat(g,1,npg);
                case 'o'            % 'o' = output power spectrum (nc*np)
                    gg(:,:,i)=yp.*g.^2;
                case 'O'            % 'O' = output complex spectrum (nc*np)
                    gg(:,:,i)=yf.*g;
            end
        end
        gg=reshape(gg,[nr,nf2,nc,npg,length(tf)]); % make it 5D
    end
end % if ~nr
if nargout==2 || nargout==5         % we have a zo output argument
    if nr
        zo.ssv=ss(end-ni*(no-1)+1:end,:);    % save the last no-1 hops for overlap-adding next time
        ss(end-ni*(no-1)+1:end,:)=[];        % only output the frames that are completed
    else
        zo.ssv=ssv;                 % if no new frames just keep the old tail
    end
    zo.si=s(length(ss)+1:end,:);      % save the tail end of the input speech signal
    zo.fs=fs;                       % save sample frequency
    zo.qq=qq;                       % save local parameters
    zo.qp=qp;                       % save v_estnoisem parameters
    zo.ze=ze;                       % save state of noise estimation
    zo.xu=xu;
    if nargout==2
        gg=zo;                      % 2nd of two arguments is zo
    end
elseif rf==0
    ss=ss(1:size(s,1),:,:);             % trim to the correct length if not an exact number of frames
end
if ~nargout && nr>0
    ffax=ff/1000;
    ax=zeros(4,1);
    ax(1)=subplot(223);
    imagesc(tt,ffax,20*log10(g(:,1:nf2))');
    colorbar;
    axis('xy');
    title(sprintf('Filter Gain (dB): ta=%.2g',qq.ta));
    xlabel('Time (s)');
    ylabel('Frequency (kHz)');
    
    ax(2)=subplot(222);
    imagesc(tt,ffax,10*log10(yp(:,1:nf2))');
    colorbar;
    axis('xy');
    title('Noisy Speech (dB)');
    xlabel('Time (s)');
    ylabel('Frequency (kHz)');
    
    ax(3)=subplot(224);
    imagesc(tt,ffax,10*log10(yp(:,1:nf2).*g(:,1:nf2).^2)');
    colorbar;
    axis('xy');
    title('Enhanced Speech (dB)');
    xlabel('Time (s)');
    ylabel('Frequency (kHz)');
    
    ax(4)=subplot(221);
    imagesc(tt,ffax,10*log10(dp(:,1:nf2))');
    colorbar;
    axis('xy');
    title('Noise Estimate (dB)');
    xlabel('Time (s)');
    ylabel('Frequency (kHz)');
    linkaxes(ax);
end