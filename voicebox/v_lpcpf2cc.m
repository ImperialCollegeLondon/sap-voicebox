function [cc,c0]=v_lpcpf2cc(pf,np,f)
%V_LPCPF2CC Convert power spectrum to complex cepstrum CC=(PF,NP)
%
%  Inputs: pf(nf,n)    Power spectrum, uniformly spaced DC to Nyquist
%          np          Number of cepstral coefficients to calculate [n-1]
%          f(1,n)      Frequencies of pf columns [linspace(0,0.5,n)]
%
% Outputs: cc(nf,np)  Complex spectrum from DC to Nyquist
%          c0(nf,1)   The zeroth cepstral coefficient, c(0)
%
% Note since the log spectrum is not normally bandlimited, this conversion is not exact unless n >> np

%      Copyright (C) Mike Brookes 1998-2014
%      Version: $Id: v_lpcpf2cc.m 10865 2018-09-21 17:22:45Z dmb $
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
[nf,nq]=size(pf);
if nargin<2 || ~numel(np) np=nq-1; end
if nargin<3 || ~numel(f)
    cc=v_rsfft(log(pf.')).'/(2*nq-2);
    c0=cc(:,1)*0.5;
    cc(:,nq)=cc(:,nq)*0.5;
    if np>nq-1
        cc=[cc(:,2:nq) zeros(nf,np-nq+1)];
    else
        cc=cc(:,2:np+1);
    end
else
    cc=0.5*(log(pf)/cos(2*pi*f(:)*(0:min(np,nq-1))));
    c0=cc(:,1);
    cc=cc(:,2:end);
    if np>nq-1
        cc(1,np)=0;
    end
end


