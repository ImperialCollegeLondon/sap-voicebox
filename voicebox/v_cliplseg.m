function xy=v_cliplseg(lseg,ax,lspec)
%V_CLIPSEG Clip a line segment to a bounding rectangle and optionally plot it
%
% Usage: (1) ax=[-1 1 -1 1];                            % define clipping rectangle
%            v_cliplseg([-0.3 -0.4; 2 1]',ax,'-ko');    % plot portion of line within rectangle
%            axis(ax);                                  % display the full rectangle
%
%        (2) ax=[-1 1 -1 1];                            % define clipping rectangle
%            xy=v_cliplseg([-0.3 -0.4; 2 1]',ax);       % calculate endpoints of clipped segment without plotting
%            plot(xy(1,:),xy(2,:),'b--');               % plot as blue dashed line
%            axis(ax);                                  % display the full rectangle
%
%  Inputs:  lseg(2,2)   Coordinates of line segment ends [x1 x2; y1 y2]
%           ax(1,4)     Axis limits: [xmin xmax ymin ymax] (defaults to limits of the current plot)
%           lspec       Line Specification for plotting
%
% Outputs:  xy(2,2)     Coordinates of clipped line segment ends [x1 x2; y1 y2] (or NaN if entirely outside rectangle)
%                       The clipped line segment will be plotted if nargin==3 or if nargout==0 
%

%      Copyright (C) Mike Brookes 2026
%      Version Date: 2026-11-20
%
%   VOICEBOX is a MATLAB toolbox for speech processing.
%   Home page: https://imperialcollegelondon.github.io/sap-voicebox/index.html
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
persistent lax0
if isempty(lax0)
    lax0=[ 1 0 -1; -1 0 1; 0 1 -1; 0 -1 1];
end
if nargin<2
    h=gca;
    ax=[get(h,'XLim') get(h,'YLim')]';      % get axis limits of current plot
end
lax=lax0;                       % matrix of bounding lines for ax=[-1 1 -1 1]
lax(:,3)=lax(:,3).*ax(:);       % bounding rectangle edges: left right bottom top. lax*[x; y; 1] is +ve for all lines if (x,y) is inside box
lsegh=ones(3,2);                % initialize homogeneous version of line segment ends
lsegh(1:2,:)=lseg;              % and insert x-y coordinates
dl=lax*lsegh;                   % distances of endpoints from bounding lines (4,2)
dlq=dl<0;                       % dlq=0 if on the good side
dx=dl(:,1)./(dl(:,1)-dl(:,2));  % crossing point as a fraction of x1 -> x2
f12=max([dx 1-dx].*dlq);
if ~any(prod(dlq,2)) && sum(f12)<1 % check that we can get the right side of all the bounding lines
    xy=lseg*[1-f12(1) f12(2); f12(1) 1-f12(2)];
else
    xy=nan(2,2);
end
if ~nargout || nargin>2
    if nargin<3
        lspec='-k';
    end
    plot(xy(1:2:3),xy(2:2:4),lspec)
end

