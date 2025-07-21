function v_fig2emf(h,s,p,f)
%V_FIG2EMF save a figure in windows metafile format (H,S,P)
% Usage:  (1) v_fig2emf      % save current figure in current folder
%         (2) emf=1;                        % set emf=1 to print
%             figsize=[500 300];            % default size
%             figdir='../figs/<m>-<n>';     % default destination
%             ...
%             plot (...);
%             v_figbolden(figsize);
%             if emf, v_fig2emf(figdir), end
%
% Inputs: h   figure handle [use [] or omit for the current figure]
%         s   optional file name which can include <m> for the top level
%                 mfile name and <n> for figure number [if empty or missing: '<m>_<n>']
%                 '.' suppresses the save, if s ends in '/' or '\', then '<m>_<n>' is appended
%         p   call v_figbolden(p) before printing the figure (use p=0 for v_figbolden default)
%         f   output format [default 'meta']
%             jpeg, png, tiff, tiffn, meta, bmpmono, bmp, bmp16m, bmp256,
%             hdf, pbm, pbmraw, pcxmono, pcx24b, pcx256, pcx16, pgm,
%             pgmraw, ppm, ppmraw; pdf, eps, epsc, eps2, epsc2, meta, svg, ps, psc, ps2, psc2 
%
% Bugs:
%    (1) MATLAB does not print the figure correctly when running under
%        remote desktop; it seems to pick up the screen resolution incorrectly.

%      Copyright (C) Mike Brookes 2012
%      Version: $Id: v_fig2emf.m 10865 2018-09-21 17:22:45Z dmb $
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
switch nargin
    case 0
        h=[];
        s='';
        p=[];
    case 1
        if ischar(h) || ~numel(h)   % v_fig2emf(s)
            s=h;
            h=[];
        else                        % v_fig2emf(h)
            s='';
        end
        p=[];
    case 2
        if ischar(h) || ~numel(h)   % v_fig2emf(s,p)
            p=s;
            s=h;
            h=[];
        else                        % v_fig2emf(h,s)
            p=[];
        end
    case 3
        if ischar(h) || ~numel(h)   % v_fig2emf(s,p,f)
            f=p;
            p=s;
            s=h;
            h=[];
        else                        % v_fig2emf(h,s,p)
            f='meta';
        end
end
if ~numel(h)
    h=gcf;
else
    figure(h);
end
if ~numel(s)
    s='<m>_<n>';
elseif s(end)=='/' || s(end)=='\'
    s=[s '<m>_<n>'];
end
[st,sti]=dbstack;
if numel(st)>1
    mfn=st(end).name;  % ancestor mfile name
else
    mfn='Figure';
end
if isreal(h)
    fn=num2str(round(h)); % get figure number
else
    fn=num2str(get(h,'number'));  % in new versions of matlab use this method
end
ix=strfind(s,'<m>');
while numel(ix)>0
    s=[s(1:ix-1) mfn s(ix+3:end)];
    ix=strfind(s,'<m>');
end
ix=strfind(s,'<n>');
while numel(ix)>0
    s=[s(1:ix-1) fn s(ix+3:end)];
    ix=strfind(s,'<n>');
end
if numel(p)>0
    if numel(p)==1 && p==0
        v_figbolden;
    else
        v_figbolden(p)
    end
end
set(gcf,'paperpositionmode','auto');  % preserve screen shape
if ~strcmp(s,'.')
    %     eval(['print -dmeta ' s]); % previous version
    if nargin<3
        f='meta';
    end
    print(['-d' f],s);
end