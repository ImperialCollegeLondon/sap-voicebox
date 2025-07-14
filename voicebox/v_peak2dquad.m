function [v,xy,t,m]=v_peak2dquad(z)
%V_PEAK2DQUAD find quadratically-interpolated peak in a 2D array
%
% Note: This routine has been superceeded by v_quadpeak
%
%  Inputs:  Z(m,n)   is the input array
%
% Outputs:  V        is the peak value
%           XY(2,1)  is the position of the peak (in fractional subscript values)
%           T        is -1, 0, +1 for maximum, saddle point or minimum
%           M        defines the fitted quadratic: z = [x y 1]*M*[x y 1]'

%	   Copyright (C) Mike Brookes 2008
%      Version: $Id: v_peak2dquad.m 10865 2018-09-21 17:22:45Z dmb $
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
%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[v,xy,t,m]=v_quadpeak(z);