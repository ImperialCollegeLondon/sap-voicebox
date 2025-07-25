function d=v_distchpf(pf1,pf2,mode)
%V_DISTCHPF calculates the cosh spectral distance between power spectra D=(PF1,PF2,MODE)
%
% Inputs: PF1,PF2     Power spectra to be compared. Each row represents a power spectrum: the first
%                     and last columns represent the DC and Nyquist terms respectively.
%                     PF1 and PF2 must have the same number of columns.
%
%         MODE        Character string selecting the following options:
%                         'x'  Calculate the full distance matrix from every row of PF1 to every row of PF2
%                         'd'  Calculate only the distance between corresponding rows of PF1 and PF2
%                              The default is 'd' if PF1 and PF2 have the same number of rows otherwise 'x'.
%           
% Output: D           If MODE='d' then D is a column vector with the same number of rows as the shorter of PF1 and PF2.
%                     If MODE='x' then D is a matrix with the same number of rows as PF1 and the same number of columns as PF2'.
%
% The COSH spectral distance is the average over +ve and -ve frequency of 
%
%                     cosh(log(p1/p2))-1   =   (p1-p2)^2/(2p1*p2)   =   (p1/p2 + p2/p1)/2 - 1
%
% The COSH distance is a symmetrical version of the Itakura-Saito distance: v_distchpf(x,y)=(v_distispf(x,y)+v_distispf(y,x))/2

% The Cosh distance can also be calculated directly from AR coefficients; providing np is large
% enough, the values of d0 and d1 in the following will be very similar:
%
%         np=255; d0=v_distchar(ar1,ar2); d1=v_distchpf(v_lpcar2pf(ar1,np),v_lpcar2pf(ar2,np))
%

% Ref: A.H.Gray Jr and J.D.Markel, "Distance measures for speech processing", IEEE ASSP-24(5): 380-391, Oct 1976
%      L. Rabiner abd B-H Juang, "Fundamentals of Speech Recognition", Section 4.5, Prentice-Hall 1993, ISBN 0-13-015157-2

%      Copyright (C) Mike Brookes 1997
%      Version: $Id: v_distchpf.m 10865 2018-09-21 17:22:45Z dmb $
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

[nf1,p2]=size(pf1);
p1=p2-1;
nf2=size(pf2,1);
if nargin<3 | isempty(mode) mode='0'; end
if any(mode=='d') | (mode~='x' & nf1==nf2)
   nx=min(nf1,nf2);
   r=pf1(1:nx,:)./pf2(1:nx,:);
   q=r+r.^(-1);
   d=(2*sum(q(:,2:p1),2)+q(:,1)+q(:,p2))/(4*p1)-1;
else
   r=permute(pf1(:,:,ones(1,nf2)),[1 3 2])./permute(pf2(:,:,ones(1,nf1)),[3 1 2]);
   q=r+r.^(-1);
   d=(2*sum(q(:,:,2:p1),3)+q(:,:,1)+q(:,:,p2))/(4*p1)-1;
end
