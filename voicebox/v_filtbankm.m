function [x,cf,xi,il,ih]=v_filtbankm(p,n,fs,fl,fh,w)
%V_FILTBANKM determine matrix for a linear/mel/erb/bark-spaced v_filterbank [X,IL,IH]=(P,N,FS,FL,FH,W)
%
% Usage:
% (1) Calcuate the Mel-frequency Cepstral Coefficients
%
%        f=v_rfft(s);			                        % v_rfft() returns only 1+floor(n/2) coefficients
%		 x=v_filtbankm(p,n,fs,0,fs/2,'m');              % n is the fft length, p is the number of filters wanted
%		 z=log(x*abs(f).^2);                            % multiply the power spectrum by x to get log mel-spectrum
%		 c=dct(z);                                      % take the DCT to get the mel-cepstrum
%
% (2) Calcuate the Mel-frequency Cepstral Coefficients efficiently
%
%        f=fft(s);                                      % n is the fft length, p is the number of filters wanted
%        [x,cf,na,nb]=v_filtbankm(p,n,fs,0,fs/2,'m');   % na:nb gives the fft bins that are needed
%        z=log(x*(f(na:nb)).*conj(f(na:nb)));           % multiply x by the power spectrum
%		 c=dct(z);                                      % take the DCT
%
% (3) Plot the calculated filterbanks as a graph or spectrogram
%
%        v_filtbankm(p,n,fs,0,fs/2,'mg');               % use option 'mg' for a graph or 'mG' for a spectrogram
%
% (4) Convert to mel-spectrum and back again
%
%        [x,cf,xi]=v_filtbankm(p,n,fs,0,fs/2,'mxXzq');  % n is the fft length, p is the number of filters wanted
%        f=v_rfft(s);			                        % v_rfft() returns only 1+floor(n/2) coefficients		
%		 z=x*abs(f).^2;                                 % multiply the power spectrum by x to get mel-spectrum
%        gp=xi*z;                                       % multiply by xi to recover the approximate power spectrum
%		 g=v_irfft(sqrt(gp).*exp(1i*angle(f)));         % take the inverse DFT using the original phase to recover the time domain signal 
%
% Inputs:
%       p   number of filters in v_filterbank or the filter spacing in k-mel/bark/erb (see 'p' and 'P' options) [ceil(4.6*log10(fs))]
%		n   length of dft
%		fs  sample rate in Hz
%		fl  low end of the lowest filter in Hz (or in mel/erb/bark/log10 with 'h' option) [default = 0Hz or, if 'l' option given, 30Hz]
%		fh  high end of highest filter in Hz (or in mel/erb/bark/log10 with 'h' option) [default = fs/2]
%		w   any sensible combination of the following:
%
%             'b' = bark scale
%             'e' = erb-rate scale
%             'l' = log10 Hz frequency scale
%             'f' = linear frequency scale [default]
%             'm' = mel frequency scale
%
%             'n' = round to the nearest FFT bin so each row of x contains only one non-zero entry
%
%             'c' = fl specifies centre of low filters instead of low edge
%             'C' = fh specifies centre of high filter instead of high edge
%             'h' = fl & fh are in mel/erb/bark/log10 instead of Hz
%             'H' = give cf outputs in mel/erb/bark/log10 instead of Hz
%
%		      'x' = lowest filter remains at 1 down to 0 frequency
%             'X' = highest filter remains at 1 up to nyquist freqency
%
%             'p' = input p specifies the number of filters [default if p>=1]
%             'P' = input p specifies the approximate filter spacing in kHz/kmel/... [default if p<1]
%
%             'z' = Treat input power spectrum at 0Hz as an impulse rather than being diffuse
%             'Z' = Treat input power spectrum at 0Hz as the sum of an impulse and a continuous component with the same amlitude as the adjacent bin
%             'q' = The first output filter gives the power of the impulse at 0Hz (regardless of the 'D' option). 'zq' ensures exact retention of DC component by zi*z
%
%             'd' = input is power spectral density (power per Hz) instead of power
%             'D' = output is power spectral density (power per Hz) instead of power
%
%             's' = single-sided input: do not add power from symmetric negative frequencies (i.e. non-DC/Nyquist inputs have already been doubled)
%             'S' = single-sided output: include power from both positive and negative frequencies (this doubles the non-DC/Nyquist outputs)
%             'w' = size(x,2)=size(xi,1)=n rather than 1+floor(n/2) although the rightmost half of x is all zeros
%
%             'g' = plot filter coefficients as graph
%             'G' = plot filter coefficients as spectrogram image [default if no output arguments present]
%
%           Legacy options: 'y'='xX', 'Y'='x', 'yY'='X', 'u'='dD', 'U'='D'
%
% Outputs:	x(p,k)  a sparse matrix containing the v_filterbank amplitudes
%		            If the il and ih output arguments are included then k=ih-il+1 otherwise k=1+floor(n/2)
%                   Note that, with the 'S' option, the peak filter values equal 2 to account for the energy in the negative FFT frequencies.
%           cf(p)   the v_filterbank centre frequencies in Hz (or in mel/erb/bark/log10 with 'H' option)
%           xi(k,p) [optional] sparse matrix that is an approximate inverse of x
%		    il      the lowest fft bin with a non-zero coefficient
%		    ih      the highest fft bin with a non-zero coefficient (Note: ih must be given if il is given and xi is omitted)
%
% The input power will be preserved if the options 'xXS' are given
%
% The output of the routine is a sparse filterbank matrix. The vector output of the filterbank can then be obtained
% by pre-multiplying an input power spectrum vector by the filterbank matrix. The input and output vectors can optionally
% be in either the power domain or the power spectral density domain.
% The routine implements the filterbank in two conceptual stages (which are merged in the practical implementation):
%
% Stage 1:
% The discrete input spectrum is converted to a continuous power spectral density using linear interpolation in frequency.
% Each element of the input spectrum influences a frequency interval of width 2d where d is the input frequency bin width.
% The DC component of the input is treated specially in one of three ways: (a) it can be treated as a normal element that
% influences an interval (-d,+d) like the other elements [default]; (b) it can be treated as an impulse at DC ['z' option];
% (c) it can be treated as a mixture of an impulse and a normal component whose value equals that of the adjacent frequency
% bin ['Z' option].
%
% Stage 2:
% The filterbank outputs are calculated by integrating the product of the continuous spectrum and a filter weight that is
% triangular in the frequency domain. Optionally, the first filterbank preserves the DC impulse component of the continuous
% spectrum ['q' option].
%
% References:
%
% [1] S. S. Stevens, J. Volkman, and E. B. Newman. A scale for the measurement
%     of the psychological magnitude of pitch. J. Acoust Soc Amer, 8: 185-190, 1937.
% [2] S. Davis and P. Mermelstein. Comparison of parametric representations for
%     monosyllabic word recognition in continuously spoken sentences.
%     IEEE Trans Acoustics Speech and Signal Processing, 28 (4): 357-366, Aug. 1980.

% Bugs/Suggestions
% (1) default frequencies won't work if the h option is specified
% (2) low default frequency is invalid if the 'l' option is specified
% (3) Add 'z' option to include a DC output as the first coefficient
% (4) Add 'Z' option to ignore the DC input component
% (5) Add 'i' option to calculate the inverse of x instead
% (6) Add option to choose the domain in which linear interpolation is performed

%      Copyright (C) Mike Brookes 1997-2024
%      Version: $Id: v_filtbankm.m $
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

% Notes:
% (1) In the comments, "FFT bin_0" assumes DC = bin 0 whereas "FFT bin_1" means DC = bin 1nfout
% (2) "input" and "output" need to be interchanged if the 'i' option is given

if nargin<6 || isempty(w)               % if no mode option, w, is specified
    w='f';                              % default mode option: 'f' = linear output frequency scale
end
wr=max(any(repmat('lebm',length(w),1)==repmat(w',1,4),1).*(1:4));           % output warping: 0=linear,1=log,2=erbrate,3=bark,4=mel
ww=any(repmat('ncChHxXyYpPzZqdDuUsSgGw',length(w),1)==repmat(w',1,23),1);    % decode all other options
% ww elements: 1=n,2=c,3=C,4=h,5=H,6=x,7=X,8=y,9=Y,10=p,11=P,12=z,13=Z,14=q,15=d,16=D,17=u,18=U,19=s,20=S,21=g,22=G,23=w
% Convert legacy option codes: 'y'='xX', 'Y'='x', 'yY'='X', 'u'='dD', 'U'='D'
ww(6)=ww(6) || (ww(8) ~= ww(9));        % convert 'y' or 'Y' (but not both) to 'x'; extend low frequencies
ww(7)=ww(7) || ww(8);                   % convert 'y' to 'X'; extend high frequencies
ww(15)=ww(15) || ww(17);                % convert 'u' to 'd'; input is also in power spectral density
ww(16)=ww(16) || ww(17) || ww(18);      % convert 'u' or 'U' to 'd'; output is in power spectral density
flhconv=repmat(wr>0 && ~ww(4),1,2);     % flag indicating need to convert filterbank limits from Hz to mel/erb/bark/log10
if nargin < 4 || isempty(fl)
    fl=30*(wr==1);                      % lower limit is 0 Hz unless 'l' option specified, in which case it is 30 Hz
    flhconv(1)=wr>0;
end
if nargin < 5 || isempty(fh)
    fh=0.5*fs;                          % max freq is the nyquist frequency
    flhconv(2)=wr>0;
end
%
% Sort out input frequency bins
%
if numel(n)>1
    error('non-standard input frequency spacing no longer supported');
else                                % n gives dft length
    nf=1+floor(n/2);                % number of input positive-frequency bins from DFT
    df=fs/n;                        % input frequency bin spacing
end
%
% Sort out output frequency bins
%
mflh=[fl fh];                       % low and high limits of filterbank triangular filters
if any(flhconv)                     % convert mflh from Hz to mel/erb/... unless already converted via 'h' option
    switch wr
        case 1                      % 'l' = log scaled
            if fl<=0
                error('Low frequency limit must be >0 for ''l'' log10-frequency option');
            end
            mflh(flhconv)=log10(mflh(flhconv));         % convert frequency limits into log10 Hz
        case 2                                          % 'e' = erb-rate scaled
            mflh(flhconv)=v_frq2erb(mflh(flhconv));     % convert frequency limits into erb-rate
        case 3                                          % 'b' = bark scaled
            mflh(flhconv)=v_frq2bark(mflh(flhconv));    % convert frequency limits into bark
        case 4                                          % 'm' = mel scaled
            mflh(flhconv)=v_frq2mel(mflh(flhconv));     % convert frequency limits into mel
    end
end
melrng=mflh(2)-mflh(1);                                 % filterbank range in Hz/mel/erb/...
if isempty(p)
    p=ceil(4.6*log10(2*(nf-1)*df));                     % default number of output filters
end
puc=ww(11) || (p<1) && ~ww(10);                         % input p specifies the filter spacing rather than the number of filters
if puc
    p=round(melrng/(p*1000))+ww(2)+ww(3)-1+ww(14);      % p now gives the number of filters (excluding DC impulse)
end
melinc=melrng/(p+ww(2)+ww(3)+1-ww(14));                 % inter-filter increment in mel
mflh=mflh+[-ww(2) ww(3)]*melinc;                        % update mflh to include the full width of all filters
%
% Calculate the output centre frequencies in Hz including dummy end points
%
pmq=p-ww(14);                                       % number of filters excluding the one for the DC impulse
cf=mflh(1)+(0:pmq+1)*melinc;                        % centre frequencies in mel/erb/... including dummy ends
cf(2:end)=max(cf(2:end),0);                         % only the first point can be negative [*** doesn't make sense for log scale ***]
switch wr                                           % convert centre frequencies to Hz from mel/erb/...
    case 1                                          % 'l' = log scaled
        mb=10.^(cf);
    case 2                                          % 'e' = erb-rate scaled
        mb=v_erb2frq(cf);
    case 3                                          % 'b' = bark scaled
        mb=v_bark2frq(cf);
    case 4                                          % 'm' = mel scaled
        mb=v_mel2frq(cf);
    otherwise                                       % [default] = linear scaled; no conversion needed
        mb=cf;
end
%
% sort out 2-sided input frequencies
%
fin=(-nf:nf)*df;                                    % reflect negative frequencies excluding DC
nfin=length(fin);                                   % length of extended input frequency list         [nfin=2*nf+1]
%
% now sort out the list of output frequencies
%
fout=mb;                                            % output centre frequencies in Hz including dummy values at each end
highex=ww(7) && (fout(end-1)<fin(end));             % extend at high end if 'X' specified and final centre frequency < Nyquist
if ww(6)                                            % ww(6)='x': extend first filter at low end to DC
    fout=[0 0 fout(2:end)];                         % ... add two dummy values at DC instead of previous single dummy value
end
if highex                                           % extend last filter at high end to Nyquist
    fout=[fout(1:end-1) fin(end) fin(end)];         % ... add two dummy values at Nyquist instead of previous single dummy value
end
fout=min(fout,fs/2);                                % limit output filters to Nyquist frequency
nfout=length(fout);                                 % number of output filters including one or two dummy points at each end
foutin=[fout fin];
nfall=length(foutin);                               % = nfout + nfin
wleft=[0 fout(2:nfout)-fout(1:nfout-1) 0 fin(2:nfin)-fin(1:nfin-1)]; % width of lower triangle attached to each node
wright=[wleft(2:end) 0];                            % width of upper triangle attached to each node
ffact=[0 ones(1,nfout-2) 0 0 ones(1,2*nf-1) 0];     % valid triangle posts
ffact(wleft+wright==0)=0;                           % disable null width triangles (*** probably unnecessary if all frequencies are distinct ***)
[fall,ifall]=sort(foutin);                          % fall is sorted frequencies with fall=foutin(ifall)
jfall=zeros(1,nfall);                               % create inverse index ...
infall=1:nfall;                                     % ...
jfall(ifall)=infall;                                % ... inverse-index satisfying foutin=fall(jfall)
ffact(ifall([1:max(jfall(1),jfall(nfout+1))-2 min(jfall(nfout),jfall(nfall))+2:nfall]))=0;  % zap input nodes that lie outside the output filters
nxto=cumsum(ifall<=nfout);                          % next output node to the right (or equal) to each node
nxti=cumsum(ifall>nfout);                           % number of input nodes to the left (or equal) to each node
nxtr=min(nxti+1+nfout,nfall);                       % next input node to the right of each value (or nfall if none)
nxtr(ifall>nfout)=1+nxto(ifall>nfout);              % next post to the right of opposite input/output type (using sorted indexes)
nxtr=nxtr(jfall);                                   % next post to the right of opposite input/output type (converted to unsorted indices) or if none: nfall or (nfout+1)
%
% The interpolated spectrum at any frequency can be expressed as the sum of the values at the adjacent input bins
% multiplied by triangular weights that decreases from 1 to 0 between the two bins. The value at an output bin
% is equal to the integral of the interpolated spectrum multiplied by a triangular weight that decreases from
% 1 to 0 either side of the output bin. Thus, if all input/output bins are sorted into ascending order, the
% interval between two adjacent bins contains four partial triangles (a.k.a. trapeziums): two "lower" triangles
% that increase with frequency and two "upper" triangles that decrease with frequency. We need to integrate the
% resultant four input-output trapezium products and add the integrals onto the sum for the appropriate output bins.
% Each triangle has a "post" at one end and is zero at the other end; we enumerate the triangle pairs by pairing
% all input and output triangles with the first available triangle of the other type (i.e. output or input) whose
% rightmost node is to the right of the entire first triangle.
%
% The general result for integrating the product of two trapesiums with
% heights (a,b) and (c,d) over a width x is (ad+bc+2bd+2ac)*x/6
%
% integrate product of lower triangles whose posts (and rightmost nodes) are ix1 and jx1
%
msk0=(ffact>0);                                     % posts with a non-zero magnitude
msk=msk0 & (ffact(nxtr)>0);                         % select triangle pairs with both posts having non-zero magnitudes
ix1=infall(msk);                                    % unsorted indices of leftmost post of pair
jx1=nxtr(msk);                                      % unsorted indices of rightmost post of pair
vfgx=foutin(ix1)-foutin(jx1-1);                     % portion of triangle attached to rightmost post that lies to the left of the leftmost post
yx=min(wleft(ix1),vfgx);                            % integration length. Maybe more efficient: dfall=diff(fall); yx=dfall(jfall(ix1)-1)
wx1=ffact(ix1).*ffact(jx1).*yx.*(wleft(ix1).*vfgx-yx.*(0.5*(wleft(ix1)+vfgx)-yx/3))./(wleft(ix1).*wleft(jx1)+(yx==0));

% integrate product of upper triangles whose posts are ix2 and jx2 and whose rightmost nodes are ix2+1 and jx2+1

nxtu=max([nxtr(2:end)-1 0],1);                      % post of the upper triangle of opposite type whose rightmost end is to the right of this triangle's rightmost end
msk=msk0 & (ffact(nxtu)>0);                         % select triangle pairs with both posts having non-zero magnitudes
ix2=infall(msk);                                    % unsorted indices of leftmost post of pair
jx2=nxtu(msk);                                      % unsorted indices of rightmost post of pair
vfgx=foutin(ix2+1)-foutin(jx2);                     % length of left triangle to the right of the right post
yx=min(wright(ix2),vfgx);                           % integration length
yx(foutin(jx2+1)<foutin(ix2+1))=0;                  % zap invalid triangles where the rightmost ends are in the wrong order
wx2=ffact(ix2).*ffact(jx2).*yx.^2.*((0.5*(wright(jx2)-vfgx)+yx/3))./(wright(ix2).*wright(jx2)+(yx==0));

% integrate lower triangle and upper triangle that ends to its right

nxtu=max(nxtr-1,1);                                 % post of the upper triangle of opposite type whose rightmost end is to the right of this triangle's post
msk=msk0 & (ffact(nxtu)>0);                         % select triangle pairs with both posts having non-zero magnitudes
ix3=infall(msk);                                    % unsorted indices of lower triangle
jx3=nxtu(msk);                                      % unsorted indices of upper triangle
vfgx=foutin(ix3)-foutin(jx3);                       % length of upper triangle to the left of the lower post
yx=min(wleft(ix3),vfgx);                            % integration length
yx(foutin(jx3+1)<foutin(ix3))=0;                    % zap invalid triangles where the rightmost ends are in the wrong order
wx3=ffact(ix3).*ffact(jx3).*yx.*(wleft(ix3).*(wright(jx3)-vfgx)+yx.*(0.5*(wleft(ix3)-wright(jx3)+vfgx)-yx/3))./(wleft(ix3).*wright(jx3)+(yx==0));

% integrate upper triangle and lower triangle that starts to its right

nxtu=[nxtr(2:end) 1];
msk=msk0 & (ffact(nxtu)>0);                         % select triangle pairs with both posts having non-zero magnitudes
ix4=infall(msk);                                    % unsorted indices of upper triangle
jx4=nxtu(msk);                                      % unsorted indices of lower triangle
vfgx=foutin(ix4+1)-foutin(jx4-1);                   % length of upper triangle to the left of the lower post
yx=min(wright(ix4),vfgx);                           % integration length
wx4=ffact(ix4).*ffact(jx4).*yx.^2.*(0.5*vfgx-yx/3)./(wright(ix4).*wleft(jx4)+(yx==0));
%
% now assemble the matrix
%
iox=sort([ix1 ix2 ix3 ix4;jx1 jx2 jx3 jx4]);        % iox(1,:) are output posts, iox(2,:) are input posts
msk=iox(2,:)<=(nfall+nfout)/2;                      % find references to negative input frequencies
iox(2,msk)=(nfall+nfout+1)-iox(2,msk);              % convert negative frequencies to positive
%
% Sort out output gains:
% If output is power then output gain is 1; if output is power/Hz then output gain is 1/area of output filter
%
if ww(6)                                            % ww(6)='x': if lowest filter extended to DC, we added a dummy point at 0Hz, so
    iox(1,iox(1,:)==2)=3;                           % merge lowest two output nodes
end
if highex                                           % if highest filter extended, we added a dummy point at Nyquist, so
    iox(1,iox(1,:)==nfout-1)=nfout-2;               % merge highest two output nodes
end
x=sparse(iox(1,:)-1-ww(6),max(iox(2,:)-nfout-nf,1),[wx1 wx2 wx3 wx4],pmq,nf);   % forward transformation matrix without input/output gains
gout=full(sum(x,2));                                % area of each output integral
goutd=sparse(1:pmq,1:pmq,(gout+(gout==0)).^(-1));   % create sparse diagonal matrix of output gains
gouti=full(sum(x(:,1+ww(12):end),2));                                % area of each output integral excluding DC if 'z' option given
    goutid=sparse(1:pmq,1:pmq,(gouti+(gouti==0)).^(-1));   % create sparse diagonal matrix of output gains
%
% Sort out input gains:
% If input is power then input gain is 1/area; if input is power/Hz then input gain is 1
%
gin=fin(3:nfin)-fin(1:nfin-2);                              % full width of input interpolation filters
gin=2*(gin+(gin==0)).^(-1);                                 % input gain equals 1/area
ginsi=repmat(1+ww(19),1,nf-2);                        % 's' option means all inputs except DC and Nyquist have been doubled
ginsd=sparse(1:nf,1:nf,[1-ww(12) ginsi.^(-1) 1]);                        % ... cancel this out with additional input scaling for forward transform
ginsid=sparse(1:nf,1:nf,[2*(1-ww(12)) ginsi 2]);     % and back again for inverse transform
gind=sparse(1:nf,1:nf,gin(end-nf+1:end));                   % input gains
%
% Now create the x and xi matrices
%
switch 2*ww(16)+ww(15)
    case 0                          % '': input and output are both power
        xi=ginsid*x'*goutid;
        x=x*(gind*ginsd);
    case 1                          % 'd': input is power/Hz, output is power
        xi=(ginsid*gind)*x'*goutid;
        x=x*ginsd;
    case 2                          % 'D': input is power, output is power/Hz
        xi=ginsid*x';
        x=goutd*x*(gind*ginsd);
    case 3                              % 'dD': input and output are both power/Hz
        xi=(ginsid*gind)*x';
        x=goutd*x*ginsd;
end
if ww(20)                               % 'S': double outputs to include negative frequency energy
    x=2*x;
    xi=0.5*xi;
end
if ww(13)                               % 'Z': DC input is an impulse plus a diffuse component
    x(:,2)=x(:,2)+x(:,1)*ginsd(2,2);    % power of diffuse component at DC is equal to that opf adjacent bin corrected for 's' option
    x(:,1)=0;                           % Eliminate references to DC input in forward transform only
end
if ww(14)                               % 'q': we need an extra output that replicates the DC component
    if ww(12)                           % 'z': DC input is an impulse
        x=[sparse(1,1,1,1,nf); x];
        xi=[sparse(1,1,1,nf,1) xi];
    elseif ww(13)                       % 'Z': DC input is an impulse plus a diffuse component
        x=[sparse([1 1],[1 2],[1 -ginsd(2,2)],1,nf); x]; % impulse component is DC input minus adjacent bin corrected for 's' option
        xi=[sparse(1,1,1,nf,1) xi];
    else
        x=[sparse(1,nf); x];            % '': DC input is diffuse as normal
        xi=[sparse(nf,1) xi];
    end
end
%
% sort out the output argument options
%
if ~ww(5)                                   % output cf in Hz instead of mel/erb/...
    cf=[zeros(1,ww(14)) mb(2:pmq+1)];       % ... and include an initial 0 if 'q' option (ww(14)==1)
else                                        % keep cf in mel/erb/...
    if ww(14)                               % 'q' (ww(14)==1): we need an extra output for the DC component
        if wr==1                            % log-scaled so ...
            cf=[-Inf cf(2:p)];              % ... DC corresponds to -Inf
        else                                % not log-scaled ...
            cf=[0 cf(2:p)];                 % ... DC corresponds to 0
        end
    else                                    % no 'q' option (ww(14)==0) ...
        cf=cf(2:p+1);                       % ... just remove dummy end frequencies
    end 
end
if ww(1)                                    % round outputs to the centre of gravity bin
    sx2=sum(x,2);                           % sum of each row
    msk=full(sx2~=0);
    vxc=zeros(pmq,1);
    vxc(msk)=round((x(msk,:)*(1:nf)')./sx2(msk));   % find centre of gravity of each row
    x=sparse(1:pmq,vxc,sx2,pmq,nf);             % put all the weight into the centre of gravity bin
end
il=1; % default range is entire x maxtrix
ih=nf;
if nargout > 3                                  % if il and/or ih output arguments are specified ...
    if nargout==4                               % xi has been omitted ...
    msk=full(any(x>0,1));                       % find non-zero columns in x
    else                                        % xi output included
        msk=full(any(x>0,1) | any(xi>0,2)');    % find non-zero columns in x or rows in xi
    end
    il=find(msk,1);                             % il is first non-zero column
    if ~numel(il)                               % if x is all zeros ...
        il=1;                                   % ... set il and ih to 1
        ih=1;                              
    elseif nargout >3
        ih=find(msk,1,'last');                  % ih is last non-zero column
    end
    x=x(:,il:ih);                               % remove redundant columns from x
    if nargout==4                               % xi has been omitted ...
        xi=il;                                  % shift the il and ih outputs up by one position
        il=ih;
    else
        xi=xi(il:ih,:);                         % remove redundant rows from xi
    end
elseif ww(23)                                   % ww(23)='w': use whole dft
    x=[x sparse(p,n-nf)];                       % append zeros onto x
    xi=[xi; xi(n-nf+1:-1:2,:)];                 % reflect elements other than the DC and Nyquist
end
%
% plot results if no output arguments or 'g','G' options given
%
if ~nargout || ww(21) || ww(22)                 % plot idealized filters
    ww(22)=~ww(21);                             % 'G' option is the default unless 'g' is specified
    finax=(il-1:ih-1)*df;                       % input frequency axis
    newfig=0;
    if  ww(21)
        plot(finax,x(:,il:ih)'); 
        hold on  
        plot(finax,sum(x,1),'--k');
        v_axisenlarge([-1 -1.05]);
        plot(repmat(mb(2:end-1),2,1),get(gca,'ylim'),':k');
        hold off
        title(['filtbankm: mode = ''' w '''']);
        xlabel(['Frequency (' v_xticksi 'Hz)']);
        ylabel('Weight');
        newfig=1;
    end
    if  ww(22)
        if newfig
            figure;
        end
        imagesc(finax,1:pmq,x);
        axis 'xy'
        colorbar;
        hold on
        ylim=get(gca,'ylim');
        plot(repmat(mb(2:end-1),2,1),ylim,':w');
        hold off
        v_cblabel('Weight');
        switch wr
            case 1
                type='Log-spaced';
            case 2
                type='Erb-spaced';
            case 3
                type='Bark-spaced';
            case 4
                type='Mel-spaced';
            otherwise
                type='Linear-spaced';
        end
        ylabel([type ' Filter']);
        xlabel(['Frequency (' v_xticksi 'Hz)']);
        title(['filtbankm: mode = ''' w '''']);
    end

end