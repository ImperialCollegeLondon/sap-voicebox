% demo of v_estnoiseg
close all;
[s,fs]=readwav('data/as01b0.wav');
ov=2;                       % STFT overlap factor
hop=round(0.01*fs);         % frame hop is 10 ms
nw=hop*ov;                  % DFT length
w=v_windows('m',nw,'se');   % ensure the squared window sums to 1
snrs=-30:30;                % SNR range to plot
nsnr=length(snrs);          % number of SNR values
vptm=zeros(nsnr,2);         % reserve space for results
for i=1:nsnr
x=v_addnoise(s,fs,snrs(i),'N'); % add white noise at required SNR
y=v_enframe(x(:,1),w,hop);      % v_enframe channel 1
yf=v_rfft(y,nw,2);              % complex spectrum of noisy speech
[nf,nb]=size(yf);               % number of frames and frequency bins
yp=yf.*conj(yf)/nw;             % power spectrum of noisy speech (normalized to preserve total power)
vp=v_estnoiseg(yp,hop/fs);      % estimate the noise power spectrum using v_estnoiseg algorithm
vptm(i,1)=mean(vp*[1;repmat(2,nb-2,1);1]); % sum the power doubling eveything except the DC and Nyquist terms
vp=v_estnoisem(yp,hop/fs);      % estimate the noise power spectrum using v_estnoisem algorithm
vptm(i,2)=mean(vp*[1;repmat(2,nb-2,1);1]); % sum the power doubling eveything except the DC and Nyquist terms
end
plot(snrs,10*log10(vptm),[snrs(1) snrs(end)],[0 0],':k',[0 snrs(end)],[0 snrs(end)],':k');
legend('v\_estnoiseg','v\_estnoisem','location','nw');
v_axisenlarge([-1 -1.05]);      % make the vertical axis slightly bigger
xlabel('SNR (dB)');
ylabel('Error (dB)');
title('White Noise Power Estimation');
