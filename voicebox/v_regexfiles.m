function tok=v_regexfiles(regex,root,m)
%V_REGEXFILES recursively searches for files matching a pattern tok=(regex,root)
%
% Usage:  (1) v_regexfiles('\.m$',[],'r')      % find all files *.m in current folder tree
%
% Inputs:
%         regex  regular expression giving the pattern to match (not including root path)
%         root   path to initial folder [default: current folder]
%         m      'n'   non recursive search [default]
%                'r'   recursive search through tree starting at root
%
% Outputs:
%          tok   cell array listing the file paths sorted alphabetically (not including the root path)
%
% Regular expressions:
%    Each character matches itself except for +?.*^$()[]{}|\
%    Precede these by \ to avoid their special meanings
%    Use '/' for the separator in file paths
%         .       Any single character, including white space
%         [xyz]   Any character contained within the brackets: x or y or z
%         [^xyz]  Any character not contained within the brackets: anything but x or y or z
%         [x-z]   Any character in the range of x through z
%         \s      Any white-space character; equivalent to [ \f\n\r\t\v]
%         \S      Any non-whitespace character; equivalent to [^ \f\n\r\t\v]
%         \w      Any alphabetic, numeric, or underscore character; equivalent to [a-zA-Z_0-9]
%         \W      Any character that is not alphabetic, numeric, or underscore; equivalent to [^a-zA-Z_0-9]
%         \d      Any numeric digit; equivalent to [0-9]
%         \D      Any nondigit character; equivalent to [^0-9]
%         \oN or \o{N}  Character of octal value N
%         \xN or \x{N}  Character of hexadecimal value N
%
%         (...)   Group
%         cat|dog Alternatives 'cat' or 'dog'
%         ^       match start of full file name (if first character)
%         $       match end of full file name (if last character)
%         \<      match start of word
%         \>      match end of word
%         ?       match preceeding character 0 or 1 times
%         *       match preceeding character or group >=0 times
%         +       match preceeding character or group >=1 times
%         {m}     match preceeding character or group exactly m times
%         {m,}    match preceeding character or group >=m  times
%         {m,n}   match preceeding character or group >=m and <=n times

%      Copyright (C) Mike Brookes 2010
%      Version: $Id: v_regexfiles.m 10865 2018-09-21 17:22:45Z dmb $
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
% root='Z:/dmb/data\speech/timit/TRAIN/DR1';
% regex='^FD.*\.wav$';
if nargin<3 || isempty(m)
    m='n';
end
if nargin<2 || isempty(root)
    root='./';
end
if isempty(regex)
    regex='.*';
end
root(root=='\')='/'; % use forward slash everywhere
if ~isempty(root) && root(end)=='/'
    root(end)=[]; % remove a final '/'
end
dirlist{1}=''; % list of sub directories to process (e.g. '/xx/yy')
ntok=0;
tok=cell(0);
rec=any(m=='r'); % recursive search
while ~isempty(dirlist)
    dd=dir([root dirlist{1}]);
    for i=1:length(dd)
        name=dd(i).name;
        full=[dirlist{1} '/' name];
        if dd(i).isdir
            if rec && name(1)~='.'   % ignore directories starting with '.'
                dirlist{end+1}=full;
            end
        else
            full(1)=[]; % remove leading '/'
            if ~isempty(regexpi(full,regex))
                ntok=ntok+1;
                tok{ntok,1}=full;
            end
        end
    end
    dirlist(1)=[];  % remove this directory from the list
end
tok=sort(tok);