function z=v_modsym(x,y,r)
%V_MODSYM  symmetric modulus function [Z]=(X,Y,R)
%
%   Usage: v_modsym(x,-2*pi) converts an angle in radians into the range (-pi,+pi].
%
%  Inputs: x    Input data (scalar or matrix)
%          y    modulus (scalar or same size as x)
%          r    Reference data (scalar or same size as x) [default: 0]
%
% Outputs: z    Output data (same size as x): z=x+k*y where integer k is chosen so that |z-r| <= |y/2|
%
% v_modsym(x,y,r) adds an integer multiple of y onto x so that it lies in
% the range [r-y/2,r+y/2) if y is positive or (r-y/2,r+y/2] if y is negative.
%
%      Copyright (C) Mike Brookes 2024
%      Version: $Id:  $
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
if nargin<3
    v=0.5*y;
else
    v=0.5*y-r;
end 
z=mod(x+v,y)-v;