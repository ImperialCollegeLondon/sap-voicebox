function v_axisenlarge(f,h)
%V_AXISENLARGE - enlarge the axes of a figure (f,h)
%
% Usage:  (1) v_axisenlarge(1.05)    % enlarge axes by 5% in each direction
%         (2) v_axisenlarge(-1.05)   % shrink to fit content before enlarging
%
% Inputs:
%    f      enlarge axis by a factor f relative to current size or
%           by -f relative to the graph content. For separate factors
%           in each direction use [fx fy fz] or [fleft fright fbottom ftop fdown fup] 
%    h      axis handle [default = gca]

%	   Copyright (C) Mike Brookes 2012
%      Version: $Id: v_axisenlarge.m 10865 2018-09-21 17:22:45Z dmb $
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
fpt=[1 1 1 1 1 1; 1 1 2 2 2 2; 1 1 2 2 3 3; 1 2 3 4 3 4; 1 2 3 4 5 5; 1 2 3 4 5 6];
if nargin<2 || ~numel(h)
    h=gca;
end
if nargin<1 || ~numel(f)
    f=-1.02;
end
nf=min(numel(f),6);
f=f(fpt(nf,:));  % expand f to dimension 4
if any(f>=0)
    ax0=[get(h,'XLim') get(h,'YLim') get(h,'ZLim')];
else
    ax0=zeros(1,6);
end
if any(f<0)
    axis(h,'tight');
    ax1=[get(h,'XLim') get(h,'YLim')  get(h,'ZLim')];
    ax0(f<0)=ax1(f<0);
    f=abs(f);
end
ax1=ax0.*f+ax0([2 1 4 3 6 5]).*(1-f);
set(h,'XLim',ax1(1:2),'YLim',ax1(3:4),'ZLim',ax1(5:6));
