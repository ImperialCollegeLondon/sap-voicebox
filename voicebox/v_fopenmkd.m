function [fid,mes]=v_fopenmkd(fn,pe,mf,en)
%V_FOPENMKD is the same as FOPEN but creates any missing directories [fid,mes]=(fn,pe,mf,en)
%
% This procedure is functionally identical to fopen() except that
% it will create the requested folder if it doesn't exist

%	   Copyright (C) Mike Brookes 2011
%      Version: $Id: v_fopenmkd.m 10865 2018-09-21 17:22:45Z dmb $
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
p=fileparts(fn);
switch nargin  % first try calling fopen normally
    case 1
        [fid,mes]=fopen(fn);
    case 2
        [fid,mes]=fopen(fn,pe);
    case 3
        [fid,mes]=fopen(fn,pe,mf);
    otherwise
        [fid,mes]=fopen(fn,pe,mf,en);
end
if fid<0  % if it was unsuccessful, check if the directory exists
    ff=dir(p);
    if ~numel(ff)
        st=mkdir(p); % if not, create the directory
        if ~st
            error('Cannot create directory/folder: %s',p);
        end
    elseif ~ff(1).isdir
        error('Directory/folder name %s is an existing file.',p);
    end
    switch nargin
        case 1
            [fid,mes]=fopen(fn);
        case 2
            [fid,mes]=fopen(fn,pe);
        case 3
            [fid,mes]=fopen(fn,pe,mf);
        otherwise
            [fid,mes]=fopen(fn,pe,mf,en);
    end
end
