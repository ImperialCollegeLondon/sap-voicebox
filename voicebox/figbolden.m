function varargout=figbolden(varargin)
%
% For calling details please see v_figbolden.m 
%
% This dummy routine is included for backward compatibility only
% and will be removed in a future release of voicebox. Please use
% v_figbolden.m in future and/or update with v_voicebox_update.m
%
%      Copyright (C) Mike Brookes 2018
%      Version: $Id: figbolden.m 10863 2018-09-21 15:39:23Z dmb $
%
if nargout
    varargout=cell(1,nargout);
    [varargout{:}]=v_figbolden(varargin{:});
else
    v_figbolden(varargin{:});
end
