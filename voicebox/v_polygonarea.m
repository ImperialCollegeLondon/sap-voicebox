function a=v_polygonarea(p)
%V_POLYGONAREA Calculate the area of a polygon
%
% Inputs:
%    P(n,2) is the polygon vertices
%
% Outputs:
%    A is teh area of teh polygon
%
% The area is positive if the vertices go anti-clockwise around the polygon.
%

%      Copyright (C) Mike Brookes 2009
%      Version: $Id: v_polygonarea.m 10865 2018-09-21 17:22:45Z dmb $
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
p(end+1,:)=p(1,:);      % append an extra point
a=0.5*sum((p(1:end-1,1)-p(2:end,1)).*(p(1:end-1,2)+p(2:end,2)),1);
if ~nargout
    plot(p(:,1),p(:,2),'b-');
    mnx=[1.05 -0.05;-0.05 1.05]*[min(p);max(p)];
    set(gca,'xlim',mnx(:,1)','ylim',mnx(:,2)');
    title(sprintf('Area = %.2g',a));
end
