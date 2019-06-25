function w = v_windows(wtype,n,mode,p,ov)
%V_WINDOWS Generate a standard windowing function (TYPE,N,MODE,P,H)
% Usage: (1) w=v_windows(3,n)'; % same as w=hamming(n);
%        (2) w=v_windows(3,n,'l')'; % same as w=hanning(n,'periodic');
%        (3) w=v_windows(2,n)'; % same as w=hanning(n);
%        (4) w=v_windows(2,n,'l')'; % same as w=hanning(n,'periodic');
%
% Inputs:   WTYPE  is a string or integer specifying the window type (see below)
%           N      is the number of output points to generate (actually FLOOR(N))
%                  and also determines the period of the underlying window [default 256]
%           MODE   is a string specifying various options (see below)
%           P      is a vector of parameters required for some window types
%           OV      is the overlap in samples between succesive windows (must be H<=N/2 and
%                  used only for the 'o' option) [default floor(N/2)]
%
% Outputs:  W(1,N)   is the output window. If no output is specified, a graph
%                  of the window and its frequency response will be drawn.
%
% The WTYPE input specifies one of the following window types (either name, short or code can be used):
%
%       Name     Short Code  Params
%    'blackman'   'b'    6
%    'cauchy'     'y'   13     1
%    'cos'        'c'   10     1      cos window to the power P [default P=1]
%    'dolph'      'd'   14     1      Dolph-Chebyshev window with sideband attenuation P dB [default P=50]
%                                     Note that this window has impulses at the two ends.
%    'gaussian'	  'g'   12     1      truncated at +-P std deviations [default P=3]
%    'hamming'    'm'    3
%    'hanning'    'n'    2            also called "hann" or "von hann"
%    'harris3'	  '3'    4            3-term blackman-harris with 67dB sidelobes
%    'harris4'	  '4'    5            4-term blackman-harris with 92dB sidelobes
%    'kaiser'	  'k'   11     1      with parameter P (often called beta) [default P=8]
%    'rectangle'  'r'    1
%    'triangle'   't'    9     1      triangle to the power P [default P=1]
%    'tukey'      'u'   15     1      cosine tapered 0<P<1 [default P=0.5]
%    'vorbis'     'v'    7            perfect reconstruction window from [2] (use mode='sE2')
%    'rsqvorbis'  'w'    8            raised squared vorbis with lower sidelobes (use mode='sdD2')
%
% Window equivalences:
%
%    'hanning'   =    cos(2) = tukey(1)
%    'rectangle' =    tukey(0)
%    'reisz'     =    triangle(2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% The MODE input determines the scaling and sampling of the window function and
%     is a text string with characters whose meanings are given below. The
%     default is 'ubw' for window functions whose end points are non-zero and 'unw'
%     for window functions whose end points are zero (e.g. hanning window)
%
%         scaling:
%                1-9 = set target gain to G = 1/n in scaling options [default n=1 so G=1]
%                  u = unscaled  with the peak of the underlying continuous
%                      window equalling G. [default]
%                  p = scaled to make the actual peak G
%                  d = scaled to make DC gain equal to G (summed sample values).
%                  D = scaled to make average value equal G
%                  e = scaled to make energy = G (summed squared sample values).
%                  E = scaled to make mean energy = G (mean squared sample values).
%                  q = take square root of the window after scaling
%
%         first and last samples (see note on periodicity below):
%                  b [both]    = The first and last samples are at the extreme ends of
%                                the window [default for most windows].
%                  n [neither] = The first and last samples are one sample away from the ends
%                                of the window [default for windows having zero end points].
%                  s [shifted] = The first and last samples are half a sample away from the
%                                ends of the window .
%                  l [left]    = The first sample is at the end of the window while the last
%                                is one sample away from the end .
%                  r [right]   = The first sample is one sample away from the end while the
%                                last is at the end of the window .
%
%         whole/half window (see note on periodicity below):
%                  w = The whole window is included [default]
%                  c = The first sample starts in the centre of the window
%                  h = The first sample starts half a sample beyond the centre
%
%         convolve with rectangle
%                  o = convolve w(n) with a rectangle of length N-H [default floor(N/2)]
%                      This can be used to force w(n) to satisfy the Princen-Bradley condition
%
% Periodicity:
%     The underlying period of the window function depends on the chosen mode combinations and
%     is given in the table below. For overlapping windows with perfect reconstruction choose
%     N to be an integer and modes 'ws', 'wl' or 'wr'.
%
%        Whole/half window -->     w         h         c
%
%        End points:       b      N-1      2N-1      2N-2
%                          n      N+1      2N+1       2N
%                          s       N        2N       2N-1
%                          l       N       2N+1       2N
%                          r       N       2N-1      2N-2
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To obtain unity gain for windowed overlap-add processing you can use
% the following. Bandwidths have been multiplied by the window length.
% For perfect reconstruction, you can use any multiple of the overlap factors
% shown assuming the same window is used for both analysis and synthesis.
% These are the Princen-Bradley conditions: fliplr(w)=w, w(i)^2+w(i+n/2)^2=1
% Any symmetric window will satisfy the conditions with mode 'boqD2' [3].
%
%   Window     Mode Overlap-Factor Sidelobe  3dB-BW  6dB-BW Equiv-noise-BW
%   rsqvorbis  sqD2     2           -26dB     1.1      1.5      1.1
%   hamming    sqD2     2,3,5       -24dB     1.1      1.5      1.1
%   hanning    sqD2     2,3,5       -23dB     1.2      1.6      1.2 =cos('sE2')
%   cos        sE2      2,3,5       -23dB     1.2      1.6      1.2 used in MP3
%   kaiser(5)  boqD2    2           -23dB     1.2      1.7      1.3 used in AAC [4]
%   vorbis     sE2      2,9,15      -21dB     1.3      1.8      1.4 used in Vorbis
%   hamming    sE4      3,4,5       -43dB     1.3      1.8      1.4
%   hanning    sE4      3,4,5       -31dB     1.4      2.0      1.5
% The integer following D or E in the mod string should match the overlap factor
%
% References:
%  [1]  F. J. Harris. On the use of windows for harmonic analysis with the
%       discrete fourier transform. Proc IEEE, 66 (1): 51-83, Jan. 1978.
%  [2]	L. D. Fielder, M. Bosi, G. Davidson, M. Davis, C. Todd, and S. Vernon.
%       AC-2 and AC-3: Low-complexity transform-based audio coding.
%       In Audio Engineering Society Conference: Collected Papers on Digital Audio Bit-Rate Reduction, May 1996.
%  [3]	J. Princen, A. Johnson, and A. Bradley. Subband/transform coding using filter
%       bank designs based on time domain aliasing cancellation.
%       In Proc. IEEE Intl Conf. Acoustics, Speech and Signal Processing, volume 12,
%       pages 2161-2164, 1987. doi: 10.1109/ICASSP.1987.1169405.
%  [4]	T. Sporer, K. Brandenburg, and B. Edler.
%       The use of multirate filter banks for coding of high quality digital audio.
%       In Proc EUSIPCO, volume 1, pages 211-214, 1992.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Copyright (C) Mike Brookes 2002-2015
%      Version: $Id: v_windows.m 10477 2018-06-03 16:16:45Z dmb $
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
persistent wnam wnami wnamp
if isempty(wnam)
    wnam={'rectangle','hanning','hamming','harris3','harris4','blackman',...
        'vorbis','rsqvorbis','triangle','cos','kaiser','gaussian',...
        'cauchy','dolph','tukey','r','n','m','3','4','b','v','w','t','c','k','g','y','d','u'};
    wnami=[1:15 1:15];
    wnamp=[0 0 0 0 0 0 0 0 1 1 1 1 1 1 1]; % parameters required
end
kk=[-1 1 1 -1; 0 0 2 -2; 0 1 2 -1;    % mode  w,  h,  c  [normal windows]
    -1 0 1 0; 0 0 2 0; 0 1 2 1;       % modes lw, lh, lc
    -1 2 1 0; 0 0 2 -2; 0 1 2 -1;     % modes rw, rh, rc
    -1 1 1 -1; 0 0 2 -2; 0 1 2 -1;    % modes bw, bh, bc
    -1 1 1 1; 0 0 2 0; 0 1 2 1;       % modes nw, nh, nc
    -1 1 1 0; 0 0 2 -1; 0 1 2 0;];    % modes sw, sh, sc

if nargin<2 || isempty(n)
    n=2520; % 2^3 * 3^2 * 5 * 7
end
if nargin<3 || isempty(mode) || ~ischar(mode)
    mode='uw';
end
mm=zeros(1,length(mode)+1);
ll='hc lrbns';
for i=1:8
    mm(mode==ll(i))=i-3;
end
wtype=lower(wtype);
k=1+3*max(mm)-min(mm);
if k<4
    k=k+12*any(wtype==[2 6 7 9 10 15]);
end
if any(mode=='o') % need to convolve with rectangle
    if nargin<5 || ~numel(h)
        ov=floor(n/2);
    end
    n=n-ov+1; % shorten baseline window
else
    ov=0;
end

% determine the sample points
% the number of points corresponding to a full period is (kk(k,3)*n+kk(k,4))
fn=floor(n);
kp=(kk(k,3)*n+kk(k,4)); % number of points corresponding to a full period
ks=kk(k,1)*fn+kk(k,2);
v=((0:2:2*fn-2)+ks)/kp;

% now make the window
if ischar(wtype)
    wtype=wnami(find(strcmp(wtype,wnam),1));
end
switch wtype
    case 1 % 'rectangle'
        w = ones(size(v));     
    case 2 % 'hanning'
        w = 0.5+0.5*cos(pi*v);             
    case 3 % 'hamming'
        w = 0.54+0.46*cos(pi*v);        
    case 4 % 'harris3'
        w = 0.42323 + 0.49755*cos(pi*v) + 0.07922*cos(2*pi*v);        
    case 5 % 'harris4'
        w = 0.35875 + 0.48829*cos(pi*v) + 0.14128*cos(2*pi*v) + 0.01168*cos(3*pi*v);        
    case 6 % 'blackman'
        w = 0.42+0.5*cos(pi*v) + 0.08*cos(2*pi*v);        
    case 7 % 'vorbis'
        w = sin(0.25*pi*(1+cos(pi*v)));        
    case 8 % 'rsqvorbis'
        w = 0.571-0.429*cos(0.5*pi*(1+cos(pi*v)));        
    case 9 % 'triangle'
        if nargin<4, p=1; end;
        w = 1-abs(v).^p(1);
    case 10 % 'cos'
        if nargin<4, p=1; end;
        w = cos(0.5*pi*v).^p(1);        
    case 11 % 'kaiser'
        if nargin<4, p=8; end;
        w=besseli(0,p*sqrt(1-v.^2))/besseli(0,p(1));        
    case 12 % 'gaussian'
        if nargin<4, p=3; end;
        w=exp(-0.5*p(1)^2*(v.*v));     
    case 13 % 'cauchy'
        if nargin<4, p=1; end;
        w = (1+(p(1)*v).^2).^-1;
    case 14 % 'dolph'
        if nargin<4, p=50; end;
        if rem(ks+kp,2)     % for shifted windows, we generate twice as many points
            w=chebwin(2*kp+1,abs(p(1)));
            w=w((1:2:2*fn)+round(ks+kp));
        else
            w=chebwin(kp+1,abs(p(1)));
            w=w((1:fn)+round((ks+kp)/2));
        end        
    case 15 % 'tukey'
        if nargin<4, p=0.5; end;
        if p(1)>0
            p(1)=min(p(1),1);
            w = 0.5+0.5*cos(pi*max(1+(abs(v)-1)/p(1),0));
        else
            w = ones(size(v));
        end    
    otherwise
        error(sprintf('Unknown window type: %s', wtype));
end;
% now convolve with rectangle
if ov
    %     w=filter(ones(1,ov),1,w); % more adds but might be just as efficient as cumsum
    w=cumsum(w);
    w(n+1:n+ov-1)=w(n)-w(n-ov+1:n-1);
    w(ov+1:n)=w(ov+1:n)-w(1:n-ov);
    n=n+ov-1; % restore original value of n
end
% scale if required
mk=find(mode>='1' & mode<='9',1);
if numel(mk)
    g=1/(mode(mk)-'0');
else
    g=1;
end
if any(mode=='d')
    w=w*(g/sum(w));
elseif any(mode=='D') || any(mode=='a')
    w=w*(g/mean(w));
elseif any(mode=='e')
    w=w*sqrt(g/sum(w.^2));
elseif any(mode=='E')
    w=w*sqrt(g/mean(w.^2));
elseif any(mode=='p')
    w=w*(g/max(w));
end
if any(mode=='q')
    w=sqrt(w);
end
if ~nargout
    v_windinfo(w,n);
    np=wnamp(wtype); % number of parameters
    if np>0
        title(sprintf('%s(%s) window  - mode=''%s''',wnam{wtype},sprintf('%g',p(1:np)),mode));
    else
        title(sprintf('%s window - mode=''%s''',wnam{wtype},mode));
    end
end

