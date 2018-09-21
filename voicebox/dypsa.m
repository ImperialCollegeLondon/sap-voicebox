function varargout=dypsa(varargin)
%
% For calling details please see v_dypsa.m 
%
% This dummy routine is included for backward compatibility only
% and will be removed in a future release of voicebox. Please use
% v_dypsa.m in future and/or update with v_voicebox_update.m
%
%      Copyright (C) Mike Brookes 2018
%      Version: $Id: dypsa.m 10863 2018-09-21 15:39:23Z dmb $
%
if nargout
    varargout=cell(1,nargout);
    [varargout{:}]=v_dypsa(varargin{:});
else
    v_dypsa(varargin{:});
end
