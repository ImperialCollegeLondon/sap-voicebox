function v_fig2pdf(h,s,p,f)
%V_FIG2EMF save a figure in pdf/eps/ps formats (H,S,P,F)
% [needs MikTeX installed]
% Usage:  (1) v_fig2pdf                       % save current figure to pdf in current folder
%         (2) v_fig2pdf([],[],'e');           % save current figure to eps in current folder
%         (3) emf=1;                        % set emf=1 to print
%             figsize=[500 300];            % default size
%             figdir='../figs/<m>-<n>';     % default destination
%             ...
%             plot (...);
%             v_figbolden(figsize);
%             if emf, v_fig2pdf(figdir), end
%
% Inputs: h   optional figure handle [use [] or omit for the current figure]
%         s   file name which can include <m> for the top level
%                 mfile name and <n> for figure number [use '[]' for '<m>_<n>']
%                 '.' suppresses the save, if s ends in '/' or '\', then '<m>_<n>' is appended
%         p   call v_figbolden(p) before printing the figure (use p=0 for v_figbolden default)
%         f   output format; a combination of the following: [default 'p']
%               'p'  pdf
%               's'  ps
%               'e'  eps
%
% Bugs:
%    (1) MATLAB does not print the figure correctly when running under
%        remote desktop; it seems to pick up the screen resolution incorrectly.

%      Copyright (C) Mike Brookes 2018
%      Version: $Id: v_fig2pdf.m 10865 2018-09-21 17:22:45Z dmb $
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
switch nargin
    case 0
        h=[];
        s='';
        p=[];
        f='p';
    case 1
        if ischar(h) || ~numel(h)   % v_fig2pdf(s)
            s=h;
            h=[];
        else                        % v_fig2pdf(h)
            s='';
        end
        p=[];
        f='p';
    case 2
        if ischar(h) || ~numel(h)   % v_fig2pdf(s,p)
            p=s;
            s=h;
            h=[];
        else                        % v_fig2pdf(h,s)
            p=[];
        end
        f='p';
    case 3
        if ischar(h) || ~numel(h)   % v_fig2pdf(s,p,f)
            f=p;
            p=s;
            s=h;
            h=[];
        else                        % v_fig2pdf(h,s,p)
            f='p';
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
set(gcf,'paperpositionmode','auto');    % preserve screen shape
if ~strcmp(s,'.')
    if isempty(f)
        f='p'; % default is pdf
    end
    sp=[s  '.pdf'];
    print('-dpdf',sp);
    %     set(gcf,'PaperPosition',[0.6350 6.3500 20.3200 12]);
    system(['pdfcrop ' sp ' ' sp]); % needs MikTeX installed
    if any(f=='s')
        system(['pdf2ps ' sp ' ' s '.ps']);
    end
    if any(f=='e')
        system(['pdf2ps ' sp ' ' s '.eps']);
    end
    if ~any(f=='p')
        system(['del ' sp]);
    end
end