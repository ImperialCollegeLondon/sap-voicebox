function xy=v_clippoint(xyin,ax,pspec)
% Plot points that lie within a bounding rectangle
%
%   Usage: ax=[-1 1 -1 1];                                      % define the boundaries of the clipping rectangle
%          v_clippoint([-2 0; 0.3 0.4; 0.5 3; -0.2 0.6]',ax);   % plot the points that lie within the rectangle
%          axis(ax);                                            % display the full rectangle
%
%  Inputs:  xyin(2,n)   x-y coordinates for n points
%           ax(1,4)     Axis limits: [xmin xmax ymin ymax] [default: limits of the current plot]
%           pspec       Specification for plotting points [default: 'xk']
%
% Outputs:  xy(2,n)     x-y coordinates for n points (or NaN if outside rectangle)
%                       Points will be plotted if nargin==3 or if nargout==0
%

%      Copyright (C) Mike Brookes 2026
%      Version Date: 2026-11-18
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
n=size(xyin,2);                 % number of points
xyh=ones(3,n);                  % initialize homogeneous version of input points
xyh(1:2,:)=xyin;                % copy input point x-y coordinates
sel=all(lax*xyh>=0,1);          % mask indicating points within the rectangle
xy=nan(2,n);                    % initialise output coordinates to NaN
xy(:,sel)=xyin(:,sel);          % copy coordinates of valid poionts
if ~nargout || nargin>2
    if nargin<3
        pspec='xk';
    end
    plot(xy(1,:),xy(2,:),pspec);
end
