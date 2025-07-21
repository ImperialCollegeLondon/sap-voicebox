%V_M2HTMLPWD - create html documentation of files in current directory
%
% M2HTML must be on the matlab path
% available from http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=4039&objectType=FILE

%      Copyright (C) Mike Brookes 1998
%      Version: $Id: v_m2htmlpwd.m 10865 2018-09-21 17:22:45Z dmb $
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

pd=pwd;
tl=pd(max([find(pd=='\') find(pd=='/')])+1:end);
cd('..');
m2html('mfiles',tl,'htmldir',[tl '\doc']);
cd(pd);
winopen(['doc\' tl '\index.html']);
