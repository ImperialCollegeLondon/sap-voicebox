function [b,a,fx,bx,gd,ph]=v_gammabank(n,fs,w,fc,bw,ph,k)
%V_GAMMABANK gammatone filter bank [b,a,fx,bx,gd]=(n,fs,w,fc,bw,ph,k)
%
% Usage:
%          (1) [b,a,fx,bx,gd,ph]=v_gammabank(0.35,fs,'',[100 6000]);
%              y = v_filterbank(b,a,s,gd);
%
%              Will create an erb-spaced v_filterbank between 100 Hz and 6kHz
%              with a filter spacing of 0.35 erb and a default bandwidth
%              of 1.019 erb. Omitting the "y =" from the second line will plot
%              a spectrogram.
% Inputs:
%       n   number of filters in v_filterbank or the filter spacing in bark/erb/k-mel.
%           Set n=0 if fc lists centre frequencies explicitly.
%		fs  sample rate in Hz
%		w   any sensible combination of the following:
%           (1) Filters are uniformly spaced in
%             'e' = erb scale (aka erb-rate scale) [default]
%             'b' = bark scale
%             'm' = mel scale
%             'l' = log10 scale
%             'h' = Hz
%
%           (2) Centre frequencies, fc, are in units of
%             'f' = Hz [default]
%             'F' = the same units as the filter spacing (see (1) above)
%
%           (3) Bandwidths, bw, are specified in units of
%             'w' = Hz [default]
%             'W' = the same units as the filter spacing (see (1) above)
%             'E' = erb scale (aka erb-rate scale)
%             'B' = bark scale
%             'M' = mel scale
%             'L' = log10 scale
%             'H' = Hz
%
%           (4) Number of filters
%             'n' = n input gives number of filters [default if n>=1]
%             'N' = n input gives filter spacing    [default if n<1]
%
%           (5) Filter alignment
%             'k' = force a filter at 1kHz
%
%           (6) Output filter
%             'c' = Use complex gammatone filters whose impulse responses uses a complex exponential
%                   instead of a cosine; the filter order is k instead of 2k. Take the real part of
%                   the filter output to obtain the same signal as using the real-valued filter.
%                   The imaginary part is approximately the Hilbert transform of the real part and
%                   so the magnitude gives the envelope.
%             'q' = biquad filter; b(k,6,n) has the sos coefficients in the  same form as sosfilt.m.
%                   Use y=sosfilt(b,x) to apply the filter.
%
%           (6) Future possible options
%             ['a' = use all-pole gammtone funtion: see [1]]
%             ['s' = use Slaney gammatone approximation: see [2]]
%             ['z' = use one-zero gammatone function: see [1]]
%
%           (7) Graph plotting
%             'g' = plot filter responses [default if no output arguments present]
%             'G' = plot frequency responses on a log axis
%		fc  frequency range or, if n=0, list of centre frequencies [default: [100 6000] ]
%		bw  bandwidth for all filters or a vector of bandwidths: one per filter [default = 1.019 erb ]
%       ph  phase of all gammatone impulse repsonses or a vector of phases: one per filter
%          [default is chosen to give zero gain at DC and a positive real part for the gain at low frequencies]
%       k   gammatone filter order; the filters have order 2k [default: 4]
%
% Outputs:
%       b/a     filter coefficients: one filter per row. The gain of each
%               filter is scaled to have unit magnitude at the centre frequency.
%               Dimensions are b(n,k+max(1,k-1)) and a(n,2*k+1) normally or else
%               b(n,max(1,k-1)) and a(n,k+1) if the 'c' option is specified.
%               If the q option is given then b(k,6,n) contains the biquad coefficients for filter n.
%       fx,bx   centre frequencies and bandwidths in Hz
%       gd      group delay at the centre frequencies (in samples)
%       ph      phase of each gammatone impulse response
%

% For k>1, the impulse response of filter i is proportional to:
%       h[n]=(((n+1)/fs).^(k-1))*cos(2*pi*fx(i)*(n+1)/fs+ph(i))*exp(-2*pi*bx(i)*(n+1)/fs)
% where n>=0. For k=1 replace "(n+1)" by "n". If the 'c' option is used, replace "cos(�)" by "exp(1i*�)".
% Note that the DC gain is only equal to zero for two particular value of ph(i) that differ by pi.
% Each filter is normalized to have unity gain at the centre frequency, fx(i).
%
% Derivation:
%       The cos() term in h[n] can be decomposed as a sum of complex exponentials resulting in
%       h[n] = a*g[n+1;p] + a'*g[n+1;p]' where p=2*pi*(-bx(i) + j*fx(i))/fs, a=fs^(1-k)*exp(j ph(i))
%       and g[n;p]=n^(k-1)*p^n.
%       The z-transform, G(z)=B(z)/A(z) where A(z)=(1 - p/z)^k. The numerator coefficents, b[r], can
%       be obtained by convolving a[r] and g[r] where a[r]=nchoosek(k,r)*(-p)^n.
%
% References
%  [1]	R. F. Lyon, A. G. Katsiamis, and E. M. Drakakis.
%       History and future of auditory filter models.
%       In Proc Intl Symp Circuits and Systems, pages 3809�3812, 2010.
%       doi: 10.1109/ISCAS.2010.5537724.
%  [2]	M. Slaney.
%       An efficient implementation of the patterson-holdsworth auditory filter bank.
%       Technical report, Apple Computer, Perception Group, Tech. Rep, 1993.

%      Copyright (C) Mike Brookes 2009-2017
%      Version: $Id: v_gammabank.m 10865 2018-09-21 17:22:45Z dmb $
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

if nargin<7
    k=[];
    if nargin<6
        ph=[];
        if nargin<5
            bw=[];
            if nargin<4
                fc=[];
                if nargin<3
                    w='';
                end
            end
        end
    end
end
fx=fc(:);
bx=bw(:);
if ~numel(k)
    k=4;
end
if ~numel(fx)
    fx=[100; 6000]; % default
end
wr='e';   % default frequency warping is erb
for i=1:length(w)
    if any(w(i)=='bmlef');
        wr=w(i);
    end
end
if any(w=='k')
    fk=1000;
    switch wr              % convert 1kHz to spacing units
        case 'b'
            fk=v_frq2bark(fk);
        case 'l'
            fk=log10(fk);
        case 'e'
            fk=v_frq2erb(fk);
    end
else
    fk=0;
end
if any(w=='W')
    wb=wr;
else
    wb='h';     % default bandwidth units are Hz
end
for i=1:length(w)
    if any(w(i)=='BMLEF');
        wb=w(i)+'a'-'A';        % convert to lower case
    end
end
if ~numel(bx)
    bx=1.019;
    wb='e';
end
if any(w=='F')          % convert centre frequencies to Hz
    switch wr
        case 'b'
            fx=v_bark2frq(fx);
        case 'm'
            fx=v_mel2frq(fx);
        case 'l'
            fx=10.^(fx);
        case 'e'
            fx=v_erb2frq(fx);
    end
end

% now sort out the centre frequencies

if n>0                      % n>0: filter end points specified
    bx=bx(1);               % only use the first bx element
    if n==1             % only one filter requested
        fx=fx(1);           % just use the first frequency
    else
        switch wr               % convert end frequencies to spacing units
            case 'b'
                fx=v_frq2bark(fx);
            case 'm'
                fx=v_frq2mel(fx);
            case 'l'
                fx=log10(fx);
            case 'e'
                fx=v_frq2erb(fx);
        end
        if n<1 || any(w=='N')       % n = filter spacing
            if fk               % force filter to 1 kHz
                f0=fk-n*floor((fk-fx(1))/n);
            else                % centre filters in range
                f0=(fx(2)+fx(1)-n*floor((fx(2)-fx(1))/n))/2;
            end
            fx=(f0:n:fx(2))';
            
        else                        % n = number of filters specified
            % Multiple filters - evenly spaced
            fx=linspace(fx(1),fx(2),n)';     % centre frequencies in spacing units
            if fk              % force a filter at 1kHz
                ik=1+ceil((fk-fx(1))*(n-1)/(fx(n)-fx(1))); % index of centre freq immediately above 1 kHz
                if ik>n || ik>1 && ((fk-fx(1))*(fx(n)-fx(ik-1))>(fx(n)-fk)*(fx(ik)-fx(1)))
                    fx=fx(1)+(fx-fx(1))*(fk-fx(1))/(fx(ik)-fx(1));
                else
                    fx=fx(n)+(fx-fx(n))*(fx(n)-fk)/(fx(n)-fx(ik-1));
                end
            end
        end
        switch wr % convert back to Hz
            case 'b'
                fx=v_bark2frq(fx);
            case 'm'
                fx=v_mel2frq(fx);
            case 'l'
                fx=10.^(fx);
            case 'e'
                fx=v_erb2frq(fx);
        end
    end
    
end
% now sort out the bandwidths
nf=numel(fx);
if numel(bx)==1
    bx=bx(ones(nf,1));      % replicate if necessary
end
switch wb               % convert bandwidth to Hz
    case 'b'
        [dum,bwf]=v_frq2bark(fx);
    case 'm'
        [dum,bwf]=v_frq2mel(fx);
    case 'l'
        bwf=fx*log(10);
    case 'e'
        [dum,bwf]=v_frq2erb(fx);
    case 'h'
        bwf=ones(nf,1);
end
bx=bx.*bwf;
zph=0; % flag to indicate missing phase vector
if ~numel(ph)
    ph=zeros(nf,1);         % default phase is zero
    zph=1;                  % set missing phase flag
elseif numel(ph)==1
    ph=ph(ones(nf,1));      % replicate a scalar value
else
    ph=ph(:);               % force ph to be a column vector
end
%
% t=(0:ceil(10*fs/(2*pi*bnd)))/fs;  % five time constants
% gt=t.^(n-1).*cos(2*pi*cfr*t+phi).*exp(-2*pi*bnd*t);
% gt=gt/sqrt(mean(gt.^2)); % normalize
% figure(1);
% plot(t,gt);
% title('Desired Impulse response');
% xlabel(['Time (' v_xticksi 's)']);
%
zp=exp((1i*fx-bx)*2*pi/fs);             % pole position in top half of z-plane
a=round([1 cumprod((-k:-1)./(1:k))]);   % create alternating sign binomial coefficients [1,k+1]
wwp=repmat(zp,1,k+1).^repmat(0:k,nf,1); % powers of pole position [nf,k+1]
denc=repmat(a,nf,1).*wwp;               % complex denominator coefficients [nf,k+1]
if k>1
    b=conv(a,(1:k-1).^(k-1));          	% convolve with integers to the power k-1 [1,2*k-1]
    b=exp(1i*ph)*b(1:k-1);             	% correct for starting phase shift [nf,k-1]
    numc=b.*wwp(:,2:k);               	% complex numerator coefficients [nf,k-1]
else % for the special case of k=1
    numc=exp(1i*ph);                    % complex numerator coefficients [nf,1]
end
kk=size(numc,2);                        % = max(1,k-1)
% if phase is unspecified choose phase to give zero gain at DC and positive real(gain) for small w
if zph
    sd=sum(denc,2);
    sn=sum(numc,2);
    snn=numc*(0:kk-1)';
    sg=sign(real(conj(sn).*snn));
    ph=angle(1i*sg.*conj(sn./sd));
    numc=numc.*repmat(exp(1i*ph),1,kk);
end
b=zeros(nf,k+kk);                      	% space for numerators
a=zeros(nf,2*k+1);                      % space for denominators
gd=zeros(nf,1);                         % space for group delay
ww=exp(2i*fx*pi/fs);                    % exp(j*centre-freq)
for i=1:nf
    b(i,:)=real(conv(numc(i,:),conj(denc(i,:))));
    a(i,:)=real(conv(denc(i,:),conj(denc(i,:)))); % denominator has k repeated poles at ww and ww'
    u=polyval(b(i,:),ww(i));            % numerator gain @ centre freqs
    v=polyval(a(i,:),ww(i));            % denominator gain @ centre freqs
    ud=polyval(b(i,:).*(0:k+kk-1),ww(i));
    vd=polyval(a(i,:).*(0:2*k),ww(i));
    vu=abs(v/u);                        % scale factor to give unity gain
    b(i,:)=b(i,:)*vu;                   % force unity gain @ centre freqs
    numc(i,:)=numc(i,:)*vu;             % scale the complex numerator coefficients also
    gd(i)=real((v*ud-u*vd)/(u*v));      % group delay at centre freq in samples
end

% now plot graph

if ~nargout || any(w=='g') || any(w=='G')
    ng=200;      %number of points to plot
    if any(w=='G')
        fax=logspace(log10(fx(1)/4),log10(fs/2),ng);
    else
        fax=linspace(0,fs/2,ng);
    end
    ww=exp(2i*pi*fax/fs);
    gg=zeros(nf,ng);
    for i=1:nf
        gg(i,:)=10*log10(abs(polyval(b(i,:),ww)./polyval(a(i,:),ww)));
    end
    if any(w=='G')
        semilogx(fax,gg','-b');
        set(gca,'xlim',[fax(1) fax(end)]);
    else
        plot(fax,gg','-b');
    end
    xlabel(['Frequency (' v_xticksi 'Hz)']);
    set(gca,'ylim',[-50 1]);
    title(sprintf('Order-%d Gammatone Filterbank (N=%d, Opt=%s)',k,nf,w));
end

% sort out output format

if any(w=='c')                              % if complex filter output
    b=numc;                                 % output complex filter of order k
    a=denc;
elseif any(w=='q')                          % if biquad output
    bb=zeros(k,6,nf);                       % space for sos
    for i=1:nf
        bb(:,:,i)=tf2sos(b(i,:),a(i,:));    % calculate the biquads
        bb(:,5,i)=-2*real(zp(i));           % force denominators to be exact
        bb(:,6,i)=zp(i)*conj(zp(i));
    end
    a=[];
    b=bb;
end
