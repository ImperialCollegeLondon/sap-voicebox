function [l,u]=v_rotro2lu(r)
%V_ROTRO2QR converts a 3x3 rotation matrix to look and up directions
%  Inputs:  R(3,3,...)  Input rotation matrix
%
% Outputs:  L(3,...)    Unit vector specifying look direction
%           U(3,...)    Unit vector specifying up direction
%
% The rotation maps the look direction to the negative z-axis and the up direction
% to lie in the y-z plane with a positive y component. That is, R*L=a*[0 0 -1]' and
% R*U=b*[0 1 c] for postive constants a and b. After applying this rotation to an object,
% the 2-D data obtained by omitting the z-component represents an orthographic projection
% performed by a camera looking in the direction L.

%      Copyright (C) Mike Brookes 2023
%      Version: $Id: v_rotro2lu.m 10865 2018-09-21 17:22:45Z dmb $
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

sz=size(r);
r=reshape(r,9,[]);                  % make 2-dimensional
if size(r,2)>1                      % multiple rotation matrices
    l=reshape(-r([3 6 9],:),[3 sz(3:end)]);
    u=reshape(r([2 5 8],:),[3 sz(3:end)]);
else                                % only one rotation matrix
    l=-r([3 6 9],:);
    u=r([2 5 8],:);
end
if ~nargout
    v_rotro2qr(reshape(r(:,1),3,3));           % plot a cube
    set(gca,'CameraPosition',[0 0 1]);
end
