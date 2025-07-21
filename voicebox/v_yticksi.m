function s=v_yticksi(ah)
%V_YTIXKSI labels the y-axis of a plot using SI multipliers S=(AH)
%
%  Inputs:  AH       axis handle [default: current axes]
%
% Outputs:  S        optional global SI multiplier (see usage below)
%
% Usage:   (1) plot(...);
%              v_yticksi;
%
%          (2) plot(...);
%              ylabel(['Frequency (' v_yticksi 'Hz)']);
%
% The first form will label the tick marks on the y-axis of the current plot
% using SI multipliers where appropriate. This is particularly useful for log
% plots which MATLAB does not label very well.
% The second form will, if possible, use a single SI multiplier for all the tick
% marks; this global multiplier can be incorporated into the axis label as shown.

%	   Copyright (C) Mike Brookes 2009
%      Version: $Id: v_yticksi.m 10865 2018-09-21 17:22:45Z dmb $
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
if ~nargin
    ah=gca;
end
if nargout
s=v_xyzticksi(2,ah);
else
    v_xyzticksi(2,ah);
end