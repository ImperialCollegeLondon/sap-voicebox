function [y,zf]=v_ditherq(x,m,zi)
%V_DITHERQ  add dither and quantize [Y,ZF]=(X,M,ZI)
%  Inputs:
%      x   is the input signal
%	   m   specifies the mode:
%          'w'  white dither (default)
%          'h'  high-pass dither (filtered by 1 - z^-1)
%          'l'  low pass filter  (filtered by 1 + z^-1)
%          'n'  no dither

%      Copyright (C) Mike Brookes 1997
%      Version: $Id: v_ditherq.m 10865 2018-09-21 17:22:45Z dmb $
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
n=length(x);
if nargin<3 | ~length(zi)
    zi=rand(1);
end
    if nargin<2
        m='w';
    end
if any(m=='n')
    y=round(x);
elseif any(m=='h') | any(m=='l')
    v=rand(n+1,1);
    v(1)=zi;
    zf=v(end);
    if any(m=='h')
        y=round(x(:)+v(2:end)-v(1:end-1));
    else
        y=round(x(:)+v(2:end)+v(1:end-1)-1);
    end
else
    y=round(x(:)+rand(n,2)*[1;-1]);
    zf=rand(1);                         % output a random number anyway
end
if s(1)==1
    y=y.';
end