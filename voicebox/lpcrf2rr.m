function varargout=lpcrf2rr(varargin)
%
% For calling details please see v_lpcrf2rr.m 
%
% This dummy routine is included for backward compatibility only
% and will be removed in a future release of voicebox. Please use
% v_lpcrf2rr.m in future and/or update with v_voicebox_update.m
%
%      Copyright (C) Mike Brookes 2018
%      Version: $Id: lpcrf2rr.m 10863 2018-09-21 15:39:23Z dmb $
%
if nargout
    varargout=cell(1,nargout);
    [varargout{:}]=v_lpcrf2rr(varargin{:});
else
    v_lpcrf2rr(varargin{:});
end
