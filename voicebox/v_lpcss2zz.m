function zz=v_lpcss2zz(ss,nr)
%V_LPCSS2ZZ Convert s-plane poles to z-plane poles ZZ=(SS,NR)
%
%  Inputs: ss(n,q)  n frames each with q complex-valued pole positions in normalized-Hz units.
%                   A formant with frequency f (in range 0 to 0.5) and bandwidth b will give an
%                   s-plane pole-pair of approximately (-b/2 +-j*f)/fs where fs is the sample frequency.
%          nr       Optional argument specifying how many of the q poles should *not* be
%                   supplemented by including their conjugate pair. The conjugates of poles nr+1:q
%                   will be appended to ss as additional columns. As a special case, nr=-1
%                   will include the conjugate of any column containing a non-real number.
%
% Outputs: zz(n,p)  z-plane poles. If nr is omitted, then p=q; if nr>=0, then p=2*q-nr.
%
% The inverse function is zz=v_lpczz2ss(zz)

%      Copyright (C) Mike Brookes 1997-2025
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
if nargin>1 && nr<size(ss,2)
    if nr>=0
        ss=[ss conj(ss(:,nr+1:end))];
    else
        ss=[ss conj(ss(:,any(imag(ss)~=0,1)))];
    end
end
zz=exp(2*pi*ss);
if ~nargout
    q=(0:200)*2*pi/200;
    plot(real(zz.'),imag(zz.'),'x',cos(q),sin(q),':k',[-1.05 0; 1.05 0],[0 -1.05; 0 1.05],':k');
    axis([-1.05 1.05 -1.05 1.05]);
    axis equal;
    xlabel('Real');
    ylabel('Imag');
end

