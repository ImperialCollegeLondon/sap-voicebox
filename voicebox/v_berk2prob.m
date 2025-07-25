function [p,d]=v_berk2prob(b)
%V_BERK2PROB convert Berksons to probability
%
%  Inputs:  B(M,N)       matrix containing Berkson values
%
% Outputs:  P(M,N)       Corresponding probability values
%           D(M,N)       Corresponding derivatives dP/dB
%
% Berksons, or log-odds, are a nonlinear scale for measuring
% probability defined by B = log2(P./(1-P)).
% When Berksons are used to measure probability, a logistic
% psychometric function becomes linear.
%
% The inverse function is v_berk2prob()

%      Copyright (C) Mike Brookes 2014
%      Version: $Id: v_berk2prob.m 10865 2018-09-21 17:22:45Z dmb $
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
p=1-1./(1+pow2(b));
if nargout>1
    d=log(2)*p.*(1-p);
end