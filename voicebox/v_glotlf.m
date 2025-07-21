function [u,q]=v_glotlf(d,t,p)
%V_GLOTLF   Liljencrants-Fant glottal model U=(D,T,P)
%  Usage: (1) f0=100;                % frequency in Hz
%             t=linspace(0,0.1,100); % time axis
%             u=v_glotlf(0,t*f0)       % glottal waveform using default parameters
%
%         (2) v_glotlf(1,[],[0.6 0.2 0.25]); % plot graph if no output argument
%
%  Inputs:  d selects which derivative of the flow waveform to calculate; 0<=d<=3 [0]
%           t is a vector of time instants at which to calculate the waveform. Time units are in
%           fractions of a cycle measured from the start of the open phase (the integer part is ignored).
%           p is a vector, [te, E0/Ee, 1-tp/te], defining the waveform [0.6 0.1 0.2]
%             See below for the parameter meanings.
%             The peak negative value of the flow derivative is Ug'(te) = -Ee
%             The peak flow occurs at tp when the flow derivative equals zero.
%
% Outputs:  u the output waveform
%           q a structure with the following fields taken from Fig 2 of reference [1]:
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
%                q.tc=1     cycle end time (always 1)                [1]
%                q.Utc      Integral of Ug' over one cycle           [approx 0]
%
%             Values are shown in brackets for the default input parameters: p=[0.6 0.1 0.2]          
%             Note that the equation for the return phase in Fig. 2 of [1] is wrong; the correct equation is given in (11).
%             The value of epsilon in this equation is chosen to ensure the flow derivative, Ug'(t), integrates to zero.
%
%   In the source-tract model of speech production [2, Ch.3], the glottal flow waveform passes through the vocal tract filter
%   (typically an all-pole LPC filter) and then a lip-radiation filter (typically a differentiator: R(z)=1-1/z) which converts
%   volume flow at the lips to pressure. If the filters are quasi-constant, their order may be interchanged and the speech
%   pressure waveform obtained by applying the vocal tract filter to the first derivative of the glottal flow waveform.
%
% Bug: this signal has not been low-pass filtered and will therefore be aliased [this is a bug]
%
% References
% [1]	G. Fant, J. Liljencrants, and Q. Lin. A four-parameter model of glottal flow. STL-QPSR, 26 (4): 1-13, 1985.
% [2]   L. R. Rabiner and R. W. Schafer. Digital Processing of Speech Signals. Prentice-Hall, 1978. ISBN 0-13-213603-1.

%      Copyright (C) Mike Brookes 1998-2017
%      Version: $Id: v_glotlf.m 10865 2018-09-21 17:22:45Z dmb $
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

if nargin<1 || isempty(d)
    d=0;                        % default output is Ug(t)
end
if nargin < 2 || isempty(t)
    tt=(0:99)'/100;             % default time axis
else
    tt=t-floor(t);              % only interested in the fractional part of t
end
u=zeros(size(tt));              % space for output
de=[0.6 0.1 0.2]';              % default parameters
if nargin < 3 || isempty(p)
    p=de;
elseif length(p)<2
    p=[p(:); de(length(p)+1:2)];
end

% Calculate the parameters in terms of ugd(t), the glottal flow derivative

te=p(1);                                % t_e from [1]. ugd(te) is the negative peak.
mtc=te-1;                               % -1 times duration of return phase
e0=1;                                   % E0 from [1]
wa=pi/(te*(1-p(3)));                    % omega_g from [1]
a=-log(-p(2)*sin(wa*te))/te;            % alpha from [1]
inta=e0*((wa/tan(wa*te)-a)/p(2)+wa)/(a^2+wa^2); % integral of first portion of waveform (0<t<te)

% convergence is only possible if 0 <= inta <= 0.5*(1-te)/p(2) as ta varies between 0 and 1-te
% if inta<0 we must reduce p(2); if inta>0.5*(1-te)/p(2) we must increase p(2)

rb0=p(2)*inta;                          % initial time constant neglects the offset; correct if rb<<(1-te)
rb=rb0;                                 % rb is closure time constant = 1/epsilon in [1]

% Use Newton to determine closure time constant, rb, so that flow starts and ends at zero.
thresh=1e-9;                            % convergence threshold
for i=1:15                              % maximum of 15 iterations (usually fewer)
    kk=1-exp(mtc/rb);                   % kk = ta/rb = ta * epsilon in [1]
    err=rb+mtc*(1/kk-1)-rb0;
    derr=1-(1-kk)*(mtc/rb/kk)^2;
    rb=rb-err/derr;                     % rb is closure time constant = 1/epsilon in [1]
    if abs(err)<thresh, break, end
end
if abs(err)>thresh                      % print error if unable to find a value of rb that gives a zero integral for U'(t)
    error('Requested glottal waveform parameters are not feasible');
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
    q.Ei=e0*exp(a*ti).*sin(wa*ti);      % max value of Ug': Ug'(ti)=Ei
    q.Ee=1/p(2);                        % negated min value of Ug': Ug'(te)=-Ee
    q.alpha=a;                          % exponent coefficient in open phase    
    q.epsilon=1/rb;                     % exponent coefficient in return phase
    q.omega=wa;                         % angular frequency in open phase (omega = pi/tp)
    q.t0=0;                             % start of cycle  
    q.ti=ti;                            % time of peak in Ug': Ug'(ti)=Ei   
    q.tp=tp;                            % time of peak in Ug : Ug(tp)=Up     
    q.te=te;                            % time of peak negative value in Ug': Ug'(te)=-Ee
    q.ta=rb/(p(2)*e1);                  % initial slope of return phase is Ug''(te)=-Ee/ta
    q.tc=1;                             % end of cycle 
    q.Utc=-err/p(2);                    % integral of Ug' (should always be zero)
end
if ~nargout
    plot(t,u,'-b',[t(1) t(end)],[0 0],':k');
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
        v_texthvc(0,-q.Ee,' Ee','lbk');
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
