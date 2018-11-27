function z=v_convfft(x,h,d,m,h0,x1,x2)
%V_CONFFT 1-D convolution or correlation using FFT
%
%  Usage: (1) z=v_convfft(x,h,d1,'',1,1,size(x,d)+length(h)-1);            % equivalent to conv(x,h)
%
%         (2) hh=v_convfft(length(x),h,2,'z',1,1,length(x)+length(h)-1);   % precalculate fft(h) for multiple calls
%             z=v_convfft(x,hh);                                           % also equivalent to conv(x,h)
%
%         (3) z=v_convfft(x,h);                                            % equivalent to filter(h,1,x)
%             z=v_convfft(x,h,d1,'',1,1,size(x,d));                        % equivalent to filter(h,1,x)
%
%         (4) z=v_convfft(x,h,d,'X',1,2-max(size(x,d),length(h)),max(size(x,d),length(h)));  % equivalent to xcorr(x,h)
%   
%         (5) z=v_convfft(x,h,d,'x',floor((1+length(h))/2),1,size(x,d));   % equivalent to imfilter(x,h) 
%
%  Inputs: x     input vector or array (or size(x,d) for the 'z' option)
%          h     impulse response (or z output from previous call with the 'z' option)
%          d     dimension of x to do convolution along [first non-singleton]
%          m     mode options (see below)
%          h0    origin sample number in h (can be outside the range 1:length(h)) [default: 1]
%          x1,x2 range of rows/columns in x to align with origin of h (can be outside the range 1:size(x,d)) [default: 1,size(x,d)]
%
% Outputs: z     output from convolution/correlation. The same size and shape as x except that size(z,d)=x2-x1+1
%                If m='z' is specified, then z is a structure that can be used as h in a subsequent call
%
% Mode is any sensible combination of the following
%          'x'   perform real correlation rather than convolution (reflects h around sample h0)
%          'X'   perform complex correlation rather than convolution (reflects and conjugates h around sample h0)
%          'z'   Precalculate fft(h) for efficiency. Input d must be given explicitly and input x equals size(x,d).

%      Copyright (C) Mike Brookes 2016-2017
%      Version: $Id: v_convfft.m 10865 2018-09-21 17:22:45Z dmb $
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
if ~isstruct(h) % normal input calling sequence
    if nargin<4 || isempty(m)
        m='';                       % set default mode string
    end
    if nargin<5 || isempty(h0)
        h0=1;                       % set default h origin
    end
    s=size(x);                      % get the structure of x
    ps=numel(x);                  	% number of elements in x
    ns=length(s);                   % number of dimensions in x
    if any(m=='z')      % output pre-computed structure instead of convolution
        if nargin<3 || isempty(d)   % if d unspecified
            error('d must be specified explicitly');
        end
        if numel(x)~=1              % x contains nx for a future call
            error('x must equal size(*,d)');
        end
        nx=x;                       % save x as the value of nx
    else
        if nargin<3 || isempty(d)       % if d unspecified
            if ps<2
                d=1;                    % if d is a singleton or is empty
            else
                d=find(s>1,1);          % d = first nonsingleton dimension
            end
        end
        nx=s(d);                        % length in correlation dimension
    end
    k=ps/nx;                        % total size of all other dimensions
    if nargin<6 || isempty(x1)
        x1=1;                       % default initial lag
    end
    if nargin<7 || isempty(x2)
        x2=nx;                      % default final lag
    end
    nz=x2-x1+1;                     % number of output lags required
    h=h(:);                         % force h to be a column
    nh=length(h);
    if any(m=='X')                  % do complex correlation rather than convolution
        h=conj(h(nh:-1:1));         % reflect and conjugate h
        h0=nh+1-h0;                 % reflect the position of h0
    elseif any(m=='x')              % do real correlation
        h=h(nh:-1:1);               % reflect h
        h0=nh+1-h0;                 % reflect the position of h0
    end
    hmin=h0+x1-nx;                  % smallest h index ever used
    hmax=h0+x2-1;                   % largest h index ever used
    xmin=x1+h0-nh;                  % smallest x index ever used
    xmax=x2+h0-1;                   % largest x index ever used
    if hmin>1 || hmax<nh            % we can delete some unused h values
        hmin=max(hmin,1);
        h=h(hmin:min(hmax,nh));     % trim h if possible
        nh=length(h);
        h0=h0-hmin+1;               % update h0 to new position
    end
    if xmin>1 || xmax<nx            % we can delete some unused x values
        vmin=max(xmin,1);           % we will trim v to v(vmin:vmax)
        vmax=min(xmax,nx);
        x1=x1-vmin+h0;              % update x1,x2 to new positions assuming h0=0
        x2=x2-vmin+h0;
    else
        vmin=1;
        vmax=nx;
        x1=x1+h0-1;                 % update x1,x2 to new positions assuming h0=0
        x2=x2+h0-1;
    end
    nv=vmax-vmin+1;                 % number of elements of v to retain
    nxz=min(max(max(nh-x1,0),max(x2-nv,0)),nh-1); % number of zeros to add to v is the larger of the number needed at each end
    [fnx,enx]=log2(nv+nxz);         % round up length of zero-padded v to next power of 2
    nf=pow2(1,enx-(fnx==0.5));      % actual length of dft is a power of 2
    fmin=max(x1,1);                 % range of indices to extract from circular convolution
    fmax=min(x2,min(nf,nx+nh-1));
    zmin=max(1,2-x1);               % range of indices for non-zero output values
    zmax=zmin+fmax-fmin;
    fh=fft(h,nf,1);
else                % h is the z output of a previous call with the 'z' option
    d=h.d;          % x dimension to convolve along
    nx=h.nx;        % original size(x,d)
    ns=h.ns;        % number of dimensions of x
    nv=h.nv;        % number x values needed (might be < nx)
    vmin=h.vmin;    % first x value needed (might be > 1)
    vmax=h.vmax;    % last x value needed (might be < nx)
    nf=h.nf;        % dft length
    fh=h.fh;        % dft of impulse response h
    fmin=h.fmin;    % first fh value needed
    fmax=h.fmax;    % last fh value needed
    nz=h.nz;        % output size(z,d)
    zmin=h.zmin;    % first non-zero z value
    zmax=h.zmax;    % last non-zero z value
    s=size(x);      % get the structure of x
    k=numel(x)/nx;  % total size of the rest of x
    if size(x,d)~=nx || length(s)~=ns
        error('input x has incompatible dimensions');
    end
end
if  ~isstruct(h) && any(m=='z')    % save required information as a structure for next call
    z.d=d;          % x dimension to convolve along
    z.nx=nx;        % original size(x,d)
    z.ns=ns;        % number of dimensions of x
    z.nv=nv;        % number x values needed (might be < nx)
    z.vmin=vmin;    % first x value needed (might be > 1)
    z.vmax=vmax;    % last x value needed (might be < nx)
    z.nf=nf;        % dft length
    z.fh=fh;        % dft of impulse response h
    z.fmin=fmin;    % first fh value needed
    z.fmax=fmax;    % last fh value needed
    z.nz=nz;        % output size(z,d)
    z.zmin=zmin;    % first non-zero z value
    z.zmax=zmax;    % last non-zero z value
elseif ~isempty(x)  % there is data to convolve
    if d==1         % reshape x if necessary
        v=reshape(x,nx,k);
    else
        v=reshape(permute(x,[d:ns 1:d-1]),nx,k);
    end
    if nv<nx        % we can delete some unused v values
        v=v(vmin:vmax,:);
    end
    zz=ifft(fft(v,nf,1).*repmat(fh,1,k));    % do the convolution
    z=zeros(nz,k);                  % reserve space for the output
    z(zmin:zmax,:)=zz(fmin:fmax,:); % extract values from the convolution
    s(d)=nz;                        % update the size of the output
    if d==1
        z=reshape(z,s);
    else
        z=permute(reshape(z,s([d:ns 1:d-1])),[ns+2-d:ns 1:ns+1-d]);
    end
else
    z=[];           % no input data
end



