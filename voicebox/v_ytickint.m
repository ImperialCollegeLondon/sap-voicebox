function ytick=v_ytickint(ax)
%V_YTICKINT removes non-integer ticks from a plot YTICK=(AX)
%
% Usage:    plot(...);      % plot a graph
%		    v_ytickint;     % remove any non-integer tick marks
%
% Inputs:   ax      axis to remove ticks from [current plot axis]
%
% Outputs:	ytick   list of remaining tick positions

%	   Copyright (C) Mike Brookes 2024
%      Version: $Id: v_xtickint.m $
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
if nargin<1 || isempty(ax)
    ax=gca; % use current axes
end
ytick=get(ax,'ytick');
set(ax,'ytick',ytick(round(ytick)==ytick));