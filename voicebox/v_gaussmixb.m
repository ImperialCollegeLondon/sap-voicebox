function [d,dbfg]=v_gaussmixb(mf,vf,wf,mg,vg,wg,nx)
%V_GAUSSMIXB approximate Bhattacharyya divergence between two GMMs
%
% Usage: (1) d=v_gaussmixb(mf,vf,wf,mg,vg,wg);        % Estimate Bhattacharyya divergence between {mf,vf,wf} and {mg,vg,wg}
%                                                     % vf and vg can independently be full or diagonal covariances
%
%        (2) [d,dbfg]=v_gaussmixb(mf,vf,wf,mg,vg,wg); % Also calculate exact Bhattacharyya divergence between compnents of f and components of g
%
%        (3) d=v_gaussmixb(mf,vf,wf,mg,vg,wg,0);      % Calculate upper bound to Bhattacharyya divergence
%
%        (4) [d,dbfg]=v_gaussmixb(mf,vf,wf);          % Calculate Bhattacharyya divergence between compnents of f. d=0 always in this case.
%
%        (5) v_gaussmixb(mf,vf,wf,mg,vg,wg);          % Plot graphs of distributions (dimension p must equal 1)
%
% Inputs: with kf & kg mixtures, p data dimensions
%
%   mf(kf,p)                mixture means for GMM f
%   vf(kf,p) or vf(p,p,kf)  variances (diagonal or full) for GMM f [default: identity]
%   wf(kf,1)                weights for GMM f - must sum to 1 [default: uniform]
%   mg(kg,p)                mixture means for GMM g [g=f if mg,vg,wg omitted]
%   vg(kg,p) or vg(p,p,kg)  variances (diagonal or full) for GMM g [default: identity]
%   wg(kg,1)                weights for GMM g - must sum to 1 [default: uniform]
%   nx                      number of samples to use in importance sampling [default: 1000]
%                           Set nx=0 to save computation by returning only an upper bound to the Bhattacharyya divergence.
%
% Outputs:
%   d             the approximate Bhattacharyya divergence D_B(f,g)=-log(Int(sqrt(f(x)g(x)) dx)).
%                 if nx=0 this will be an upper bound (typically 0.3 to 0.7 too high) rather than an estimate.
%   dbfg(kf,kg)   the exact Bhattacharyya divergence between the unweighted components of f and g
%
% The Bhattacharyya divergence, D_B(f,g), between two distributions, f(x) and g(x), is -log(Int(sqrt(f(x)g(x)) dx)).
% It is a special case of the Chernoff Bound [2]. The Bhattacharyya divergence [1] satisfies:
%     (1) D_B(f,g) >= 0
%     (2) D_B(f,g) = 0 iff f = g
%     (3) D_B(f,g) = D_B(g,f)
% It is not a distance because it  does not satisfy the triangle inequality. It upper bounds the Bayes
% divergence -log(Int(min(f(x),g(x)) dx) which relates to the probability of 2-class misclassification [1].
%
% This routine calculates the "variational importance sampling" estimate of (or if nx=0,
% the "variational II" upper bound to) the Bhattacharyya divergence from [3]. It is exact
% when f and g are single component gaussians and is zero if f=g.
%
% Refs:
% [1] T. Kailath. The divergence and Bhattacharyya distance measures in signal selection.
%     IEEE Trans Communication Technology, 15 (1): 52–60, Feb. 1967.
% [2] H. Chernoff. A measure of asymptotic efficiency for tests of a hypothesis based on the
%     sum of observations. The Annals of Mathematical Statistics, 23 (4): 493–507, Dec. 1952.
% [3] P. A. Olsen and J. R. Hershey. Bhattacharyya error and divergence using variational
%     importance sampling. In Proc. Interspeech Conf., pages 46–49, 2007.
%
%	   Copyright (C) Mike Brookes 2024
%      Version: $Id: v_gaussmixk.m 10865 2018-09-21 17:22:45Z dmb $
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
maxiter=15;                                                     % maximum iterations for upper bound calculation
pruneth=0.2;                                                    % prune threshold for importance sampling (prob that any excluded mixture would have been chosen)
[kf,p]=size(mf);
if nargin<2 || isempty(vf)                                      % if vf inoput is missing
    vf=ones(kf,p);                                              % ... default to diagonal covariances
end
if nargin<3 || isempty(wf)                                      % if wf inoput is missing
    wf=repmat(1/kf,kf,1);                                       % ... default to uniform weights
end
if p==1                                                         % if data dimension is 1
    vf=vf(:);                                                   % ... then variances are always diagonal
    dvf=true;
else
    dvf=ismatrix(vf) && size(vf,1)==kf;                         % diagonal covariance matrix vf is supplied
end
if nargin<7
    nx=1000;                                                    % default count for importance sampling
end
hpl2=0.5*p*log(2);
if nargin<5                                                     % only f GMM specified: use this for g GMM as well
    dbfg=zeros(kf,kf);                                          % space for pairwise divergences
    if kf>1
        nup=kf*(kf-1)/2;                                        % number of elements in upper triangle
        gix=ceil((1+sqrt(8*(1:nup)-3))/2);                      % column of upper triangle
        fix=(1:nup)-(gix-1).*(gix-2)/2;                         % row of upper triangle
        if dvf                                                  % diagonal covariances
            mdif=mf(fix,:)-mf(gix,:);                           % difference in means
            vfpg=(vf(fix,:)+vf(gix,:));                         % sum of variances
            qldf=0.25*log(prod(vf,2));
            dbfg(fix+kf*(gix-1))=0.25*sum((mdif./vfpg).*mdif,2)+0.5*log(prod(vfpg,2))-qldf(fix)-qldf(gix)-hpl2; % fill in upper triangle
        else                                                    % full covariance matrices
            qldf=zeros(kf,1);
            for jf=1:kf                                         % precalculate the log determinants for f covariances
                qldf(jf)=0.5*log(prod(diag(chol(vf(:,:,jf))))); % equivalent to 0.25*log(det(vf(:,:,jg)))
            end
            for jf=1:kf-1
                vjf=vf(:,:,jf);                                 % covariance matrix for f
                for jg=jf+1:kf
                    vfg=vjf+vf(:,:,jg);
                    mdif=mf(jf,:)-mf(jg,:);                     % difference in means
                    dbfg(jf,jg)=0.25*(mdif/vfg)*mdif'+log(prod(diag(chol(vfg))))-qldf(jg)-qldf(jf)-hpl2; % fill in upper triangle
                end
            end
        end
        dbfg(gix+kf*(fix-1))=dbfg(fix+kf*(gix-1));              % now reflect upper triangle divergences into the symmmetric lower triangle
    end
    d=0;                                                        % divergence is always zero if f and g are identical
else                                                            % both f and g GMMs are specified as inputs
    kg=size(mg,1);
    if nargin<5 || isempty(vg)
        vg=ones(kg,p);                                          % default to diagonal covariances
    end
    if nargin<6 || isempty(wg)
        wg=repmat(1/kg,kg,1);                                   % default to uniform weights
    end
    if p==1                                                     % if data dimension is 1
        vg=vg(:);                                               % ... then variances are always diagonal
        dvg=true;
    else
        dvg=ismatrix(vg) && size(vg,1)==kg;                     % diagonal covariance matrix vg is supplied
    end
    % first calculate pairwise Bhattacharyya divergences between the components of f and g
    dbfg=zeros(kf,kg);                                          % space for full covariance matrices (overwritten below if f and g both diagonal)
    dix=1:p+1:p^2;                                              % index of diagonal elements in covariance matrix
    if dvf
        if dvg                                                  % both f and g have diagonal covariances
            fix=repmat((1:kf)',kg,1);                           % index into f values
            gix=reshape(repmat(1:kg,kf,1),kf*kg,1);             % index into g values
            mdif=mf(fix,:)-mg(gix,:);                           % difference in means
            vfpg=(vf(fix,:)+vg(gix,:));                         % sum of variances
            qldf=0.25*log(prod(vf,2));                          % 0.25 * log determinants of f components
            qldg=0.25*log(prod(vg,2));                          % 0.25 * log determinants of g components
            dbfg=reshape(0.25*sum((mdif./vfpg).*mdif,2)+0.5*log(prod(vfpg,2))-qldf(fix)-qldg(gix),kf,kg);
        else                                                    % diagonal f covariance but not g
            qldf=0.25*log(prod(vf,2));                          % precalculate the log determinants for f covariances
            for jg=1:kg                                         % loop through g components
                vjg=vg(:,:,jg);                                 % full covariance matrix for g
                qldg=0.5*log(prod(diag(chol(vjg))));            % equivalent to 0.25*log(det(vjg))
                for jf=1:kf                                     % loop through f components
                    vfg=vjg;                                    % take full g covariance matrix
                    vfg(dix)=vfg(dix)+vf(jf,:);                 % ... and add diagonal f covariance
                    mdif=mf(jf,:)-mg(jg,:);                     % difference in means
                    dbfg(jf,jg)=0.25*(mdif/vfg)*mdif'+log(prod(diag(chol(vfg))))-qldf(jf)-qldg;
                end
            end
        end
    else
        if dvg                                                  % diagonal g covariance but not f
            qldg=0.25*log(prod(vg,2));                          % precalculate the log determinants for g covariances
            for jf=1:kf                                         % loop through f components
                vjf=vf(:,:,jf);                                 % full covariance matrix for f
                qldf=0.5*log(prod(diag(chol(vjf))));            % equivalent to 0.25*log(det(vjf))
                for jg=1:kg                                     % loop through g components
                    vfg=vjf;                                    % take full f covariance matrix
                    vfg(dix)=vfg(dix)+vg(jg,:);                 % ... and add diagonal g covariance
                    mdif=mf(jf,:)-mg(jg,:);                     % difference in means
                    dbfg(jf,jg)=0.25*(mdif/vfg)*mdif'+log(prod(diag(chol(vfg))))-qldg(jg)-qldf;
                end
            end
        else                                                    % both f and g have full covariance matrices
            qldg=zeros(kg,1);
            for jg=1:kg                                         % precalculate the log determinants for g covariances
                qldg(jg)=0.5*log(prod(diag(chol(vg(:,:,jg))))); % equivalent to 0.25*log(det(vg(:,:,jg)))
            end
            for jf=1:kf                                         % loop through f components
                vjf=vf(:,:,jf);                                 % covariance matrix for f
                qldf=0.5*log(prod(diag(chol(vjf))));            % equivalent to 0.25*log(det(vjf))
                for jg=1:kg                                     % loop through g components
                    vfg=vjf+vg(:,:,jg);                         % calculate sum of covariance matrices
                    mdif=mf(jf,:)-mg(jg,:);                     % difference in means
                    dbfg(jf,jg)=0.25*(mdif/vfg)*mdif'+log(prod(diag(chol(vfg))))-qldg(jg)-qldf;
                end
            end
        end
    end
    dbfg=dbfg-hpl2;                                             % add correction term to all the calculated covariances
    %
    % Now calculate the variational bound
    % Note that in [3], the psi and phi symbols are interchanged in (20) and also in the previous
    % line; in addition, the subscript of phi is incorrect in the denominator of (26).
    %
    lwf=repmat(log(wf),1,kg);                                   % log of f component weights
    lwg=repmat(log(wg'),kf,1);                                  % log of g component weights
    lhf=repmat(log(1/kf),kf,kg);                                % initialize psi_f|g from [3] (cols of exp(lhf) sum to 1)
    lhg=repmat(log(1/kg),kf,kg);                                % initialize phi_g|f from [3] (rows of exp(lhg) sum to 1)
    dbfg2=2*dbfg;                                               % log of squared Bhattacharyya measure lower bound
    dbfg2f=lwf-dbfg2;                                           % interation-independent term used to update lhg
    dbfg2g=lwg-dbfg2;                                           % interation-independent term used to update lhf
    dbfg2fg=dbfg2(:)-lwf(:)-lwg(:);                             % iteration-independent termto calculate the divergence upper bound
    dub=Inf;                                                    % dummy upper bound for first iteration
    for ip=1:maxiter                                            % maximum number of iterations
        dubp=dub;                                               % save previous iteration's upper bound
        dub=-v_logsum(0.5*(lhf(:)+lhg(:)-dbfg2fg));             % update the upper bound on Bhattacharyya divergence
        if dub>=dubp                                            % quit if no longer decreasing
            break;
        end
        lhg=lhf+dbfg2f;                                         % update phi_g|f as in numerator of [3]-(25)
        lhg=lhg-repmat(v_logsum(lhg,2),1,kg);                   % normalize phi_g|f as in [3]-(25) (rows of exp(lhg) sum to 1)
        dub=-v_logsum(0.5*(lhf(:)+lhg(:)-dbfg2fg));             % update the upper bound on Bhattacharyya divergence
        lhf=lhg+dbfg2g;                                         % update psi_f|g as in numerator of [3]-(26)
        lhf=lhf-repmat(v_logsum(lhf,1),kf,1);                   % normalize psi_f|g as in [3]-(26) (cols of exp(lhf) sum to 1)
    end
    if isempty(nx) || nx==0                                     % only calculate the upper divergence bound
        d=dub;
    else
        [lnwt,jlnwt]=sort(0.5*(lhf(:)+lhg(:)-dbfg2fg)+dub,'descend'); % normalized component log weights (highest first)
        wt=exp(lnwt);
        cwt=cumsum(wt);
        nmix=1+sum(cwt<1-pruneth/nx);                           % number of mixtures for <20% chance that any excluded ones would be picked
        [fix,gix]=ind2sub([kf kg],jlnwt(1:nmix));               % mixture indices that are needed
        %
        % now create the sampling GMM distribution
        %
        ws=wt(1:nmix)/cwt(nmix);                                % sampling GMM weight vector
        ms=zeros(nmix,p);                                       % space for sampling GMM means
        vs=zeros(p,p,nmix);                                     % space for sampling GMM full covariances
        if dvf
            if dvg                                              % both f and g have diagonal covariances
                vff=vf(fix,:);
                vgg=vg(gix,:);
                vsumi=1./(vff+vgg);
                vs=2*vff.*vgg.*vsumi;                           % mixture covariance matrix
                ms=vff.*vsumi.*mg(gix,:)+vgg.*vsumi.*mf(fix,:); % mixture means
            else                                                % diagonal f covariance but not g
                for jfg=1:nmix
                    vgg=vg(:,:,gix(jfg));
                    vff=vf(fix(jfg),:);
                    vsum=vgg;
                    vsum(dix)=vsum(dix)+vff;                    % add diagonal components
                    vs(:,:,jfg)=2*vgg/vsum.*repmat(vff,p,1);    % mixture covariance matrix
                    ms(jfg,:)=mg(gix(jfg),:)/vsum.*vff+mf(fix(jfg),:)/vsum*vgg; % mixture means
                end
            end
        else
            if dvg                                              % diagonal g covariance but not f
                for jfg=1:nmix
                    vff=vf(:,:,fix(jfg));
                    vgg=vg(gix(jfg),:);
                    vsum=vff;
                    vsum(dix)=vsum(dix)+vgg;                    % add diagonal components
                    vs(:,:,jfg)=2*vff/vsum.*repmat(vgg,p,1);    % mixture covariance matrix
                    ms(jfg,:)=mf(fix(jfg),:)/vsum.*vgg+mg(gix(jfg),:)/vsum*vff; % mixture means
                end
            else                                                % both f and g have full covariance matrices
                for jfg=1:nmix
                    vff=vf(:,:,fix(jfg));
                    vgg=vg(:,:,gix(jfg));
                    vsum=vff+vgg;
                    vs(:,:,jfg)=2*vff/vsum*vgg;                 % mixture covariance matrix
                    ms(jfg,:)=mf(fix(jfg),:)/vsum*vgg+mg(gix(jfg),:)/vsum*vff; % mixture means
                end
            end
        end
        x=v_randvec(nx,ms,vs,ws);                               % draw from sampling distribution
        d=-(v_logsum(0.5*(v_gaussmixp(x,mf,vf,wf)+v_gaussmixp(x,mg,vg,wg))-v_gaussmixp(x,ms,vs,ws)))+log(nx); % montecarlo estimate of Bhatt divergence
    end
end
if ~nargout
    switch p
        case 1
            nsd=3;          % number of std deviations to plot
            nxax=251; % number of points on x-axis (MUST be odd)
            xlo=min([mf;mg]-nsd*sqrt([vf;vg]));
            xhi=max([mf;mg]+nsd*sqrt([vf;vg]));
            xax=linspace(xlo,xhi,nxax)';
            sint=(xax(2)-xax(1))/3*(4-2*mod(1:nxax,2)-[1 zeros(1,nxax-2) 1]); % Simpson's rule integration
            yf=exp(v_gaussmixp(xax,mf,vf,wf));
            yg=exp(v_gaussmixp(xax,mg,vg,wg));
            bayeserr=sint*min(yf,yg)*0.5; % calculate Bayes error
            plot(xax,yf,'-b',xax,yg,'-r',xax,sqrt(yf.*yg),'-g');
            if ~isempty(nx) && nx~=0
                ys=exp(v_gaussmixp(xax,ms,vs,ws));
                hold on
                plot(xax,exp(-d)*ys,'--k');
                hold off
                legend('f(x)','g(x)','\surd(fg)','\approx \surd(fg)','location','northeast');
                v_texthvc(0.02,0.98,sprintf('Bhattacharyya = %.1f%% (>=%.1f%%)\nBayes Err = 0.5 x %.1f%%',100*exp(-d),100*exp(-dub),200*bayeserr),'LTk');
            else
                legend('f(x)','g(x)','\surd(fg)','location','northeast');
            end
            xlabel('x');
            ylabel('Prob density');
    end
end