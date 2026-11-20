function xy=v_clipline(ln,ax,lspec)
%V_CLIPLINE Clip an infinite line to a bounding rectangle and optionally plot it
%
% Usage: (1) v_clipline([1 -1 0; 0 1 -0.5]',[-1 1 -1 1]);       % plot lines y=x and y=0.5 in square bounded by x=+-1 and y=+-1
%        (2) xy=v_clipline([1 -1 0; 0 1 -0.5]',[-1 1 -1 1]);    % calculate the line segments without plotting
%            plot(xy(1:2:3,:),xy(2:2:4,:));                     % plot the line segments (equivalent to (1) above
%
%  Inputs:  ln(3,n)     Coefficients for n lines: ln(1,*)*x + ln(2,*)*y + ln(3,*) = 0
%           ax(1,4)     Axis limits: [xmin xmax ymin ymax] [default: limits of the current plot]
%           lspec       Line Specification for plotting [default: '-']
%
% Outputs:  xy(4,n)     For each line xy(:,*)=[x1 y1 x2 y2]' where (x1,y1) and (x2,y2) are the line-rectangle intersections (or NaN if no intersection exists)
%                       The clipped line segment will be plotted if nargin==3 or if nargout==0 
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
persistent ijx corn
if isempty(ijx)
    ix=[0 0; 1 4; 1 2; 2 4; 2 3; 0 0; 1 3; 3 4; 3 4; 1 3; 0 0; 2 3; 2 4; 1 2; 1 4; 0 0]; % edges that are intersected
    jx=[1 3 2 1 4 1; 1 4 3 2 4 2; 2 4 4 2 3 3; 2 3 1 1 3 4]; % interpolation indices for each edge
    ijx=zeros(16,12);
    for i=1:16
        if ix(i,1)
            ijx(i,:)=[jx(ix(i,1),:) jx(ix(i,2),:)];
        end
    end
    corn=[1 1 2 2; 3 4 4 3];
end
if nargin<2
    h=gca;
    ax=[get(h,'XLim') get(h,'YLim')]';      % get axis limits of current plot
else
    ax=ax(:);                               % force ax to be a column vector
end
n=size(ln,2);                               % number of lines
xch=[ax(corn); ones(1,4)];    % homogeneous corner coordinates: BL, TL, TR, BR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  We first calculate the signed distance of each corner for the clipping rectangle from the line. If all       %
%  distances have the same sign then the line doesn't intersect the rectangle. Otherwise, it intersects         %
%  those edges whose corners have distances with opposite signs. The point of intersection with an edge         %
%  is a weighted average of the corner locations where the weights of the inverse distances of the line         %
%  from the corners. We use a lookup table, ijx(16,12), to convert from the 16 possible corner-distance sign    %
%  possibilities to the indices into the corner coordinates, ax(1,4), and corner-line distances, d(4,n), that   %
%  are needed to calculate the two intersection points.                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
d=xch'*ln;                                  % scaled signed distance of corners from each line: (4,n)
dx=1+pow2(0:3)*(d>0);                       % index into ijx array: code in range 1 to 16 indicating which boundaries of the clipping rectangle are crossed (1,n)
xy=nan(4,n);                                % space for output boundary coordinates ([x1 x2 y1 y2],n)
kx=ijx(dx,:)';                              % list of indices needed for intersection calculation (12,n)
kvm=kx(1,:)>0;                              % mask is true for "valid" lines i.e. ones that intersect the clipping rectangle: (1,n)
if any(kvm)                                 % check if any lines are valid
    kv4r=repmat((find(kvm)-1)*4,4,1);       % each row is the indexing offset into d(4,n) for each valid line's column
    xy(:,kvm)=(ax(kx([1 2 7 8],kvm)).*d(kx([3 3 9 9],kvm)+kv4r)-ax(kx([4 5 10 11],kvm)).*d(kx([6 6 12 12],kvm)+kv4r))./(d(kx([3 3 9 9],kvm)+kv4r)-d(kx([6 6 12 12],kvm)+kv4r));
end
if ~nargout || nargin>2
    if nargin<3
        plot(xy(1:2:3,:),xy(2:2:4,:),'-');
    else
        plot(xy(1:2:3,:),xy(2:2:4,:),lspec);
    end
end

