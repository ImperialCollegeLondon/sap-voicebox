function varargout=pcmu2lin(varargin)
%
% For calling details please see v_pcmu2lin.m 
%
% This dummy routine is included for backward compatibility only
% and will be removed in a future release of voicebox. Please use
% v_pcmu2lin.m in future and/or update with v_voicebox_update.m
%
%      Copyright (C) Mike Brookes 2018
%      Version: $Id: pcmu2lin.m 10863 2018-09-21 15:39:23Z dmb $
%
if nargout
    varargout=cell(1,nargout);
    [varargout{:}]=v_pcmu2lin(varargin{:});
else
    v_pcmu2lin(varargin{:});
end
