function wavwrite(y,fs,n,fn)
%WAVREAD  Legacy MATLAB function to write .WAV file (Y,Fs,N,FILENAME)
% wavwrite writes data to 8-, 16-, 24-, and 32-bit .wav files.
%
% Usage:
% wavwrite(y,'filename')        writes the data stored in the variable y to a WAVE file called filename.
%                               The data has a sample rate of 8000 Hz and is assumed to be 16-bit.
%                               Each column of the data represents a separate channel.
%                               Therefore, stereo data should be specified as a matrix with two columns.
%                               Amplitude values outside the range [-1,+1] are clipped prior to writing.
% wavwrite(y,Fs,'filename')     writes the data stored in the variable y to a WAVE file called filename.
%                               The data has a sample rate of Fs Hz and is assumed to be 16-bit.
%                               Amplitude values outside the range [-1,+1] are clipped prior to writing.
% wavwrite(y,Fs,N,'filename')   writes the data stored in the variable y to a WAVE file called filename.
%                               The data has a sample rate of Fs Hz and is N-bit, where N is 8, 16, 24, or 32.
%                               For N < 32, amplitude values outside the range [-1,+1] are clipped.
% Note:    8-, 16-, and 24-bit files are type 1 integer pulse code modulation (PCM). 32-bit files are written as type 3 normalized floating point.

%	   Copyright (C) Mike Brookes 2018
%      Version: $Id: wavwrite.m 10865 2018-09-21 17:22:45Z dmb $
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
if nargin<3
    v_writewav(y,8000,fs,'p'); % default is 8kHz, 16 bit
elseif nargin<4
    v_writewav(y,fs,n,'p'); % default is 16 bit
else
    switch n
        case 8
            v_writewav(y,fs,fn,'8p'); % write 8 bit fixed-point data
        case 16
            v_writewav(y,fs,fn,'p'); % default is 16 bit
        case 24
            v_writewav(y,fs,fn,'24p'); % write 24 bit fixed-point data
        case 32
            v_writewav(y,fs,fn,'v'); % write 32 bit floating-point data
        otherwise
            error('invalid precision: %d',n);
    end
end
