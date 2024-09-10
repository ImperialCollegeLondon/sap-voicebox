function p=v_paramsetch(d,q,m,c,t)
%V_PARAMSETCH update and check parameter values p=(d,q,m,c,t)
% Usage: (1) function x=func(y,q)
%            d=struct('a',1,'b',2,'c',3);   % default parameters
%            p=v_paramsetch(d,q);           % update selected parameters
%
%        (2) function x=func(y,q)
%            d=struct('a',1,'b',2,'c',3);   % default parameters
%            c={'p.a>0 && p.a<5','p.b>0'};
%            p=v_paramsetch(d,q,'E',c);     % check parameter ranges
%
%        (3) t={'a','description of parameter a';'c','and of parameter c'}
%            p=v_paramsetch(d,q,'l',c,t);   % list values with optional descrpitions
%                                           % '-','*','+' indicates default, updated and new fields
%
%  Inputs:
%       d  default parameter structure
%       q  new parameter values either a struct or alternatively matrix with
%          each row a different variable in the same order as the fields of d
%       m  mode string: any combination of the following
%           'a' include additional fields in q that are not in d
%           'A' additional fields in q constitute an error
%           'e' print errors but don't exit
%           'E' print errors and exit
%           'l' list fields and their values (default if no output)
%       c  cell array with parameter checking conditions and error message; one row per check. All results of command c{*,1) must be true.
%               e.g. {'p.a>3' 'parameter a must be > 3'} (use p for structure name)
%       t  cell array with descriptive text for each field in a new row. Either in
%          the form t(:,*)={'field' 'description'} or a single column of
%          descriptions in the same order as the fields of d
%
% Outputs:
%       p  output parameter structure
%
% Bugs/Suggestions:
% (1) When printing include "=" to show an updated parameter has not changed (might waste a lot of computation)
% (2) If input d has few entries, it would be faster to loop through d rather than q
% (3) to save speed, eliminate the dup variable and work it all out when printing

%      Copyright (C) Mike Brookes 2017
%      Version: $Id: v_paramsetch.m 10865 2018-09-21 17:22:45Z dmb $
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
p=d;                                    % initialize to the default values
numerr=0;                               % initialize error count
dn=fieldnames(d);                       % default list of parameter fields
ndn=length(dn);                         % number of default parameter fields
dup=zeros(ndn,1);                       % update flags for default fields
% sort out input arguments
if nargin<5
    t={'' ''};                          % define an empty description array
    if nargin<4
        c=cell(0);                      % define an empty check condition array       
        if nargin<3
            m='';                       % define an empty mode string
        end
    end
end
% now update the selected fields
if nargin>1 && numel(q)>0               % if update argument exists
    if isstruct(q)                      % if update argument is a structure
        qn=fieldnames(q);               % field names to update
        addnew=any(m=='a');             % new fields should be added into p
        adderr=~addnew && any(m=='A');  % new fields constitute an error
        for i=1:length(qn)              % loop through list of fields to update
            fi=qn{i};                   % get field name to update
            old=isfield(p,fi);          % is this an existing field ?
            if addnew || old
                p.(fi)=q.(fi);          % set new field value
            end
            if old
                dup(find(strcmp(fi,dn),1))=1; % indicate field is updated
            end
            if adderr && ~old
                fprintf(2,'%s is an unknown parameter field\n',fi);
                numerr=numerr+1;        % increment error count
            end
        end        
    else                                % else update argument is a matrix
        nq=min(size(q,1),ndn);          % number of fields to update
        dup(1:nq)=1;                    % indicate which fields are updated
        for i=1:nq
            p.(dn{i})=q(i,:);
        end
        if size(q,1)>nq && any(lower(m)=='e')
            fprintf(2,'More than %d parameters specified\n',nq);
            numerr=numerr+1;
        end
    end
end
% Apply parameter checks
if any(lower(m)=='e') && numel(c)>0     % check if any checks are specified
    for i=1:size(c,1)                   % one check per row of c
        if any(~eval(c{i,1}))           % perform the check
            numerr=numerr+1;
            if size(c,1)==1
                fprintf(2,'Parameter check failed: %s\n',c{i});
            else
                fprintf(2,c{i,1});
            end
        end
    end
end
% print out a list of the parameters if requested
if ~nargout || any(m=='l')
    pn=fieldnames(p);
    nf=length(pn);
    st=size(t);
    for i=1:nf
        fi=pn{i};
        vi=p.(fi);
        if i>ndn
            cat='+';
        else
            cat='-'+('*'-'-')*dup(i);
        end
        if st(2)>1
            jti=find(strcmp(fi,t(:,1)),1);
            if ~isempty(jti)
                jti=t{jti,2}; % description string
            end
        elseif i<=st(1)
            jti=t{i,1}; % description string
        else
            jti=[];
        end
        if isnumeric(vi) && length(vi)==numel(vi) && isreal(vi) % can print on one line
            fit=fi;
            if size(vi,1)>1
                fit=[fi ''''];
            end
            fprintf('%3d%c %s =',i,cat,fit);
            fprintf(' %g',vi);
            if isempty(jti)
                fprintf('\n');
            else
                fprintf(' = %s\n',jti);
            end
        else
            fprintf('%3d%c %s =',i,cat,fi);
            if isempty(jti)
                fprintf('\n');
            else
                fprintf(' %s =\n',jti);
            end
            disp(vi);
        end
    end
end
if numerr>0 && any(m=='E')
    error('%d error%c in parameter specification',numerr,(' '+(numerr>1)*('s'-' ')));
end