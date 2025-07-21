function [y,fs,h]=v_readau(filename,mode)
%V_READAU  Read a SUN .AU format sound file [Y,FS,H]=(FILENAME)
%
% Inputs:
%           filename : character string containing filename (default extension .au)
%           mode:    't' = trim leading and trailing silences
%                    'h' = read header only
%             'd'    Look in data directory: v_voicebox('dir_data')
%
% Outputs:
%           y  : matrix containing one channel per column
%           fs : sample frequency
%           h  : parameter array:
%                h(1) = header length (bytes)
%                h(2) = data length (bytes)
%                h(3) = data format (see below)
%                h(4) = sample rate (Hz)
%                h(5) = number of channels

%	   Copyright (C) Mike Brookes 2008
%      Version: $Id: v_readau.m 10865 2018-09-21 17:22:45Z dmb $
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


if nargin<2,  mode='0'; end
if any(mode=='d')
    filename=fullfile(v_voicebox('dir_data'),filename);
end
fid=fopen(filename,'rb','b');       % big endian
if fid == -1
    fn=[filename,'.au'];
    fid=fopen(fn,'rb','l');
    if fid ~= -1, filename=fn; end
end
if fid == -1, error('Can''t open %s for input',filename); end
[hdr,n]=fread(fid,6,'int');
if n ~= 6 || hdr(1)~=779316836, error('Can''t read header from AU file %s',filename); end

if any(mode =='h')
    y=hdr(2:6);
else
    if nargout>1
        fs=hdr(5);
        if nargout>2
            h=hdr(2:6);
        end
    end
    fseek(fid,hdr(2),-1);
    switch hdr(4)
        case 1
                        y=fread(fid,inf,'uchar');
                        y=v_pcmu2lin(y);
                case 2
            y=fread(fid,inf,'schar');
        case 3
            y=fread(fid,inf,'short');
        otherwise
            error('Unsupported format type %d in AU file %s',hdr(4),filename);
    end
    nsamp=length(y);
    msamp=floor(nsamp/hdr(6));
    y=reshape(y,hdr(6),msamp)';
end
fclose(fid);
