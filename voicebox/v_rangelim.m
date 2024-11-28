function y=v_rangelim(x,r,m)
%V_RANGELIM  limit the range of matrix elements: Y=(X,R,M)
%
%  Usage: (1) y=v_rangelim(x,[a b]);        % limit x to the range [a,b]
%         (2) y=v_rangelim(x,[a b],'n');    % set values outside range to NaN
%         (3) y=v_rangelim(x,r);            % limit x to the range max(x(:))+[-r,0]
%         (4) y=v_rangelim(x,r,'r');        % limit x to the range max(x(:)).*[1/r,1]
%
%  Inputs: x    Input data (scalar or matrix)
%          r    desired range as [min max], max-min, max/min or 20*log10(max/min) (see options below)
%          m    mode string containing any reasonable combination of:
%
%                   'd' range r gives range in dB: 20*log10(max(y)/min(y))
%                   'r' range r gives max(y)/min(y) ratio
%                   'l' range r gives max(y)-min(y) difference [default]
%
%                   'p' max(x) is top of range [default]
%                   't' min(x) is bottom of range
%                   'g' geometric mean is centre of range
%                   'u' mean is centre of range
%                   'm' median is centre of range
%
%                   'c' clip out of range values to limit [default]
%                   'n' set out of range values to NaN
%
% Outputs: y    Output data (same size as x)
%
%
%      Copyright (C) Mike Brookes 2024
%      Version: $Id:  $
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
if nargin<3 || ~length(m)
    m='lp';
end
nm=length(m);

id=find([any(repmat(m',1,4)==repmat('gumt',nm,1),1) 1].*(1:5),1);
if length(r)>1                          % r specifies explicit limits
    p=r(1);
    q=r(2); 
else                                    % r specifies max/min or max-min
    ir=find([any(repmat(m',1,2)==repmat('dr',nm,1),1) 1].*(1:3),1);
if ir==1                                % ratio in dB
    r=10^(0.05*r);                      % convert to actual ratio
end
if ir==3                                % 'l' denotes a linear range specification
    switch id                           % switch according to reference value
        case 5                          % 'p': peak of x(:)
            q=max(x(:));                % ... upper limit
            p=q-r;                      % ... lower limit
        case 4                          % 't': trough of x(:)
            p=min(x(:));                % ... lower limit
            q=p+r;                      % ... upper limit
        case 3                          % 'm': median of x(:)
            p=median(x(:))-0.5*r;       % ... lower limit
            q=p+r;                      % ... upper limit
        case 2                          % 'u': mean of x(:)
            p=mean(x(:))-0.5*r;         % ... lower limit
            q=p+r;                      % ... upper limit
        case 1                          % 'g': geometric mean of x(:)
            p=exp(mean(log(x(:))))-0.5*r; % ... lower limit
            q=p+r;                      % ... upper limit
    end
else                                    % 'r' or 'd' denotes a ratio range specification
    switch id                           % switch according to reference value
        case 5                          % 'p': peak of x(:)
            q=max(x(:));                % ... upper limit
            p=q/r;                      % ... lower limit
        case 4                          % 't': trough of x(:)
            p=min(x(:));                % ... lower limit
            q=p*r;                      % ... upper limit
        case 3                          % 'm': median of x(:)
            p=median(x(:))/sqrt(r);     % ... lower limit
            q=p*r;                      % ... upper limit
        case 2                          % 'u': mean of x(:)
            p=mean(x(:))/sqrt(r);       % ... lower limit
            q=p*r;                      % ... upper limit
        case 1                          % 'g': geometric mean of x(:)
            p=exp(mean(log(x(:))))/sqrt(r); % ... lower limit
            q=p*r;                      % ... upper limit
    end
end
end
y=x;                                    % initialize y output
if any(m=='n')
    y(x<p | x>q)=NaN;                   % set out-of-range elements to NaN
else
    y(x<p)=p;                           % clip low out-of-range elements
    y(x>q)=q;                           % clip high out-of-range elements
end