function c=v_cblabel(l,h)
%V_CBLABEL add a label to a colorbar c=(l,h)
%
% Usage: (1) imagesc(...)
%            colorbar;
%            v_cblabel('Colorbar label');       % label closest colorbar to the current axis
%
%        (2) imagesc(...)
%            ch=colorbar;
%            v_cblabel('Colorbar label',ch);    % label the explicitly specified colorbar
%
% Inputs:
%
%     L        Label string for colorbar
%     H        Handle of the colorbar, axis or figure [default = current figure]
%
% Outputs:
%
%     C        Handle of the colorbar
%
%
%      Copyright (C) Mike Brookes 2000-2009
%      Version: $Id: v_cblabel.m 10865 2018-09-21 17:22:45Z dmb $
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
persistent t
if isempty(t)
    t=[1 0 0.5 0; 0 1 0 0.5]'; % matrix used to find centre of graphical object
end
if nargin<2
    h=gcf; % default is current figure
end
switch get(h,'Type')
    case 'axes'
        if strcmpi(get(h,'Tag'),'colorbar')
            c=h;
        else
            cg=h.Position*t;                              % coordinates of the centre of requested axis
            while ~strcmp(get(h,'Type'),'figure')           % loop to find ancestor of h of type figure
                h=get(h,'Parent');                          % find parent figure
                if h==0
                    error('cannot find ancestor figure');
                end
            end
            cx=findobj(h,'tag','Colorbar');                 % find all colorbars on this figure
            nc=length(cx);
            switch nc
                case 0
                    error('There is no colour bar on this figure')
                case 1
                    c=cx(1);
                otherwise                                   % find the nearest colorbar to the centre of requested axis                  
                    c=cx(1);                                % select the first colorbar
                    d=sum((c.Position*t-cg).^2);            % squared distance to centre of requested axis
                    for ic=2:nc                             % loop through each colorbar
                        di=sum((cx(ic).Position*t-cg).^2);  % squared distance to centre of requested axis
                        if di<d                             % if this colorbar is nearer
                            c=cx(ic);                       % ... select this colorbar
                            d=di;                           % ... and save the squared distance
                        end
                    end
            end
        end
    case 'figure'
        cx=findobj(h,'tag','Colorbar');
        nc=length(cx);
        switch nc
            case 0
                error('There is no colour bar on this figure')
            case 1
                c=cx(1);
            otherwise                                   % find the nearest colorbar to the centre of current graph
                cg=gca().Position*t;                    % coordinates of the centre of current graph
                c=cx(1);                                % select the first colorbar
                d=sum((c.Position*t-cg).^2);            % squared distance to centre of current graph
                for ic=2:nc                             % loop through each colorbar
                    di=sum((cx(ic).Position*t-cg).^2);  % squared distance to centre of current graph
                    if di<d                             % if this colorbar is nearer
                        c=cx(ic);                       % ... select this colorbar
                        d=di;                           % ... and save the squared distance
                    end
                end
        end
    case 'colorbar'
        c=h;
    otherwise
        error(['h argument must be colorbar, axis or figure handle but is ''' get(h,'Type') '''']);
end
set(get(c,'ylabel'),'string',l);