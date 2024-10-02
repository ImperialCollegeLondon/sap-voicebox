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
%          each row being the value of the variables in the same order as the
%          fields of d. If q is a matrix then all updated values will be row
%          vectors with the same number of elements.
%       m  mode string: any combination of the following
%           'a' include additional fields in q that are not in d
%           'A' additional fields in q constitute an error
%           'e' print errors (but don't exit unless 'E' given as well)
%           'E' exit if there are any errors
%           'l' list fields and their values (default if no output)
%       c  cell array with parameter checking conditions (use p for structure name) and error
%               message; one row per check. All results of command c{*,1) must be true.
%               e.g. {'p.a>3' 'parameter a must be > 3'; 'p.b<2' 'parameter b must be < 2'}
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
p=d;                                            % initialize output structure to the default values
numerr=0;                                       % initialize error count
dn=fieldnames(d);                               % list of parameter default fields
ndn=length(dn);                                 % number of default parameter fields
nq=0;                                           % default value for size(q,1)
% handle common case efficiently with 1 or 2 input arguments and an output argument
if nargin<=2 && nargout>0
    if nargin==2 && numel(q)>0                  % if update argument exists
        if isstruct(q)                          % if update argument is a structure
            qn=fieldnames(q);                   % field names to update
            nq=length(qn);                      % number of fields to update
            if nq<ndn                           % relatively few entries in q
                for i=1:nq                      % loop through list of fields to update
                    fi=qn{i};                   % get field name to update
                    if isfield(p,fi);           % is this an existing field ?
                        p.(fi)=q.(fi);          % set new field value
                    end
                end
            else                                % more entries in q than in d
                for i=1:ndn                     % loop through list of existing fields
                    fi=dn{i};                   % get field name to potentially update
                    if isfield(q,fi);           % is there a replacement value for this field ?
                        p.(fi)=q.(fi);          % set new field value
                    end
                end
            end
        else                                    % else update argument is a matrix
            nq=size(q,1);                       % number of fields to update
            for i=1:min(nq,ndn)
                p.(dn{i})=q(i,:);
            end
        end
    end
else                                            % we have >2 arguments or else no output arguments
    % sort out input arguments
    if nargin<5
        t={'' ''};                              % define an empty description array
        if nargin<4
            c=cell(0,2);                        % define an empty check condition array
            if nargin<3
                m='';                           % define an empty check mode string
            end
        end
    end
    % now update the selected fields
    adderr=any(m=='A');                         % new fields constitute an error
    addnew=any(m=='a');                         % new fields should be added into p
    printerr=any(m=='e');                       % print error messages
    numerr=0;                                   % initialize count of errors
    if numel(q)>0                               % if update argument is non-empty
        if isstruct(q)                          % if update argument is a structure
            qn=fieldnames(q);                   % field names to update
            nq=length(qn);                      % number of fields to update
            if addnew                           % we are including all fields in q(n)
                for i=1:nq                      % loop through list of fields to update
                    p.(fi)=q.(qn{i});           % set new field value
                end
            else
                for i=1:length(qn)              % loop through list of fields to update
                    fi=qn{i};                   % get field name to update
                    if isfield(p,fi)            % if this is an existing field ...
                        p.(fi)=q.(fi);          % set new field value
                    elseif adderr               % if this is an non-existant field ...
                        numerr=numerr+1;        % increment error count
                        if printerr
                            fprintf(2,'Unknown parameter: %s\n',fi);
                        end
                    end
                end
            end
        else                                    % else update argument is a matrix
            nq=size(q,1);                       % number of fields to update
            for i=1:min(nq,ndn)
                p.(dn{i})=q(i,:);
            end
            if nq>ndn && adderr
                numerr=numerr+nq-ndn;
                if printerr
                    fprintf(2,'%d extra parameters specified\n',nq-ndn);
                end
            end
        end
    end
    % Apply parameter checks
    if numel(c)>0                               % check if any checks are specified
        for i=1:size(c,1)                       % one check per row of c
            if ~all(eval(c{i,1}))               % perform the check
                numerr=numerr+1;
                if size(c,1)==1
                    fprintf(2,'Parameter check failed: %s\n',c{i});
                else
                    fprintf(2,c{i,2});
                end
            end
        end
    end
    % print out a list of the parameters if requested
    if ~nargout || any(m=='l')
        pn=fieldnames(p);
        nf=length(pn);                          % length of updated structure
        st=size(t);
        for i=1:nf
            fi=pn{i};
            vi=p.(fi);
            if i>ndn
                cat='+';
            else
                if nq>0 && isstruct(q)          % if update argument is a structure
                    if isfield(q,fi)            % was this field updated ?
                        if isequal(p.(fi),q.(fi))
                            cat='=';            % updated to existing value
                        else
                            cat='*';            % updated to new value
                        end
                    else                        % not an updated field
                        cat='-';                % not updated
                    end
                else                            % if update argument is a matrix
                    if i>nq                     % beyond list of updated fields
                        cat='-';                % not updated
                    else
                        if isequal(p.(fi),q(i,:))
                            cat='=';            % updated to existing value
                        else
                            cat='*';            % updated to new value
                        end
                    end
                end
            end
            if st(2)>1
                jti=find(strcmp(fi,t(:,1)),1);
                if ~isempty(jti)
                    jti=t{jti,2};               % description string
                end
            elseif i<=st(1)
                jti=t{i,1};                     % description string
            else
                jti=[];
            end
            if isnumeric(vi) && length(vi)==numel(vi) && isreal(vi) % can print on one line
                fit=fi;
                if size(vi,1)>1
                    fit=[fi ''''];
                end
                fprintf('%3d%c %s:',i,cat,fit);
                fprintf(' %g',vi);
                if isempty(jti)
                    fprintf('\n');
                else
                    fprintf(' = %s\n',jti);
                end
            elseif numel(vi)<6
                fprintf('%3d%c %s:',i,cat,fi);
                if isempty(jti)
                    fprintf('\n');
                else
                    fprintf(' %s:\n',jti);
                end
                disp(vi);
            else
                fprintf('%3d%c %s: [large]',i,cat,fi);
                if isempty(jti)
                    fprintf('\n');
                else
                    fprintf(' = %s\n',jti);
                end
            end
        end
    end
    if numerr>0 && any(m=='E')
        error('%d error%c in parameter specification',numerr,(' '+(numerr>1)*('s'-' ')));
    end
end