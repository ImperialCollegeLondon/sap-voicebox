function [ff,fo]=v_lpcpf2ff(pf,np,fi)
%V_LPCPF2FF Convert power spectrum to complex spectrum [FF,FO]=(PF,NP,FI)
%
%  Inputs: pf(nf,n)     Power spectrum at n discrete frequencies, one frame per row
%          np           Number of complex cepstral coefficients to use (excluding c0) [n-1]
%                          should be greater than the sum of the numerator
%                          and denominator filter orders but less than n
%          fi(1,n)      Vector of frequencies [linspace(0,0.5,n)]
%                         including this argument slows down the routine
%
% Outputs: ff(nf,n)     Complex spectrum (pf = abs(ff).^2
%          fo(1,n)      Vector of frequencies
%
% This routine converts a power spectrum into the corresponding complex
% spectrum. It determines the phase spectrum under the assumption that it
% is minimum phase. The routine works by converting first to the compex
% cepstrum.

%      Copyright (C) Mike Brookes 2014
%      Version: $Id: v_lpcpf2ff.m 10865 2018-09-21 17:22:45Z dmb $
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
if nargin<3 fi=[];
    if nargin<2
        np=nq-1; % number of cepstal coefficients (excl c(0))
    end
end
[cc,c0]=v_lpcpf2cc(pf,np,fi);
if ~numel(fi)
    fi=nq-1;
end
[fx,fo]=v_lpccc2ff(cc,fi,-1,c0);
ff=sqrt(pf).*exp(1i*angle(fx));
if ~nargout
    subplot(2,1,2);
    plot(fo,unwrap(angle(ff.')));
    xlabel('Normalized frequency f/f_s');
    ylabel('Phase (rad)');
    subplot(2,1,1);
    plot(fo,db(abs(ff.')),'-b',fo,db(pf.')/2,':k');
    xlabel('Normalized frequency f/f_s');
    ylabel('Gain (dB)');
end


