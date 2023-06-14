function [eta,etaf]=v_finishat(frac,tol,fmt)
%V_FINISHAT print estimated finish time of a long computation (FRAC,TOL,FMT)
% Usage:  (1)  for i=1:many
%                  v_finishat((i-1)/many);  % initializes on first pass when i=1
%                  ... computation ...
%              end
%
%         (3)  v_finishat(0);               % explicit initialization before loop
%              for i=1:many
%                  ... computation ...
%                  v_finishat(i/many);      % calculate fraction completed
%              end
%
%         (5)  for i=MI:NI
%                  for j=MJ:NJ
%                      for k=MK:NK
%                          v_finishat([i MI NI; j MJ NJ; k MK NK]); % one row per nested loop
%                          ... computation ...
%                      end
%                  end
%              end
%
%         (6)  for i=MI:DI:NI
%                  for j=MJ:DJ:NJ
%                      for k=MK:DK:NK
%                          v_finishat([i MI DI NI; j MJ DJ NJ; k MK DK NK]); % one row per nested loop
%                          ... computation ...
%                      end
%                  end
%              end
%
% Inputs: FRAC = fraction of total comutation that has been completed
%                Alternatively at start of inner loop: [i MI DI NI; j MJ DJ NJ; k MK DK NK; ...] where i, j, k are
%                nested loop indices and MI:DI:NI, MJ:DJ:NJ, MK:DK:NK their limits. If the DI, DJ, DK, ... all equal 1
%                The may be omitted. Use k+1 instead of k if placed at the end of the inner loop.
%                As a special case, FRAC=0 initializes the routine.
%         TOL  = Tolerance in minutes. If the estimated time has changed by less
%                than this, then nothing will be printed. [default 10% of remaining time]
%         FMT  = Format string which should include:
%                   %s for estimated finish time
%                   %d for remaining minutes
%                   %t for remaining hr:min:sec
%                   %f for fraction complete
%                   %p for % complete
%                The %t, %f and %p options can include optional width and/or decimal-place dimensions (e.g. %.2f)
%
% Output: ETA  = string containing the expected finish time
%                specifying this will suppress printing message to std err (fid=2)
%         ETAF = expected finish time as a daynumber
%
% Example:       v_finishat(0);
%                for i=1:many
%                    long computation;
%                    v_finishat(i/many);
%                end

%      Copyright (C) Mike Brookes 1998-2023
%      Version: $Id: v_finishat.m 10865 2018-09-21 17:22:45Z dmb $
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

persistent oldt oldnw tstart
[nf,nv]=size(frac);
if nargin<3
    fmt='Estimated finish at %s (%.0p done, %t remaining)\n';
end
if isempty(tstart) || nv<3 && all(frac(:,1)<=[ones(nf-1,1); 0]) || nv>=3 && all(frac(:,1)==frac(:,2)) % initialize if fraction done is <=0
    oldt=0;
    eta='Unknown';
    tstart=tic;
else
    if nv==2 % obsolete format that assumes all loop indices start at 1
        fp=cumprod(frac(:,2));
        frac=sum((frac(:,1)-1)./fp)+1/fp(end);
    elseif nv==3
        fp=cumprod(frac(:,3)-frac(:,2)+1);
        frac=sum((frac(:,1)-frac(:,2))./fp);
    else
        fp=cumprod(floor((frac(:,4)-frac(:,2))./frac(:,3))+1);
        frac=sum(round((frac(:,1)-frac(:,2))./frac(:,3))./fp);
    end
    nw=now;                             % current time as serial number
    sectogo=(1/frac-1)*toc(tstart);      % seconds to go
    newt=nw+sectogo/86400;       % add estimated time in days
    if nargin<2 || ~numel(tol)
        tol=max(0.1*(newt-nw)*1440,1);
    end
    if ~exist('oldt','var') || length(oldt)~=1 || oldt==0 || (abs(newt-oldt)>tol/1440 && (nw-oldnw)>10/86400) || (nw-oldnw)>10/1440 || nargout>0
        oldt=newt;
        if floor(oldt)==floor(nw)
            df='HH:MM';
        else
            df='HH:MM dd-mmm-yyyy';
        end
        eta=datestr(oldt,df);
        if ~nargout
            ix=find(fmt=='%',1);
            while ~isempty(ix)
                fprintf(2,fmt(1:ix-1));
                fmt=fmt(ix:end);
                ix=find(fmt>='a' & fmt<='z',1); % find letter
                switch fmt(ix)
                    case 's'
                        fprintf(2,fmt(1:ix),eta);
                    case 'd'
                        fprintf(2,fmt(1:ix),round(sectogo/60));
                    case 'f'
                        if ix>2
                            fprintf(2,fmt(1:ix),frac);
                        else
                            fprintf(2,'%.2f',frac);
                        end
                    case 'p'
                        if ix>2
                        fprintf(2,[fmt(1:ix-1) 'f%%'],frac*100);
                        else
                            fprintf(2,'%.0f%%',frac*100);
                        end
                    case 't'
                        if ix>2
                            if sectogo>=3600
                                fprintf(2,[fmt(1:ix-1) 'f hr'],sectogo/3600);
                            elseif sectogo>=60
                                fprintf(2,[fmt(1:ix-1) 'f min'],sectogo/60);
                            else
                                fprintf(2,[fmt(1:ix-1) 'f sec'],sectogo);
                            end
                        else
                            if sectogo>=36000
                                fprintf(2,'%.0f hr',sectogo/3600);
                            elseif sectogo>=3600
                                fprintf(2,'%.1f hr',sectogo/3600);
                            elseif sectogo>=600
                                fprintf(2,'%.0f min',sectogo/60);
                            elseif sectogo>=60
                                fprintf(2,'%.1f min',sectogo/60);
                            else
                                fprintf(2,'%.0f sec',sectogo);
                            end
                        end
                end
                fmt=fmt(ix+1:end);
                ix=find(fmt=='%',1);
            end
            fprintf(2,fmt);
        end
        oldnw=nw;                           %
    end
end
etaf=oldt;