function [u,q]=v_glotlf(d,t,p)
%V_GLOTLF   Liljencrants-Fant glottal model U=(D,T,P)
%  Usage: (1) f0=100;                % frequency in Hz
%             t=linspace(0,0.1,100); % time axis
%             u=v_glotlf(0,t*f0)       % glottal waveform using default parameters
%
%         (2) v_glotlf(1,[],[0.6 0.2 0.25]); % plot graph if no output argument
%
%  Inputs:  d selects which derivative of the flow waveform to calculate; 0<=d<=3 [0]
%           t is a vector of time instants at which to calculate the
%             waveform. Time units are in fractions of a cycle.
%           p is a vector, [te, E0/Ee, 1-tp/te], defining the waveform [0.6 0.1 0.2]
%             See below for the parameter meanings.
%             The peak negative value of the flow derivative is Ug'(te) = -Ee
%             The peak flow occurs at tp.
%
% Outputs:  u the output waveform
%           q a structure with the following fields taken from Fig 2 of [1]:
%                q.Up       peak value of Ug occurs at tp            [0.979]
%                q.E0=1     gain in open phase (always 1)            [1]
%                q.Ei       peak value of Ug' occurs at ti           [3.57]
%                q.Ee       min value of Ug' is -Ee and occurs at te [10]
%                q.alpha    exponent coefficient in open phase       [4.42]
%                q.epsilon  exponent coefficient in return phase     [22.4]
%                q.omega    angular frequency in open phase (=pi/tp) [6.55]
%                q.t0=0     start time (always 0)                    [0]
%                q.ti       time of peak in Ug'                      [0.33]  
%                q.tp       time of peak in Ug                       [0.48]
%                q.te       time of peak negative value in Ug'       [0.6]
%                q.ta       initial slope of return phase is Ee/ta   [0.045]
%                q.tc=1     cycle end tiem (always 1)                [1]
%
%             Values are shown in brackets for the default input parameters: p=[0.6 0.1 0.2]          
%             Note that for the return phase in Fig. 2 is wrong; the correct equation is (11).
%             The value of epsilon is chosen to ensure the flow derivative, Ug'(t), integrates to zero.
%
% Bug: this signal has not been low-pass filtered and will therefore be aliased [this is a bug]
%
% References
% [1]	G. Fant, J. Liljencrants, and Q. Lin. A four-parameter model of glottal flow. STL-QPSR, 26 (4): 1�13, 1985.

%      Copyright (C) Mike Brookes 1998-2017
%      Version: $Id: v_glotlf.m 10865 2018-09-21 17:22:45Z dmb $
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

if nargin<1 || isempty(d)
    d=0;                        % default output is Ug(t)
end
if nargin < 2 || isempty(t)
    tt=(0:99)'/100;             % default time axis
else
    tt=t-floor(t);              % only interested in th fractional part of t
end
u=zeros(size(tt));              % space for output
de=[0.6 0.1 0.2]';              % default parameters
if nargin < 3 || isempty(p)
    p=de;
elseif length(p)<2
    p=[p(:); de(length(p)+1:2)];
end

% Calculate the parameters in terms of ugd(t), the glottal flow derivative

te=p(1);                        % t_e from [1]. ugd(te) is the negative peak.
mtc=te-1;                       % -1 times duration of return phase
e0=1;                           % E0 from [1]
wa=pi/(te*(1-p(3)));            % omega_g from [1]
a=-log(-p(2)*sin(wa*te))/te;    % alpha from [1]
inta=e0*((wa/tan(wa*te)-a)/p(2)+wa)/(a^2+wa^2); % integral of first portion of waveform (0<t<te)

% if inta<0 we should reduce p(2)
% if inta>0.5*p(2)*(1-te) we should increase p(2)

rb0=p(2)*inta;  % initial time constant neglects the offset; correct if rb<<(1-te)
rb=rb0;         % rb is closure time constant = 1/epsilon in [1]

% Use Newton to determine closure time constant, rb, that flow starts and ends at zero.

for i=1:4
    kk=1-exp(mtc/rb);
    err=rb+mtc*(1/kk-1)-rb0;
    derr=1-(1-kk)*(mtc/rb/kk)^2;
    rb=rb-err/derr;               % rb is closure time constant = 1/epsilon in [1]
end
e1=1/(p(2)*(1-exp(mtc/rb)));
ta=tt<te;
tb=~ta;
if d==0                                 % output Ug(t)
    u(ta)=e0*(exp(a*tt(ta)).*(a*sin(wa*tt(ta))-wa*cos(wa*tt(ta)))+wa)/(a^2+wa^2);
    u(tb)=e1*(exp(mtc/rb)*(tt(tb)-1-rb)+exp((te-tt(tb))/rb)*rb);
    ylab='u(t)';
elseif d==1                             % output Ug'(t)
    u(ta)=e0*exp(a*tt(ta)).*sin(wa*tt(ta));
    u(tb)=e1*(exp(mtc/rb)-exp((te-tt(tb))/rb));
    ylab='u''(t)';
elseif d==2                             % output Ug''(t)
    u(ta)=e0*exp(a*tt(ta)).*(a*sin(wa*tt(ta))+wa*cos(wa*tt(ta)));
    u(tb)=e1*exp((te-tt(tb))/rb)/rb;
    ylab='u''''(t)';
else
    error('Derivative must be 0,1 or 2');
end
if nargout~=1
    ti=(pi+atan(-wa/a))/wa;             % time of peak in Ug'   
    tp=pi/wa;                           % time of peak in Ug      
    q.Up=e0*wa*(exp(a*tp)+1)/(a^2+wa^2); % peak value of Ug occurs at tp   
    q.E0=1;                             % gain in open phase (always 1) 
    q.Ei=e0*exp(a*ti).*sin(wa*ti);      % peak value of Ug' occurs at ti 
    q.Ee=1/p(2);                        % note ugd(te)=-Ee
    q.alpha=a;                          % exponent coefficient in open phase    
    q.epsilon=1/rb;                     % exponent coefficient in return phase
    q.omega=wa;                         % angular frequency in open phase (=pi/tp)
    q.t0=0;                             % start of cycle  
    q.ti=ti;                            % time of peak in Ug'   
    q.tp=tp;                            % time of peak in Ug      
    q.te=te;                            % time of peak negative value in Ug' 
    q.ta=rb/(p(2)*e1);                  % initial slope of return phase is Ee/ta
    q.tc=1;                             % end of cycle  
end
if ~nargout
    plot(tt,u,'-b',[tt(1) tt(end)],[0 0],':k');
    v_axisenlarge([-1 -1.05]);
    xlim=get(gca,'xlim');
    ylim=get(gca,'ylim');
    hold on
    plot([1;1]*[q.ti q.tp q.te],ylim,':k');
    v_texthvc(q.ti,0,' ti','lbk');
    v_texthvc(q.tp,0,' tp','lbk');
    if d==0
        plot(xlim,[1;1]*q.Up,':k');
        v_texthvc(0,q.Up,' Up','ltk');
        v_texthvc(te,0,' te','lbk');
    elseif d==1
        plot(xlim,[1;1]*[q.Ei -q.Ee],':k');
        plot([te te+q.ta te+q.ta],[-q.Ee 0 ylim(2)],':k');
        v_texthvc(te,0,' te','rtk');
        v_texthvc(te+q.ta,0,' te+ta','lbk');
        v_texthvc(0,-q.Ee,' �Ee','lbk');
        v_texthvc(0,q.Ei,' Ei','ltk');
    elseif d==2
        plot(xlim,[1;1]*q.Ee/q.ta,':k');
        v_texthvc(0,q.Ee/q.ta,' Ee/ta','ltk');
        v_texthvc(te,0,' te','lbk');
    end
    hold off
    xlabel('Fraction of period');
    ylabel(ylab);
end
