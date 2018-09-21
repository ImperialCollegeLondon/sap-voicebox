function varargout=pcma2lin(varargin)
%
% For calling details please see v_pcma2lin.m 
%
% This dummy routine is included for backward compatibility only
% and will be removed in a future release of voicebox. Please use
% v_pcma2lin.m in future and/or update with v_voicebox_update.m
%
%      Copyright (C) Mike Brookes 2018
%      Version: $Id: pcma2lin.m 10863 2018-09-21 15:39:23Z dmb $
%
if nargout
    varargout=cell(1,nargout);
    [varargout{:}]=v_pcma2lin(varargin{:});
else
    v_pcma2lin(varargin{:});
end
