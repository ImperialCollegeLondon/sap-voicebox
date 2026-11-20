function [xy,ty,dxy]=v_conicline(s,l,th)
%V_CONICLINE Determine the intersection points of a line and a conic 
%
%   Usage: xy=v_conicline([1 0 0 0 -1 0],[0 1 -2]'); % find both intersections of y=x^2 with the line y=2
%
%  Inputs:  s           Conic specified as either a 3x3 matrix with [x y 1]*s*[x y 1]'=0, or polynomial coefficients with s*[x^2 x*y y^2 x y 1]'=0
%           l(3,nl)     nl lines of form l(1)*x + l(2)*y + l(3)=0
%           th          threshold for classifying line as a tangent or point at infinity [default: 1e-6]
%
% Outputs:  xy(2,2,nl)  x and y coordinates of up to 2 intersection points per line (NaN for missing points)
%           ty(2,nl)    Intersection type: 0=none, 1=tangent or 2=crossing
%           dxy(2,2,nl) dx and dy for a unit-magnitude tangent to conic at each intersection point. The sign
%                       of [dx; dy] is chosen so that the tangent vectror point to the "positive" side of the
%                       corresponding line (see (c) below).
%
% If s is in 3x3 matrix form, then xy(:,i,j) satisfies the following three equations for all i={1,2} and 1<=j<=nl (except for NaN entries):
%
%           (a) [xy(:,i,j); 1]'*s*[xy(:,i,j); 1] = 0        % xy(:,i,j) lies on the conic: 
%           (b) l(:,j)'*[xy(:,i,j); 1 1] = 0                % xy(:,i,j) lies on line j: 
%           (c) l(:,j)'*[xy(:,i,j)+dxy(:,:,1); 1 1] >= 0    % dxy(:,i,j) points to the "positive" side of line j: 
%

%      Copyright (C) Mike Brookes 2026
%      Version Date: 2026-11-20
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
persistent k1x3 k2x3 k3x2 k245 kp2m kdxy
if isempty(k1x3)                             % define useful constants
    k1x3=ones(1,3);
    k2x3=2*k1x3;
    k3x2=[3 3];
    kdxy=[0 -1 0; 1 0 0];
    k245=[2 4 5];
    kp2m=[1 2 4; 2 3 5; 4 5 6];
end
if nargin<3
    th=1e-6;
end
if numel(s)<9
    s(k245)=0.5*s(k245);                    % halve the off-diagonal coefficients
    s=s(kp2m);                              % convert to symmetric matrix
end
nl=size(l,2);                               % number of lines
nl2=2*nl;                                   % twice number of lines (often needed below)
xyh=nan(3,2,nl);                            % space for homogeneous intersection points (up to 2 per line)
ty=zeros(2,nl);                             % space for intersection types
dxy=nan(2,2,nl);
m=reshape([-l(2,:); l(1,:); zeros(1,nl); -l(1:2,:).*l([3 3],:); sum(l(1:2,:).^2,1)],3,2,nl);    % (3,2,nl) M matrix
gg=reshape(sum(repmat((s*m(:,:)),1,2).*[m(:,:) reshape(m(:,2:-1:1,:),3,2*nl)],1),2,nl,2);       % (2,nl,2) [G([1 4],:) G([2 3],:)]
t=gg(1,:,2).^2;                             % G(2,1)^2
d=gg(1,:,1).*gg(2,:,1)-t;                   % (1,nl): det(G)
t=abs(d+2*t)*th;                            % threshold for testing det(g)=0
sd=(d>t)-(d<-t);                            % = {-1,0,1} according to sign
q=sd==0;                                    % mask for tangent lines for which sd==0
if any(q)
    xyh(:,1,q)=gg(k1x3,q,1).*m(:,2,q)-gg(k1x3,q,2).*m(:,1,q);     % tangent points
    ty(1,q)=1;                              % indicate as tangents
end
q=sd==-1;                                   % mask for lines crossing conic twice
if any(q)                                   % we want to solve gg(1,*,1)*t^2 + 2*gg(1,*,2)*t + gg(2,*,1) = 0 but do it carefully in case some of the coefficients are zero
    f=gg(1,q,2)+(2*(gg(1,q,2)>0)-1).*sqrt(-d(q));
    xyh(:,1,q)=gg(k1x3,q,1).*reshape(m(:,2,q),3,[])-repmat(f,3,1).*reshape(m(:,1,q),3,[]);
    xyh(:,2,q)=gg(k2x3,q,1).*reshape(m(:,1,q),3,[])-repmat(f,3,1).*reshape(m(:,2,q),3,[]);
    ty(:,q)=2;                              % indicate as crossings
end
xyh(:,abs(xyh(3,:))<=th*max(abs(xyh(1,:)),abs(xyh(2,:))))=NaN;          % zap points at infinity
xy=xyh(1:2,:,:)./xyh(k3x2,:,:);            % convert homogeneous coordinates to real ones
if nargout>2
    dxy(:)=kdxy*s*xyh(:,:);
    ll=reshape(repmat(l(1:2,:),2,1),2,2,nl);
    dxy=dxy.*repmat((1-2*(sum(dxy.*ll)<0))./sqrt(sum(dxy.^2)),2,1,1); % normalize tangent vector and negate if necessary
end

