function xtick=v_xtickint(ax)
%V_XTICKINT removes non-integer ticks from a plot XTICK=(AX)
%
% Usage:    plot(...);      % plot a graph
%		    v_xtickint;     % remove any non-integer tick marks
%
% Inputs:   ax      axis to remove ticks from [current plot axis]
%
% Outputs:	xtick   list of remaining tick positions
%

%	   Copyright (C) Mike Brookes 2024
%      Version: $Id: v_xtickint.m $
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
if nargin<1 || isempty(ax)
    ax=gca; % use current axes
end
xtick=get(ax,'xtick');
set(ax,'xtick',xtick(round(xtick)==xtick));