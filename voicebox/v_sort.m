function [b,i,j]=v_sort(varargin)
%V_SORT   Sort in ascending or descending order including an inverse index.
%
% This routine performes the same function as sort but includes an additional
% output, j, which is the same size as b and i and gives an inverse index .
% If the input is a column vector, a, then b=a(i) and a=b(j).
%
% The routine does not currently accept the "dim" argument to sort and the
% first argument must be a vector or matrix.
%

%      Copyright (C) Mike Brookes 2023
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
%
[b,i]=sort(varargin{:});
if nargout>2
    if nargin>1 && isnumeric(varargin{2}) || ndims(b)>2
        error('The dim input is not supported and the input must be a vector or matrix');
    else
        [r,c]=size(i);
        j=zeros(r,c);
        if r==1 && c>1  % if a row vector
            j(i)=1:c;
        else
            k=i+repmat(0:r:r*(c-1),r,1);
            j(k(:))=repmat((1:r)',c,1);
        end
    end
end
