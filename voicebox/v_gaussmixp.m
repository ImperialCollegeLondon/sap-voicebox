function [lp,rp,kh,kp]=v_gaussmixp(y,m,v,w,a,b)
%V_GAUSSMIXP calculate probability densities from or plot a Gaussian mixture model
%
% Usage: (1) v_gaussmixp([],m,v,w) % plot a 1D or 2D gaussian mixture pdf
%
% Inputs: n data values, k mixtures, p parameters, q data vector size
%
%   Y(n,q) = (possibly transformed) input data (or optional plot range if no output arguments)
%            Row Y(i,:) represents a single observation of the transformed GMM data
%            point X: Y(i,1:q)=X(i,1:p)*A'+B'. If A and B are omitted and q=p, then Y(i,:)=X(i,:).
%   M(k,p) = mixture means for x(p)
%   V(k,p) or V(p,p,k) variances (diagonal or full) for x(p)
%   W(k,1) = weights (must sum to 1)
%   A(q,p) = transformation: y=x*A'+ B' (where y and x are row vectors).
%   B(q,1)   If A is omitted or null, y=x*I(B,:)' where I is the identity matrix.
%            If B is also omitted or null, y=x*I(1:q,:)'.
%   Note that most commonly, q=p and A and B are omitted entirely.
%
% Outputs
%
%  LP(n,1) = log probability of each data point
%  RP(n,k) = relative probability of each mixture
%  KH(n,1) = highest probability mixture
%  KP(n,1) = relative probability of highest probability mixture
%
% See also: v_gaussmix, v_gaussmixd, v_gaussmixg, v_randvec

%      Copyright (C) Mike Brookes 2000-2009
%      Version: $Id: v_gaussmixp.m 10865 2018-09-21 17:22:45Z dmb $
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
[k,p]=size(m);
[n,q]=size(y);
if isempty(y)                       % no y data supplied; we must calculate q
    if nargin<=4 || (nargin==5 && isempty(a)) || (nargin>=6 && isempty(a) && isempty(b))
        q=p;                        % no transformation
    elseif ~isempty(a)              % y=x*a' or y=x*a'+b'
        q=size(a,1);
    else
        q=length(b);                % b contains a list of dimensions to extract
    end
end
if nargin<4                         % w not supplied; assume uniform weights
    w=repmat(1/k,k,1);
    if nargin<3
        v=ones(k,p);                % v not supplied assume identity covariance matrix
    end
end
fv=ndims(v)>2 || size(v,1)>k;       % fv=1 if full covariance matrix is supplied
if nargin>4 && ~isempty(a)          % a is specified so need to transform the data
    if nargin<6 || isempty(b)
        m=m*a';                     % no offset b specified
    else
        m=m*a'+repmat(b',k,1);      % offset b is specified
    end
    v1=v;                           % save the original covariance matrix array
    v=zeros(q,q,k);                 % create new full covariance matrix array
    if fv
        for ik=1:k
            v(:,:,ik)=a*v1(:,:,ik)*a';
        end
    elseif all(sum(a~=0,2)==1)      % a does not disturb diagonality
        for ik=1:k
            v(ik,:)=v1(ik,:)*(a.^2)';
        end
    else
        for ik=1:k
            v(:,:,ik)=(a.*repmat(v1(ik,:),q,1))*a';
        end
        fv=true;                    % now we definitely have a full covariance matrix
    end
elseif q<p || nargin>4              % a is unspecified but need to select coefficient subset
    if nargin<6 || isempty(b)       % b not given; just use first q dimensions
        b=1:q;
    end
    m=m(:,b);
    if fv
        v=v(b,b,:);
    else
        v=v(:,b);
    end
end

memsize=v_voicebox('memsize');    % set memory size to use

lp=zeros(n,1);
rp=zeros(n,k);
wk=ones(k,1);                           % index to replicate k times
if n>0                                  % y data is supplied
    if ~fv                              % diagonal covariance
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Diagonal Covariance matrices  %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % If data size is large then do calculations in chunks

        nb=min(n,max(1,floor(memsize/(8*q*k))));    % chunk size for testing data points
        nl=ceil(n/nb);                  % number of chunks
        jx0=n-(nl-1)*nb;                % size of first chunk
        im=repmat((1:k)',nb,1);
        wnb=ones(1,nb);
        wnj=ones(1,jx0);
        vi=-0.5*v.^(-1);                % data-independent scale factor in exponent
        lvm=log(w)-0.5*sum(log(v),2);   % log of external scale factor (excluding -0.5*q*log(2pi) term)

        % first do partial chunk

        jx=jx0;
        ii=1:jx;
        kk=repmat(ii,k,1);
        km=repmat(1:k,1,jx);
        py=reshape(sum((y(kk(:),:)-m(km(:),:)).^2.*vi(km(:),:),2),k,jx)+lvm(:,wnj);
        mx=max(py,[],1);                % find normalizing factor for each data point to prevent underflow when using exp()
        px=exp(py-mx(wk,:));            % find normalized probability of each mixture for each datapoint
        ps=sum(px,1);                   % total normalized likelihood of each data point
        rp(ii,:)=(px./ps(wk,:))';                % relative mixture probabilities for each data point (columns sum to 1)
        lp(ii)=log(ps)+mx;

        for il=2:nl
            ix=jx+1;
            jx=jx+nb;                    % increment upper limit
            ii=ix:jx;
            kk=repmat(ii,k,1);
            py=reshape(sum((y(kk(:),:)-m(im,:)).^2.*vi(im,:),2),k,nb)+lvm(:,wnb);
            mx=max(py,[],1);                % find normalizing factor for each data point to prevent underflow when using exp()
            px=exp(py-mx(wk,:));            % find normalized probability of each mixture for each datapoint
            ps=sum(px,1);                   % total normalized likelihood of each data point
            rp(ii,:)=(px./ps(wk,:))';                % relative mixture probabilities for each data point (columns sum to 1)
            lp(ii)=log(ps)+mx;
        end
    else
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Full Covariance matrices  %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        pl=q*(q+1)/2;
        lix=1:q^2;
        cix=repmat(1:q,q,1);
        rix=cix';
        lix(cix>rix)=[];                                        % index of lower triangular elements
        lixi=zeros(q,q);
        lixi(lix)=1:pl;
        lixi=lixi';
        lixi(lix)=1:pl;                                        % reverse index to build full matrices
        vt=reshape(v,q^2,k);
        vt=vt(lix,:)';                                            % lower triangular in rows

        % If data size is large then do calculations in chunks

        nb=min(n,max(1,floor(memsize/(24*q*k))));    % chunk size for testing data points
        nl=ceil(n/nb);                  % number of chunks
        jx0=n-(nl-1)*nb;                % size of first chunk
        wnb=ones(1,nb);
        wnj=ones(1,jx0);

        vi=zeros(q*k,q);                    % stack of k inverse cov matrices each size q*q
        vim=zeros(q*k,1);                   % stack of k vectors of the form inv(vt)*m
        mtk=vim;                             % stack of k vectors of the form m
        lvm=zeros(k,1);
        wpk=repmat((1:q)',k,1);

        for ik=1:k

            % these lines added for debugging only
            %             vk=reshape(vt(k,lixi),q,q);
            %             condk(ik)=cond(vk);
            %%%%%%%%%%%%%%%%%%%%
            [uvk,dvk]=eig(reshape(vt(ik,lixi),q,q));      % convert lower triangular to full and find eigenvalues
            dvk=diag(dvk);
            if(any(dvk<=0))
                error('Covariance matrix for mixture %d is not positive definite',ik);
            end
            vik=-0.5*uvk*diag(dvk.^(-1))*uvk';   % calculate inverse
            vi((ik-1)*q+(1:q),:)=vik;           % vi contains all mixture inverses stacked on top of each other
            vim((ik-1)*q+(1:q))=vik*m(ik,:)';   % vim contains vi*m for all mixtures stacked on top of each other
            mtk((ik-1)*q+(1:q))=m(ik,:)';       % mtk contains all mixture means stacked on top of each other
            lvm(ik)=log(w(ik))-0.5*sum(log(dvk));       % vm contains the weighted sqrt of det(vi) for each mixture
        end
        %
        %         % first do partial chunk
        %
        jx=jx0;
        ii=1:jx;
        xii=y(ii,:).';
        py=reshape(sum(reshape((vi*xii-vim(:,wnj)).*(xii(wpk,:)-mtk(:,wnj)),q,jx*k),1),k,jx)+lvm(:,wnj);
        mx=max(py,[],1);                % find normalizing factor for each data point to prevent underflow when using exp()
        px=exp(py-mx(wk,:));  % find normalized probability of each mixture for each datapoint
        ps=sum(px,1);                   % total normalized likelihood of each data point
        rp(ii,:)=(px./ps(wk,:))';                % relative mixture probabilities for each data point (columns sum to 1)
        lp(ii)=log(ps)+mx;

        for il=2:nl
            ix=jx+1;
            jx=jx+nb;        % increment upper limit
            ii=ix:jx;
            xii=y(ii,:).';
            py=reshape(sum(reshape((vi*xii-vim(:,wnb)).*(xii(wpk,:)-mtk(:,wnb)),q,nb*k),1),k,nb)+lvm(:,wnb);
            mx=max(py,[],1);                % find normalizing factor for each data point to prevent underflow when using exp()
            px=exp(py-mx(wk,:));  % find normalized probability of each mixture for each datapoint
            ps=sum(px,1);                   % total normalized likelihood of each data point
            rp(ii,:)=(px./ps(wk,:))';                % relative mixture probabilities for each data point (columns sum to 1)
            lp(ii)=log(ps)+mx;
        end
    end
    lp=lp-0.5*q*log(2*pi);
end
if nargout >2
    [kp,kh]=max(rp,[],2);
end
if ~nargout
    if q==1
        nxx=256;                        % grid size for 1D pdf plot
        if size(y,1)<2
            nsd=2;                      % number of std deviations
            sd=sqrt(v(:));
            xax=linspace(min(m-nsd*sd),max(m+nsd*sd),nxx);
        else
            xax=linspace(min(y),max(y),nxx);
        end
        plot(xax,v_gaussmixp(xax(:),m,v,w),'-b');
        xlabel('Parameter 1');
        ylabel('Log probability density');
        if n>0
            hold on
            plot(y,lp,'xr');
            hold off
        end
    else
        if q>2 % if dimension >2, take the first two dimensions only
            m=m(:,1:2);
            if fv
                v=v(1:2,1:2,:);
            else
                v=v(:,1:2);
            end
        end
        nxx=256;                        % grid size for 2D pdf plot
        if n<2                          % number of data points is 1 or 0
            nsd=2;                      % number of std deviations to plot
            if fv
                sd=sqrt([v(1:4:end)' v(4:4:end)']); % extract diagonal elements from each mixture covariance
            else
                sd=sqrt(v);
            end
            xax=linspace(min(m(:,1)-nsd*sd(:,1)),max(m(:,1)+nsd*sd(:,1)),nxx);
            yax=linspace(min(m(:,2)-nsd*sd(:,2)),max(m(:,2)+nsd*sd(:,2)),nxx);
        else
            yminmax=(eye(2)+0.1*[1 -1; -1 1])*[min(y,[],1);max(y,[],1)];
            xax=linspace(yminmax(1,1),yminmax(2,1),nxx);
            yax=linspace(yminmax(1,2),yminmax(2,2),nxx);
        end
        xx(:,:,1)=repmat(xax',1,nxx);
        xx(:,:,2)=repmat(yax,nxx,1);
        imagesc(xax,yax,reshape(gaussmixp(reshape(xx,nxx^2,2),m,v,w),nxx,nxx)');
        axis 'xy';
        colorbar;
        xlabel('Parameter 1');
        ylabel('Parameter 2');
        v_cblabel('Log probability density');
        if n>0                              % if y data is supplied
            hold on
            cmap=colormap;
            clim=get(gca,'CLim');           % get colourmap limits
            msk=lp>clim*[0.5; 0.5];
            if any(msk)
                plot(y(msk,1),y(msk,2),'x','markeredgecolor',cmap(1,:));
            end
            if any(~msk)
                plot(y(~msk,1),y(~msk,2),'x','markeredgecolor',cmap(64,:));
            end
            hold off
        end
    end
end