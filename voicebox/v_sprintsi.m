function s=v_sprintsi(x,d,w,u)
%V_SPRINTSI Print X with SI multiplier S=(X,D,W,U)
%
%  Usage: (1) v_sprintsi(2345,-2) -> '2.3 k'
%         (2) v_sprintsi(2345,-2,8,' ') -> '   2.3 k'
%         (3) v_sprintsi(2345,-2,[],'Hz') -> '2.3kHz'
%
%  Inputs:  X        the value to print
%           D        number of decimal places (+ve) or significant digits (-ve) [-3]
%           W        add leading spaces so that |W| is minimum total width including multiplier [0]
%                    If W<=0 then trailing 0's will be eliminated.
%           U        string giving the unit (if present, an initial space will be placed before the multiplier) [' ']
%
% Outputs:  S        output string

%      Copyright (C) Mike Brookes 1998-2022
%      Version: $Id: v_sprintsi.m 10865 2018-09-21 17:22:45Z dmb $
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
persistent f f0 emin emax
if isempty(f)
    f='qryzafpnum kMGTPEZYRQ';      % list of SI multipliers
    f0=find(f==' ');            % position of space in list of SI multipliers
    emin=3-3*f0;                % lowest power of 10 in f
    emax=3*(length(f)-f0);      % highest power of 10 in f
end
if nargin<4                     % if no unit string specified
    u=' ';                      % default unit string is a space
end
if nargin<3 || isempty(w)       % if no width is specified
    w=0;                        % default is 0, i.e. eliminate trailing zeros
end
if nargin<2 || isempty(d)
    d=-3;                       % default precision is 3 significant figures
end
% need to check what happens if x=0 to avoid "y" prefix
if x==0
    e=0;
else
    e=floor(log10(abs(x)));     % highest power of 10 <= abs(x)
end
k=floor(max(emin,min(emax,e))/3);               % SI multilier to use is f(k+f0)
dp=max([0 d 3*k-d-e-1]);                        % number of decimal places to use
if w<=0 & dp
    w=abs(w);
    dp=max(find([1 mod(mod(round(x*10^(dp-3*k)),10^dp),10.^(dp:-1:1))]))-1;
end
if length(u)>0 && u(1)==' '                     % unit string starts with a space
    if(k)                                       % mutliplier needed
        s=sprintf(sprintf('%%%d.%df %c%s',max(w-2,0),dp,f(k+f0),u(2:end)),x*1e-3^k);
    else                                        % no mutliplier needed
        s=sprintf(sprintf('%%%d.%df %s',max(w-1,0),dp,u(2:end)),x*1e-3^k);
    end
else                                            % no space before unit string
    if(k)                                       % mutliplier needed
        s=sprintf(sprintf('%%%d.%df%c%s',max(w-2,0),dp,f(k+f0),u),x*1e-3^k);
    else                                        % no mutliplier needed
        s=sprintf(sprintf('%%%d.%df%s',max(w-1,0),dp,u),x*1e-3^k);
    end
end
