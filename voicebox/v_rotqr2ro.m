function r=v_rotqr2ro(q)
%ROTQR2RO converts a real quaternion to a 3x3 rotation matrix
% Inputs:
%
%     Q(4,...)      Real-valued quaternion array (possibly unnormalized)
%
% Outputs:
%
%     R(3,3,...)    Rotation matrix array
%                   Plots a diagram if no output specified
%
% In the quaternion representation of a rotation, and q(1) = cos(t/2)
% where t is the angle of rotation in the range 0 to 2pi
% and q(2:4)/sin(t/2) is a unit vector lying along the axis of rotation
% a positive rotation about [0 0 1] takes the X axis towards the Y axis.
%
%      Copyright (C) Mike Brookes 2007-2018
%      Version: $Id: v_rotqr2ro.m 10865 2018-09-21 17:22:45Z dmb $
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

persistent a b c d e f g h m
if isempty(a)
    a=[1 5 9];
    b=[11 16 6];
    c=[16 6 11];
    d=[4 8 3];
    e=[10 15 14];
    f=[4 2 3];
    g=[2 6 7];
    h=[1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4]';
    m=[1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4]';
end
sz=size(q);
q=reshape(q,4,[]);      % convert to 2D matrix
nq =size(q,2);          % number of quaternions to convert
p=2*q(h,:).*q(m,:)./repmat(sum(q.^2,1),16,1); % force normalized and calculate quadratic terms       
r=zeros(9,nq);          % space for nq rotation matrices
r(a,:)=1-p(b,:)-p(c,:);
r(d,:)=p(e,:)-p(f,:);
r(g,:)=p(e,:)+p(f,:);
r=reshape(r,[3 3 sz(2:end)]);
if ~nargout
    % display rotated cube
    q1=q(:,1);
    q1=q1/sqrt(q1'*q1); % normalize the first quaternion
    clf('reset'); % clear current axis
    v0=[-1 1 1 -1 -1 1 1 -1; -1 -1 1 1 -1 -1 1 1; -1 -1 -1 -1 1 1 1 1]*0.5; % unrotated coordinates
    v=r(:,:,1)*v0; % use first elemnt of r to rotate
    fv=[4 1 5 8; 2 3 7 6; 1 2 6 5; 3 4 8 7; 2 1 4 3; 5 6 7 8]; % verices for each face
    fc=[0 1 1; 1 0 0; 1 0 1; 0 1 0; 1 1 0; 0 0 1]; % colours for faces
    xc={[25 46 46 25; 55 55 49 49]/100,
        [25 33 33 39 39 46 46 39 39 33 33 25; 55 55 63 63 55 55 49 49 42 42 49 49]/100,
        [48 56 62 69 76 66 76 69 62 56 48 59; 68 68 58 68 68 53 37 37 47 37 37 53]/100,
        [48 55 62 69 77 65 65 59 59; 68 68 55 68 68 50 37 37 50]/100,
        [50 74 74 57 74 74 50 50 67 50; 68 68 62 43 43 37 37 43 62 62]/100};
    xf=[1 3; 2 3; 1 4; 2 4; 1 5; 2 5]; % characters to plot on each face
    nf=size(fv,1); % number of faces
    for i=1:6
        p(i)=patch(v(1,fv(i,:)),v(2,fv(i,:)),v(3,fv(i,:)),fc(i,:));
        set(p(i),'FaceAlpha',0.65);
        k=1.001; % factor to move out labels slightly to get correct depth ordering
        for j=1:2
            xij=xc{xf(i,j)}; % relative coordinates of character vertices
            patch(k*(v(1,fv(i,1))+(v(1,fv(i,2))-v(1,fv(i,1)))*xij(1,:)+(v(1,fv(i,4))-v(1,fv(i,1)))*xij(2,:)), ...
                k*(v(2,fv(i,1))+(v(2,fv(i,2))-v(2,fv(i,1)))*xij(1,:)+(v(2,fv(i,4))-v(2,fv(i,1)))*xij(2,:)), ...
                k*(v(3,fv(i,1))+(v(3,fv(i,2))-v(3,fv(i,1)))*xij(1,:)+(v(3,fv(i,4))-v(3,fv(i,1)))*xij(2,:)),1-fc(i,:));
        end
    end
    qa=q1(2:4);
    qm=max(abs(qa));
    if qm>1e-6*abs(q1(1))
        qa=qa/(qm/0.7); % scale so axis extends outside the cube
        hold on;
        plot3([1 -1]*qa(1),[1 -1]*qa(2),[1 -1]*qa(3),'-');
        hold off
    end
    th=360/pi*acos(abs(q1(1)));
    xlabel('x axis');
    ylabel('y axis');
    zlabel('z axis');
    q=q(:,1)*((2*(q(find(q1(:)~=0,1))>0)-1)); % force leading coefficient to be positive
    title(sprintf('%d^\\circ, qr'' = [%.2f,%.2f,%.2f,%.2f], eu_{xyzo}'' = [%d, %d, %d]^\\circ',round(th),q1(:),round(v_rotqr2eu('xyz',q1)*180/pi)));
    axis([-1 1 -1 1 -1 1 0 1]*sqrt(3)/2);
    axis equal
    grid on
    view(3);
end

