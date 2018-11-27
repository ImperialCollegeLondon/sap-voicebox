function [u,v]=v_pow2cep(m,c,mode)
%V_CEP2POW convert cepstral means and variances to the power domain
% Inputs:
%    m: vector giving means in the power domain
%    c: covariance matrix in the power domain (or diag(c) if diagonal)
% mode: 'c'  pow=exp(v_irdct(cep))   [default]
%       'f'  pow=exp(v_rsfft(cep)/n)  [fft length even]
%       'fo' pow=exp(v_rsfft(cep)/n)  [fft length odd]
%       'i'  pow=exp(cep)           [ no transformation ]
%
% Outputs:
%    u: row vector giving the cepstral means with u(1) the 0'th cepstral coefficient
%    v: cepstral covariance matrix

%      Copyright (C) Mike Brookes 1998
%      Version: $Id: v_pow2cep.m 10865 2018-09-21 17:22:45Z dmb $
%
%   VOICEBOX is a MATLAB toolbox for speech processing.
%   Home page: http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/voicebox.html
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This program is free software; you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation; either version 2 of the License, or
%   (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You can obtain a copy of the GNU General Public License from
%   http://www.gnu.org/copyleft/gpl.html or by writing to
%   Free Software Foundation, Inc.,675 Mass Ave, Cambridge, MA 02139, USA.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<3 mode='c'; end
if min(size(c))==1
   c=diag(c);
end
m=m(:)';        % force to be a row vector
q=log(1+c./(m'*m));
p=log(m)-0.5*diag(q)';
if any(mode=='f')
   n=2*length(m)-2;
   if any(mode=='o')
      n=n+1;
   end
   u=v_rsfft(p,n);
   v=rsfft(rsfft(q,n)',n);
elseif any(mode=='i')
    u=p;
    v=q;
else
   u=v_rdct(p);
   v=rdct(rdct(q)');
end
