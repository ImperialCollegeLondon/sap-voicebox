function [no,ni,nc]=v_rootstab(p)
%V_ROOTSTAB determines the  number of polynomial roots outside, inside and on the unit circle [NO,NI,NC]=v_rootstab(P)
%
%  Inputs:  p   Polynomial with real or complex coefficients
%
% Outputs: no   Number of roots outside the unit circle
%          ni   Number of roots inside the unit circle
%          nc   Number of roots lying on the unit circle
%
% This routine uses the algorithm given in [1]. Rounding errors may cause roots that lie on the unit circle to migrate to either inside or outside.
%
% Refs:
%   [1] Messaoud Benidir. On the root distribution of general polynomials with respect to the unit circle.
%       Signal Processing, 53 (1): 75–82, August 1996. ISSN 0165-1684. doi: 10.1016/0165-1684(96)00077-1.
%       [ Note error in equation (52) which should read k^ = +k - Q(0)/(conj(c0)*(1/c - c)) ]

%      Copyright (C) Mike Brookes 2025
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

no=0;                                       % initialize count of roots outside unit circle
nc=0;                                       % initialize count of roots on the unit circle
if all(p==0)                                % p is all zero
    ni=0;
else
    p=p(:).';                               % force to be a row vector
    p=p(find(p~=0,1):end);                  % trim leading zeros
    np=length(p);                           % initial 1+order(p)
    np0=np;                                 % save initial order for calculating ni later
    npd=0;                                  % initialize saved order for calculating nc
    while length(p)>1
        p=p/sqrt(p*p');                     % normalize p each loop
        pf=conj(p(np:-1:1));                % flipped version of p
        k=-p(np)/pf(np);
        q=p+k*pf;                           % null out the constant coefficient
        q(np)=0;                            % force exact zero in case of rounding errors
        if all(q==0)
            p=p(1:end-1).*(np-1:-1:1);      % take derivative
            if npd==0
                npd=np;                     % save current 1+order(p)
                nod=no;                     % save current count of roots outside unit circle
            end
        elseif q(1)==0                      % if |k|=1 and q~=0
            q=q(1:find(q~=0,1,'last'));     % trim trailing zeros from q
            dr=-q(end)/(pf(end)*k);         % direction we will move normalized k in
            if abs(real(dr))>abs(imag(dr)) 
                cf=abs(real(dr));           % increase or decrease real part by 0.5
            else
                cf=0.25*abs(imag(dr));      % increase or decrease imag part by 2
            end
            c=sqrt(1+cf^2)-cf;             % choose c in range (0,1)
            p=p/c+k*c*pf+[zeros(1,np-length(q)) q];
        elseif abs(k)>1
            q=q(1:find(q~=0,1,'last'));     % trim trailing zeros from q
            p=conj(q(end:-1:1));            % flip q
            no=no+np-length(p);             % increement count of zeros outside unit circle
        else
            p=q(1:find(q~=0,1,'last'));     % trim trailing zeros from q and take as p
        end
        np=length(p);                       % 1+order(p)
    end
    if npd>0
        nc=npd-1-2*(no-nod);
    end
    ni=np0-1-nc-no;
end