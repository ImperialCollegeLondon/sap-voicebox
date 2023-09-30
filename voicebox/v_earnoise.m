function [y,x,v]=v_earnoise(s,fs,m,spl)
%V_EARNOISE Add noise to simulate the hearing threshold of a listener [Y,X,V]=(S,FS,M,SPL)
%
% Usage: (1) y=v_earnoise(s,fs);            % scale the speech to 62.35 dB SPL, add "internal ear noise" and then filter
%        (2) spl=62.35;                     % this code does the same but with explicit signal scaling
%            x=10^(0.05*spl)*v_activlev(s,fs,'n')
%            y=v_earnoise(x,fs,'u');
%        (3) v_earnoise(s,fs);              % If outputs are omitted, a graph is plotted showing SNR spectrrum
%        (4) y=v_earnoise(s,fs,[],50);      % scale the speech to 50 dB SPL instead of the default 62.35
%        (5) y=v_earnoise(s,fs,'n',spl);    % Assume the input signal, s, has already been scaled to 0 dB (saves computation)
%
%  Inputs:  s(n,c)  speech signal: n samples with one channel per column
%           fs      sample frequency in Hz
%           m       mode string as shown below [default '??']
%                     'n' Input s has been normalized to 0 dB (e.g. with the 'n' option of v_activlev.m)
%                     'u' Input s is already scaled correctly in SPL (so ignore the spl input argument)
%           spl       target active speech level in db SPL [default: 62.35]
%
% Outputs:  y(n,c)  filtered speech signal with added noise which simulates the ear input signal
%           x(n,c)  filtered input speech signal
%           v(n,c)  noise added to filtered speech signal
%
% This function adds ficticious "internal ear noise" onto an audio signal to simulate the effects of the
% frequency-dependent hearing threshold of a normal listener. To avoid having to add very high noise
% levels at low and high frequencies, it instead filters the input signal by the inverse of the desired
% noise spectrum and then adds white noise with 0 dB power spectral density. The noise spectrum is taken
% from Table 1 of [1] (which derived it from [2]) and, at a particular frequency, equals the pure-tone
% hearing threshold minus 10*log10(R) where R is the critical ratio. The critical ratio, R, is the power
% of a pure tone divided by the power spectral density of a white noise that just masks it; this ratio is
% approximately independent of level.
%
% By default the input speech for the strongest channel is scaled to correspond to a normal speaking level
% at 1 metre from the lips (62.35 dB from [1]). The speech level at the centre of the listener's head  can
% alternatively be specified explicitly in dB SPL using the spl input parameter. For distant sources, the
% level should be reduced by 20*log10(dist) where dist is the distance in metres between the speaker's
% lips and the centre of the listener's head. The same scaling is used for all channels.
%
% This function assumes normal hearing; to account for hearing loss, use the 'u' option (as in usage
% example 2 above) and apply a filter to x that reduces the signal level by the hearing loss at each
% frequency. For example, if the hearing loss is 20 dB at all frequencies, then x should be multiplied by 0.1.
%
% Refs: [1]	ANSI. Methods for the calculation of the speech intelligibility index.
%               ANSI Standard S3.5-1997 (R2007), American National Standards Institute, 1997.
%       [2]	C. V. Pavlovic. Derivation of primary parameters and procedures for use in speech
%               intelligibility predictions. J. Acoust. Soc. Amer., 82: 413–422, 1987.
%
persistent fs0 a b
if isempty(fs0) || fs~=fs0
    [b,a]=v_stdspectrum(7,'z',fs);              % inverse internal noise spectrum filter
    fs0=fs;
end
[ns,nc]=size(s);
if nc>ns
    error('s input has more columns (channels) than rows (samples)');
end
if nargin<3 || isempty(m)
    m=' ';
end
if nargin<4 || isempty(spl)
    spl=62.35;
end
if any(m=='n') || any(m=='u')
    if any(m=='n')
        dboff=spl;
    else
        dboff=0;
    end
else
    if nc>1
        sal=zeros(1,nc);
        for i=1:nc
            sal(i)=v_activlev(s(:,i),fs,'d');
        end
        dboff=spl-max(sal);               % gain to apply to speech signal in dB
    else
        dboff=spl-v_activlev(s,fs,'d');               % gain to apply to speech signal in dB
    end
end
x=10^(0.05*dboff)*filter(b,a,s);
v=sqrt(0.5*fs)*randn(size(s)); % Add noise at 0 dB power spectral density
y=x+v;
if ~nargout
    nfft=2*round(10e-3*fs/2);                       % FFT length is even number approximately 5 ms long
    fax=(0:nfft/2)*fs/nfft; % frequency axis for plot
    win=hamming(nfft);
    sal=zeros(1,nc);
    for i=1:nc
        sal(i)=v_activlev(s(:,i),fs,'d')+dboff;
    end
    [salmax,imax]=max(sal);
    [salmax,af,fso,vad]=v_activlev(s(:,imax),fs,'d');          % Get VAD from highest power input sigal
    fvad=sum(v_enframe(vad,nfft,nfft/2),2)>nfft/2;  % frames with mostly speech in them
    minmax=[Inf -Inf];
    leg=cell(nc,1);
    gsnr=zeros(nc,1);
    cols='brgcmyk';
    for i=1:nc
        col=cols(1+mod(i-1,length(cols)));
        px=v_enframe(x(:,i),win,nfft/2,'sdp',fs);        % computer first half of PSD
        psxm=mean(px(fvad,:),1);
        psxmdb=db(psxm,'p');
        minmax=[min(minmax(1),min(psxmdb)) max(minmax(2),max(psxmdb))];
        gsnr(i)=db(mean(psxm),'p');
        semilogx(fax,psxmdb,[col '-']);
        hold on
        leg{i}=sprintf('Chan %d: %+.1f dB SPL',i,sal(i));
    end
    for i=1:nc
        col=cols(1+mod(i-1,length(cols)));
        semilogx(fax([2 end]),gsnr([i i]),[col '--']);
    end
    snrrange=60;
    ylim=[max(minmax(1),minmax(2)-snrrange) minmax(2)]*[1.05 -0.05; -0.05 1.05];
    set(gca,'ylim',ylim,'xlim',[100 fs/2]);
    if ylim(1)<0 && ylim(2)>0
        semilogx(fax([2 end]),[0 0],'k:');
    end
    hold off
    grid on;
    legend(leg,'location','best')
    xlabel(['Frequency (' v_xticksi 'Hz)']);
    ylabel('SNR (dB)')
    title('Hearing threshold equivalent SNR');
end