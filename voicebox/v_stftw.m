function [y,so,tax,fax]=v_stftw(x,nw,m,ov)
%V_STFTW converts a time-domain signal into the time-frequency domain with the Short-time Fourier Transform [Y,SO,T,F]=(X,NW,M,OV)
%  Usage:  (1) [y,so]=v_stftw(x,nw); % default parameters: m='rM', ov=2
%              % ...                 % time-frequency domain processing goes here
%              z=v_istftw(y,so);     % z is the same as x except for the first and last half-frames
%
%          (2) [y,so]=v_stftw(x,nw,'en',4); % Hanning window with ov=4
%              z=v_istftw(y,so);     % z is the same as x everywhere due to 'e' option
%
%          (3) [y,so]=v_stftw([],nw,'pn',4);      	% initialise v_stftw state variable, so
%              io=[];                               % initialise v_istftw state variable, io
%              while true                           % loop forever
%                % ... [acquire input chunk x]     	% acquire new chunk of input samples
%                [y,so]=v_stftw(x,so,'p');       	% 'p' option means more chunks to come
%                % ... [process in T-F domain]      % process signal in time-frequency domain
%                [z,io]=v_istftw(y,so,io);         	% convert back to time domain
%                % ... [output chunk z];            % output chunk of processed samples
%              end
%
%          (4) v_stftw(x,nw);                        % Plot spectrogram of first channel
%
%          (5) [y1,so]=v_stftw(x(1:1000),nw,'ep'); 	 % convert chunk 1 of 3
%              [y2,so]=v_stftw(x(1001:2000),so,'p'); % Options other than 'p' will be remembered
%              [y3,so]=v_stftw(x(2001:end),so);      % Omit 'p' for final chunk (which can have x=[] if desired)
%              y=[y1; y2; y3];                       % Concatenate to get complete T-F data
%              [z1,io]=v_istftw(y(1:5,:),so);     	 % convert back to time domain
%              [z2,io]=v_istftw(y(6:10,:),so,io);    % convert back to time domain
%              z3=v_istftw(y(11:end,:),so,io);    	 % omit 'io' output on final chunk
%              z=[z1; z2; z3];                       % z is the same as x everywhere due to 'e' option
%
%  Inputs: x(tax,...)	input signal (one signal per column)
%          nw       DFT length (will be rounded up to a multiple of ov)
%                       alternatively so output from the previous chunk's call to v_stftw
%          m        mode string including window code
%          ov       integer overlap factor; the frame hop is nw/ov. [2]
%
% Outputs: y(tf,k,...)  output STFT (frame=tf, freq=k). Number of frequencies is normally 1+nw/2 from DC to Nyquist
%          tax          sample numbers corresponding to the centre of each frame; divide by fs to get times
%          fax          normalized centre frequencies of each bin (multiply by fs for actual frequencies)
%          so           structure used in subsequent call as the nw argument to
%                       alllow processing in chunks. Also used in v_istftw
%
% The mode string, m, is a character string containing a combination of the following options:
%
%             'p'   x is a partial signal which will be followed by another chunk (prevents paddding of the final frame)

%             'r'   pad final frame with reflected data if necessary [default]
%             'z'   pad final frame with zeros if necessary
%             't'   truncate data to an exact number of frames
%             'e'   pad with samples at beginning and end of signal to include all frames with at least one signal sample
%
%             'i'   zero-pad by a factor of 2 to increase apparent frequency resolution
%             'I'   zero-pad by a factor of 4 to increase apparent frequency resolution
%             'u'   zero-pad to round transform length up to a power of 2 to speed computation
%
%             's'   plot spectrogram of first channel (default if no outputs)
%             'S'   plot mean spectra and mean power waveforms of all channels
%
%            Code Window      mode   ov   Sidelobe  3dB-BW  6dB-BW  Falloff    Comment
%
%             'c'   cos(1)     s   2,3,5   -23dB     1.2     1.6  -12dB/oct   used in MP3
%             'k'   kaiser(5)  boq   2     -23dB     1.2     1.7   -6dB/oct   used in AAC
%             'm'   hamming    s   3,4,5   -43dB     1.3     1.8   -6dB/oct   low sidelobes [default if ov>2]
%             'M'   hamming    sq  2,3,5   -24dB     1.1     1.5   -6dB/oct   sqrt Hamming  [default if ov=2]
%             'n'   hanning    s   3,4,5   -31dB     1.4     2.0  -18dB/oct   rapid falloff
%             'v'   vorbis     s    2,15   -21dB     1.3     1.8  -18dB/oct   used in Vorbis
%             'V'   rsqvorbis  sq    2     -26dB     1.1     1.5   -6dB/oct   sqrt Vorbis
%
% Notes:
%
%  (1) The scaling preserves power in a 2-sided transform so that
%
%        p = mean(x.^2) ~=~ mean(sum(abs(yy).^2,2)) where yy=[y conj(y(:,nw-size(y,2)+1:-1:2))]
%
%      where yy is the double-sided spectrum. This equivalence is stochastic rather than exact.
%  (2) For perfect reconstruction (see [3]), the overlap factor, ov, must be a multiple of one of
%      the values listed above in the ov column for the selected window.
%  (3) Using the default parameters, perfect reconstruction will not be obtained for the first and 
%      the last frames of the signal. Using the 'e' option will add padding frames to the start and
%      end of the signal so that the entire signal will be reconstructed perfectly.
%  (4) By default, padding at the start and end of the signal will avoid introducing a discontinuity
%      by using a time-reversed reflection of the input signal. Alternatively, the 'z' option will
%      pad with zeros and the 't' option will truncate the signal to fit into an exact number of frames.
%  (5) To avoid temporal aliasing in the time-frequency domain , an overlap factor of ov>=4 is required for
%      most windows. Using an overlap factor of ov=2 (the default) halves the number of frames to process
%      but may result in aliasing for some signals although this is normally slight (see [1]).
%
% Refs: [1] J. B. Allen. Short term spectral analysis, synthesis, and modification by discrete Fourier transform.
%           IEEE Trans. Acoustics, Speech and Signal Processing, 25 (3): 235–238, June 1977.
%       [2]	R. Crochiere. A weighted overlap-add method of short-time fourier analysis/synthesis.
%           IEEE Trans. Acoustics, Speech and Signal Processing, 28 (1): 99–102, 1980.
%       [3]	J. Princen and A. Bradley. Analysis/synthesis filter bank design based on time domain aliasing cancellation.
%           IEEE Trans. Acoustics, Speech and Signal Processing, 34 (5): 1153–1161, 1986. doi: 10.1109/TASSP.1986.1164954.
%
% Revision History
%    2022-04-10 First version
persistent nw0 nt0 wi0 w0 wt wm wp
if isempty(nw0)
    nw0=0;
    wt={'hamming','hamming','cos','kaiser','hanning','rsqvorbis','vorbis'};
    wm={'sq','s','s','boq','s','sq','s'};
    wp=[0 0 1 5 0 0 0];
end
sx=size(x);
if sx(1)==1 && length(sx)==2 % transpose x if it is a row vector
    x=x.';
    sx=size(x);
end
nx=sx(1);                   % number of samples
nc=prod(sx(2:end));         % total number of channels
x=reshape(x,nx,nc);         % make input data 2-dimensional
if nargin<3 || ~numel(m)    % no mode options specified
    m='';                   % use default modes
end
if isstruct(nw)             % nw is structure from previous call to v_stftw
    so=nw;                  % replicate into so since most fields will be identical
    wa=nw.wa;               % analysis window
    nh=nw.nh;               % frame hop (samples)
    po=nw.po;               % padding option
    nt=nw.nt;               % overwrite nw with length of transform
    me=nw.me;               % 'e' option given
    ff=nw.ff;               % first frame flag
    mf=nw.mf;
    if ~isempty(nw.xx)    	% there is a data tail from a previous call
        x=cat(1,nw.xx,x); 	% pre-append saved data
    end
    so.mx=so.mx+nx;      	% cumulative signal length (using original value of nx)
    sx=size(x);             % recalculate sx (especially necessary if input argument x=[]
    nx=sx(1);               % recalculate the number of samples
    nw=length(wa);          % overwrite nw with the window length
else
    if nargin<4 || ~numel(ov)
        ov=2;               % default overlap factor
    else
        ov=round(ov);     	% force integer overlap factor
    end
    nh=ceil(nw/ov);         % force integer hop length
    nw=ov*nh;               % recalculate DFT length
    wi=find(sum(repmat(m(:),1,7)==repmat('MmcknVv',length(m),1),1),1); % check if m specifies the window
    if isempty(wi)          % if no window specified
        wi=1+(ov>2);    	% use 's' or 'm'
    end
    % sort out zero-padding
    nt=nw;                  % default transform length
    if any(m=='i')          % 'p' = multiply nt by 2 for increased frequency resolution
        nt=2*nt;
    end
    if any(m=='I')          % 'u' = multiply nt by 4 for increased frequency resolution
        nt=4*nt;
    end
    if any(m=='u')          % 'u' = round up nt to a power of 2 for increased frequency resolution
        [fw,pw]=log2(nt);
        nt=pow2(pw-(fw==0.5));
    end
    me=any(m=='e');
    if nw==nw0 && wi==wi0 && nt==nt0    % check if window already cached
        wa=w0;                          % use cached version if available
    else
        wa = v_windows(wt{wi},nw,wm{wi},wp(wi)); % only need the parameter for 'c' and 'k' windows
        wa=wa/sqrt(sum(wa.^2)*nt);      % scale to preserve power
        nw0=nw;                         % save parameters of cached window
        nt0=nt;
        wi0=wi;
        w0=wa;                          % save window in cache
    end
    % sort out enframing details
    ff=1;                               % flag to indicate the first frame
    po=find(sum(repmat(m(:),1,3)==repmat('zrt',length(m),1),1),1); % find padding option
    if isempty(po)
        po=2;                           % default to po=2 ('r')
    end
    % create so structure
    mf=0;
    so.wa=wa;                       % save analysis window
    so.po=po;                       % save padding option for final frame
    so.nh=nh;                       % save frame hop
    so.nt=nt;                       % length of transform
    so.me=me;                       % 'e' option given
    so.mx=nx;                       % cumulative signal length
    so.mf=0;                        % zero cumulative frames output so far (excluding prefix frames)
end
% now do the STFT
mp=any(m=='p');                     % 'p' option given: this is not the last chunk
f0=(1-nw/nh)*(me && ff);            % initial frame: either 0 or (1-ov)
if nx>0                             % there are some samples
    if me && ~mp                    % include all frames that contain at least one sample
        f1=ceil(nx/nh)-1;           % last frame that include at least one sample
    elseif po<3 && ~mp              % ensure all samples are in at least one frame
        f1=max(ceil((nx-nw)/nh),0);
    else                            % only include full frames
        f1=floor((nx-nw)/nh);       % last full frame (might be negative and/or <f0)
    end
else                                % input signal is empty
    f1=-1;
end
nf=max((f1-f0+1)*(f1>=0),0);        % number of frames to output
if nf>0                             % if there are frames to output
    ff=0;                           % turn off first frame flag
    indx=repmat(nh*(f0:f1).',nw,1)+reshape(repmat(0:nw-1,nf,1),nf*nw,1); % index into x
    mk=indx<0 | indx>nx-1;          % mask for values outside 0:nx-1
    indx=nx+0.5-abs(mod(indx,2*nx)+0.5-nx); % reflect values outside the range
    y=x(indx,:);                    % create output
    if po==1                        % padding option was 'z'
        y(mk,:)=0;                  % set padding values to zero
    end
    y=v_rfft(reshape(y,[nf,nw,sx(2:end)]).*repmat(wa,[nf,1,sx(2:end)]),nt,2);  % perform windowed DFT
else
    y=zeros([0,nw,sx(2:end)]);
end
if nargout>1                        % need additional outputs
    if nf>0
        tax=(f0+mf:f1+mf)*nh+0.5*(1+nw);      % frame centre times (where input samples are 1,2,...)
    else
        tax=[];
    end
    fax=(0:size(y,2)-1)/nt;           % bin centre frequencies (normalized by sample frequency)
    if nf>0
        so.xx=x((f1+1)*nh+1:end,:);	% save data tail for next chunk (starts at sample nh+1 of the last frame in y)
    else
        so.xx=x;               % if nf==0 then data tail is entire signal (including any previous tail)
    end
    so.ff=ff;                  % first frame flag
    so.mp=mp;                  % flag indicating more chunks to follow
    so.mf=mf+nf+f0;            % add number of additional non-prefix frames output
end
if nf>0 && (~nargout || any(lower(m)=='s')) 	% no outputs or 'sS' options so plot graphs
    ta=(f0+mf:f1+mf)*nh+0.5*(1+nw);
    nv=size(y,2);
    fa=(0:nv-1)/nt;
    clf;
    if any(m=='S')
        subplot(2,1,1);
        yp=abs(reshape(y,[nf,nv,nc])).^2;       % calculate power spectrum
        plot(ta,10*log10(reshape(sum(cat(2,yp,yp(:,2:floor((nt+1)/2),:)),2),nf,nc))); % add in power from negative frequencies
        v_axisenlarge([-1 -1.05]);
        xlabel('Sample Number');
        ylabel('Frame power (dB)');
        subplot(2,1,2);
        plot(fa,10*log10(reshape(mean(yp,1),nv,nc)));
        v_axisenlarge([-1 -1.05]);
        xlabel('Normalized Frequency');
        ylabel('Mean Power (dB)');
    else
        imagesc(ta,fa,20*log10(abs(y(:,:,1)))'); % plot only the first channel
        colorbar;
        axis 'xy';
        ylabel('Normalized Frequency');
        xlabel('Sample Number');
        v_cblabel('Energy (dB)');
        hold on;
        clim=get(gca,'clim');
        set(gca,'clim',[max(clim(1),clim(2)-40) clim(2)]);
        ylim=get(gca,'ylim');
        plot([0.5;0.5],ylim',':k');             % indicate start of signal
        if ~mp
            plot([1;1]*(so.mx+0.5),ylim',':k'); % indicate end of signal
        end
        hold off
    end
end

