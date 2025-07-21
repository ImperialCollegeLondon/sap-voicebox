function [ff,f]=v_lpccc2ff(cc,np,nc,c0)
%V_LPCCC2FF Convert complex cepstrum to complex spectrum FF=(CC,NP,NC)
%
%  Inputs: cc(nf,n)     Complex ceptral coefficients excluding c(0), one frame per row
%          np           Size of output spectrum is np+1 [n]
%                       Alternatively, a vector of output frequencies in the range 0 to 0.5
%          nc           Number of cepstral coefficients to use [np or, if np is a vector, n]
%                       Set nc=-1 to use n coefficients
%          c0(nf,1)     Cepstral coefficient c(0) [0]
%
% Outputs: ff(nf,np+2)  Complex spectrum from DC to Nyquist
%          f(1,np+2)    Normalized frequencies (0 to 0.5)
%
% The "complex cepstral coefficients", cc(n), are the inverse discrete-time Fourier transform
% of the log of the complex-valued spectrum. The cc(n) are real-valued and, for n<0, cc(n)=0.
% The "real cepstral coeffcients", rc(n), are the inverse discrete-time Fourier transform
% of the log of the magnitude spectrum; rc(0)=cc(0) and rc(n)=0.5*cc(n) for n~=0. 
% For highest speed, choose np+1 to be a power of 2.

%      Copyright (C) Mike Brookes 2014
%      Version: $Id: v_lpccc2ff.m 10865 2018-09-21 17:22:45Z dmb $
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
[nf,mc]=size(cc);
if nargin<2 || ~numel(np)
    if nargout
        np=mc;
    else
        np=128;
    end
end
if nargin>=3 && numel(nc)==1 && nc==-1 nc=mc; end
if nargin<4 || ~numel(c0) c0=zeros(nf,1); end
if numel(np)>1 || np(1)<1
    if nargin<3 || ~numel(nc) nc=mc; end
    f=np(:)';
    if nc==mc
        ff=exp([c0 cc]*exp(-2i*pi*(0:mc)'*f));
    else
        ff=exp([c0 lpccc2cc(cc,nc)]*exp(-2i*pi*(0:nc)'*f));
    end
else
    if nargin<3 || ~numel(nc) nc=np; end
    if nc==mc
        ff=exp(v_rfft([c0 cc].',2*np).');
    else
        ff=exp(v_rfft([c0 v_lpccc2cc(cc,nc)].',2*np).');
    end
    f=linspace(0,0.5,np+1);
end
if ~nargout
    subplot(2,1,2);
    plot(f,unwrap(angle(ff.')));
    xlabel('Normalized frequency f/f_s');
    ylabel('Phase (rad)');
    subplot(2,1,1);
    plot(f,db(abs(ff.')));
    xlabel('Normalized frequency f/f_s');
    ylabel('Gain (dB)');
end

