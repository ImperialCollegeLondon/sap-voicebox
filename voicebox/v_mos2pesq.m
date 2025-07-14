function p=v_mos2pesq(m)
%V_MOS2PESQ convert MOS speech quality scores to PESQ p=(m)
%Inputs:    m  is a matrix of MOS scores
%
%Outputs:   p  is a matrix, the same size as m, of PESQ scores
%
% The PESQ measure is defined in [2]. The mapping function, defined in [3],
% converts raw PESQ scores (which lie in the range -0.5 to 4.5) onto the
% MOS-LQO (Mean Opinion Score - Listening Quality Objective [2]) scale in the
% range 1 to 5. The MOS scale is defined in [1] as
%           5=Excellent, 4=Good, 3=Fair, 2=Poor, 1=Bad.
%
% Refs: [1]	ITU-T. Methods for subjective determination of transmission quality.
%           Recommendation P.800, Aug. 1996.
%       [2]	ITU-T. Mean opinion score (MOS) terminology.
%           Recommendation P.800.1, July 2006.
%       [2]	ITU-T. Perceptual evaluation of speech quality (PESQ), an objective
%           method for end-to-end speech quality assessment of narrowband telephone
%           networks and speech codecs. Recommendation P.862, Feb. 2001.
%       [3]	ITU-T. Mapping function for transforming P.862 raw result scores to MOS-LQO.
%           Recommendation P.862.1, Nov. 2003.

%      Copyright (C) Mike Brookes 2012-2013
%      Version: $Id: v_mos2pesq.m 10865 2018-09-21 17:22:45Z dmb $
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
persistent a b c d
if isempty(a)
    a=0.999;
    b=4.999-a;
    c=-1.4945;
    d=4.6607;
end
if nargout>0
    p=(log(b./(m-a)-1)-d)/c;
else
    if nargin<1 || isempty(m)
        pp=linspace(-0.5,4.5,100);
        mm=v_pesq2mos(pp);
    else
        mm=m;
    end
    p=v_mos2pesq(mm);
    plot(mm,p);
    ylabel('PESQ (P.862)');
    xlabel('Mean Opimion Score (MOS)');
end
