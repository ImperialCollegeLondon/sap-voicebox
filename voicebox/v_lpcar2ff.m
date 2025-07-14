function [ff,f]=v_lpcar2ff(ar,np)
%V_LPCAR2FF LPC: Convert AR coefs to complex spectrum FF=(AR,NP)
%
%  Inputs: ar(nf,n)     AR coefficients, one frame per row
%          np           Size of output spectrum is np+1 [n]
%
% Outputs: ff(nf,np+1)  Complex spectrum from DC to Nyquist
%          f(1,np+1)    Normalized frequencies (0 to 0.5)
%
% For high speed make np equal to a power of 2

%      Copyright (C) Mike Brookes 1998-2014
%      Version: $Id: v_lpcar2ff.m 10865 2018-09-21 17:22:45Z dmb $
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
%    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[nf,p1]=size(ar);
if nargin<2
    if nargout
        np=p1-1;
    else
        np=128;
    end
end
ff=(v_rfft(ar.',2*np).').^(-1);
f=(0:np)/(2*np);
if ~nargout
    subplot(2,1,2);
    plot(f,unwrap(angle(ff)));
    xlabel('Normalized frequency f/f_s');
    ylabel('Phase (rad)');
    subplot(2,1,1);
    plot(f,db(abs(ff)));
    xlabel('Normalized frequency f/f_s');
    ylabel('Gain (dB)');
    title('LPC Spectrum');
end

