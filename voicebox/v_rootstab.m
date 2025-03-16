function [no,ni,nc]=v_rootstab(p)
%V_ROOTSTAB calculates the  number of polynomial roots outside, inside and on the unit circle [NO,NI,NC]=v_rootstab(P)
%
%  Inputs:  p   Polynomial with real or complex coefficients
%
% Outputs: no   Number of roots outside the unit circle
%          ni   Number of roots inside the unit circle
%          nc   Number of roots on the unit circle
%
% This routine uses the algorithm given in [1]. Note that rounding errors may cause roots that lie on the unit circle to migrate to either inside or outside.
%
% Refs:
%   [1] Messaoud Benidir. On the root distribution of general polynomials with respect to the unit circle.
%       Signal Processing, 53 (1): 75–82, August 1996. ISSN 0165-1684. doi: 10.1016/0165-1684(96)00077-1.
%
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
            p=q(1:find(q~=0,1,'last'));     % trim trailing zeros from q
        end
        np=length(p);                       % 1+order(p)
    end
    if npd>0
        nc=npd-1-2*(no-nod);
    end
    ni=np0-1-nc-no;
end