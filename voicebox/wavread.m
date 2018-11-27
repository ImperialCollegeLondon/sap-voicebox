function [y,fs,bits]=wavread(fn,n)
%WAVREAD  Legacy MATLAB function to read .WAV file [Y,FS,BITS]=(FILENAME,NMAX)
% wavread supports multichannel data, with up to 32 bits per sample, and supports reading 24- and 32-bit .wav files.
%
% Usage:
% y = wavread('filename')               loads a WAVE file specified by the string filename, returning
%                                       the sampled data in y. The .wav extension is appended if no
%                                       extension is given. Amplitude values are in the range [-1,+1].
% [y,Fs,bits] = wavread('filename')     returns the sample rate (Fs) in Hertz and the number of bits
%                                       per sample (bits) used to encode the data in the file.
% [...] = wavread('filename',N)         returns only the first N samples from each channel in the file.
% [...] = wavread('filename',[N1 N2])   returns only samples N1 through N2 from each channel in the file.
% siz = wavread('filename','size')      returns the size of the audio data contained in the file in place
%                                       of the actual audio data, returning the vector siz = [samples channels].

%	   Copyright (C) Mike Brookes 2018
%      Version: $Id: wavread.m 10865 2018-09-21 17:22:45Z dmb $
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
if nargin<2
    [y,fs,wm,fx]=v_readwav(fn);
elseif ischar(n)
    if strcmp(n,'size')
        [y,fs,wm,fx]=v_readwav(fn,'',0);
        y=fx(4:5); % number of samples and channels
    else
        error('%s is invalid option',n);
    end
elseif length(n)<2
    [y,fs,wm,fx]=v_readwav(fn,'',n);
else
    [y,fs,wm,fx]=v_readwav(fn,'',n(2)-n(1)+1,n(1)-1);
end
bits=fx(7); % bits precision