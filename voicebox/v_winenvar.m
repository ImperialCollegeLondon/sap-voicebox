function d=v_winenvar(n)
%V_WINENVAR get windows environment variable [D]=(N)
%
% Inputs: N  name of environment variable (e.g. 'temp')
%
% Outputs: D  value of variable or [] is non-existant
%
% Notes: (1) This is WINDOWS specific and needs to be fixed to work on UNIX
%        (2) The search is case insensitive (like most of WINDOWS).
%
% Examples: (1) Open a temporary text file:
%               d=winenar('temp'); fid=fopen(fullfile(d,'temp.txt'),'wt');

%   Copyright (c) 2005 Mike Brookes,  mike.brookes@ic.ac.uk
%      Version: $Id: v_winenvar.m 10865 2018-09-21 17:22:45Z dmb $
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
p=['%',n,'%'];
[s,d]=system(['echo ',p]);
while d(end)<=' ';
    d(end)=[];
end
if strcmp(d,p)
    d=[];
end