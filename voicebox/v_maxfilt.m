function [y,k,y0]=v_maxfilt(x,f,n,d,x0)
%V_MAXFILT find max of an exponentially weighted sliding window  [Y,K,Y0]=(X,F,nn,D,X0)
%
% Usage: (1) y=v_maxfilt(x)   % maximum filter along first non-singleton dimension
%        (2) y=v_maxfilt(x,0.95) % use a forgetting factor of 0.95 (= time const of -1/log(0.95)=19.5 samples)
%        (3) Two equivalent methods (i.e. you can process x in chunks):
%                 y=v_maxfilt([u v]);      [yu,ku,x0)=v_maxfilt(u);
%                                        yv=v_maxfilt(v,[],[],[],x0);
%                                        y=[yu yv];
%
% Inputs:  X  Vector or matrix of input data
%          F  exponential forgetting factor in the range 0 (very forgetful) to 1 (no forgetting)
%             F=exp(-1/T) gives a time constant of T samples [default = 1]
%          n  Length of sliding window [default = Inf (equivalent to [])]
%          D  Dimension for work along [default = first non-singleton dimension]
%         X0  Initial values placed in front of the X data
%
% Outputs: Y  Output matrix - same size as X
%          K  Index array: Y=X(K). (Note that these value may be <=0 if input X0 is present)
%         Y0  Last nn-1 values (used to initialize a subsequent call to
%             v_maxfilt()) (or last output if n=Inf)
%
% This routine calaulates y(p)=max(f^r*x(p-r), r=0:n-1) where x(r)=-inf for r<1
% y=x(k) on output

% Example: find all peaks in x that are not exceeded within +-w samples
% w=4;m=100;x=rand(m,1);[y,k]=v_maxfilt(x,1,2*w+1);p=find(((1:m)-k)==w);plot(1:m,x,'-',p-w,x(p-w),'+')

% Bugs/suggestion
% (1) if n<0 then centre filter support of the current sample (or make it +-n)

%      Copyright (C) Mike Brookes 2003-2014
%      Version: $Id: v_maxfilt.m 10865 2018-09-21 17:22:45Z dmb $
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

s=size(x);
if nargin<4 || isempty(d)           % if d is unspecified
    d=find(s>1,1);                  % find first non-singleton dimension
    if isempty(d)
        d=1;                        % else defailt to dimension 1
    end
end
if nargin>4 && numel(x0)>0          % initial values specified
    y=shiftdim(cat(d,x0,x),d-1);    % concatenate x0 and x along d
    nx0=size(x0,d);                 % number of values added onto front of data
else                                
    y=shiftdim(x,d-1);              % dimension specified, d
    nx0=0;                          % no values added onto front of data
end
s=size(y);
s1=s(1);                            % size of active dimension
if nargin<3 || isempty(n)
    n0=Inf;                         % default filter support is Inf
else
    n0=max(n,1);
end
if nargin<2 || isempty(f)
    f=1;
end
nn=n0;
if nargout>2 % we need to output the tail for next time
    if n0<Inf
        ny0=min(s1,nn-1);
    else
        ny0=min(s1,1);
    end
    sy0=s;
    sy0(1)=ny0;
    if ny0<=0 || n0==Inf
        y0=zeros(sy0);
    else
        y0=reshape(y(1+s1-ny0:end,:),sy0);
        y0=shiftdim(y0,ndims(x)-d+1);
    end
end
nn=min(nn,s1);         % no point in having nn>s1 
k=repmat((1:s1)',[1 s(2:end)]);
if nn>1
    j=1;
    j2=1;
    while j>0
        g=f^j;
        m=find(y(j+1:s1,:)<=g*y(1:s1-j,:));
        m=m+j*fix((m-1)/(s1-j));
        y(m+j)=g*y(m);
        k(m+j)=k(m);
        j2=j2+j;
        j=min(j2,nn-j2);                    % j approximately doubles each iteration
    end
end
if nargout==0
    if nargin<3
        x=shiftdim(x);
    else
        x=shiftdim(x,d-1);
    end
    ss=min(prod(s(2:end)),5);   % maximum of 5 plots
    plot(1:s1,reshape(y(nx0+1:end,1:ss),s1,ss),'-r',1:s1,reshape(x(:,1:ss),s1,ss),':b');
else
    if nargout>2 && n0==Inf && ny0==1 % if n0==Inf, we need to save the final output
        y0=reshape(y(end,:),sy0);
        y0=shiftdim(y0,ndims(x)-d+1);
    end
    if nx0>0                        % pre-data specified, x0
        s(1)=s(1)-nx0;
        y=shiftdim(reshape(y(nx0+1:end,:),s),ndims(x)-d+1);
        k=shiftdim(reshape(k(nx0+1:end,:),s),ndims(x)-d+1)-nx0;
    else                            % no pre-data
        y=shiftdim(y,ndims(x)-d+1);
        k=shiftdim(k,ndims(x)-d+1);
    end
end