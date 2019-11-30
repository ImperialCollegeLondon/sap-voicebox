% Voicebox: Speech Processing Toolbox for MATLAB
%
% Function names have been prefixed "v_" to avoid name conflicts; the
% unprefixed aliases will be removed in a future version. Use the function
% v_voicebox_update to update old code which, by default, updates all .m files
% in the current folder.
%
% Audio File Input/Output
%   v_readwav       - Read a WAV file
%   v_writewav      - Write a WAV file
%   v_readhtk       - Read HTK waveform files
%   v_writehtk      - Write HTK waveform files
%   v_readsfs       - Read SFS files
%   v_readsph       - Read SPHERE/TIMIT waveform files
%   v_readaif       - Read AIFF Audio Interchange file format file
%   v_readcnx       - Raed BT Connex database files
%   v_readau        - Read AU files (from SUN)
%   v_readflac      - Read FLAC files
%   wavread       - Emulation of legacy MATLAB function to read a WAV file
%   wavwrite      - Emulation of legacy MATLAB function to write a WAV file
%
% Frequency Scales
%   v_frq2bark      - Convert Hz to the Bark frequency scale
%   v_frq2cent      - Convert Hertz to cents scale
%   v_frq2erb       - Convert Hertz to erb rate scale
%   v_frq2mel       - Convert Hertz to mel scale
%   v_frq2midi      - Convert Hertz to midi scale of semitones
%   v_bark2frq      - Convert the Bark frequency scale to Hz
%   v_cent2frq      - Convert cents scale to Hertz
%   v_erb2frq       - Convert erb rate scale to Hertz
%   v_mel2frq       - Convert mel scale to Hertz
%   v_midi2frq      - Convert midi scale of semitones to Hertz
%
% Fourier/DCT/Hartley Transforms
%   v_rfft          - FFT of real data
%   v_irfft         - Inverse of FFT of real data
%   v_rsfft         - FFT of real symmetric data
%   v_rdct          - DCT of real data
%   v_irdct         - Inverse of DCT of real data
%   v_rhartley      - Hartley transform of real data
%   v_zoomfft       - calculate the fft over a portion of the spectrum with any resolution
%   v_sphrharm      - calculate forward and inverse shperical harmonic transformations
%
% Probability Distributions
%   v_berk2prob     - Convert Berksons to probability
%   v_gaussmix      - Fit a gaussian mixture model to data values
%   v_gaussmixd     - Calculate marginal and conditional density distributions and perform inference
%   v_gaussmixk     - Estimate Kuleck-Leibler divergence between two GMMs
%   v_gaussmixg     - Calculate global mean, covariance and mode of a Gaussian mixture
%   v_gaussmixm     - Estimate mean and variance of GMM vector magnitude
%   v_gaussmixp     - Calculates and plots full and marginal probability density from a GMM
%   v_gaussmixt     - multiplies two GMMs together
%   v_gausprod      - Calculate the product of multiple gaussians
%   v_gmmlpdf       - OBSOLETE - use v_gaussmixp instead
%   v_histndim      - N-dimensional histogram (+ plot 2-D histogram)
%   v_lognmpdf      - Prob density function of a lognormal distribution
%   v_maxgauss      - Calculate the mean and variance of max(x) where x is a gaussian vector
%   v_normcdflog    - Calculate the log of the Normal cdf without underflow
%   v_pdfmoments    - Convert between central moments, raw moments and cumulants
%   v_prob2berk     - Convert probability to Berksons
%   v_randvec       - Generate random vectors
%   v_randiscr      - Generate discrete random values with prescribed probabilities
%   v_rnsubset      - Select a random subset
%   v_randfilt      - Generate filtered random noise without transients
%   v_stdspectrum   - Generate standard audio and speech spectra
%   v_usasi         - Generate USASI noise (obsolete: use v_stdspectrum instead)
%   v_chimv         - Approximate mean and variance of non-central chi distribution
%   v_vonmisespdf   - Calculate the pdf of the Von Mises (circular normal) distribution
%
% Vector Distances
%   v_disteusq      - Calculate euclidean/mahanalobis distances between two sets of vectors
%   v_distchar      - COSH spectral distance between AR coefficient sets 
%   v_distitar      - Itakura spectral distance between AR coefficient sets 
%   v_distisar      - Itakura-Saito spectral distance between AR coefficient sets
%   v_distchpf      - COSH spectral distance between power spectra 
%   v_distitpf      - Itakura spectral distance between power spectra 
%   v_distispf      - Itakura-Saito spectral distance between power spectra 
%
% Speech Analysis
%   v_activlev      - Calculate the active level of speech (ITU-T P.56)
%   v_activlevg     - Calculate the active level of speech robustly to added noise
%   v_dypsa         - Estimate glottal closure instants from a speech waveform
%   v_enframe       - Divide a speech signal into frames for frame-based processing
%   v_correlogram   - calculate a 3-D v_correlogram
%   v_ewgrpdel      - Energy-weighted group delay waveform
%   v_fram2wav      - Interpolate frame-based values to a waveform
%   v_filtbankm     - Transformation matrix for a linear/mel/erb/bark-spaced v_filterbank from dft output 
%   v_fxpefac       - PEFAC pitch tracker
%   v_fxrapt        - RAPT pitch tracker
%   v_gammabank     - Calculate a bank of IIR gammatone filters
%   v_importsii     - Calculate the SII importance function (ANSI S3.5-1997)
%   v_modspect      - Caluclate the modulation specrogram
%   v_mos2pesq      - Convert MOS values to equivalent PESQ scores
%   v_overlapadd    - Reconstitute an output waveform after frame-based processing
%   v_pesq2mos      - Convert PESQ scores to equivalent MOS values
%   v_phon2sone     - Convert signal levels from phons to sones
%   v_psycdigit     - Experimental estimation of monotonic/unimodal psychometric function using TIDIGITS
%   v_psycest       - Experimental estimation of monotonic psychometric function
%   v_psycestu      - Experimental estimation of unimodal psychometric function 
%   v_psychofunc    - Psychometric functions
%   v_sigma         - Identify glottal closure and opening intstants from Lx or EGG waveform
%   v_snrseg        - Segmental SNR and Global SNR calculation
%   v_sone2phon     - Convert signal levels from sones to phons
%   v_soundspeed    - Returns the speed of sound in air as a function of temperature
%   v_spgrambw      - Spectrogram with many options
%   v_stoi2prob     - Convert STOI intelligibility measure to probability of correct recognition
%   v_txalign       - Align two sets of time markers
%   v_vadsohn       - Voice activity detector
%   v_ppmvu         - Calculate the PPM, VU or EBU levels of a signal
%
% LPC Analysis of Speech
%   v_ccwarpf       - warp complex cepstrum coefficients
%   v_lpcauto       - LPC analysis: autocorrelation method
%   v_lpcbwexp      - Bandwidth expansion of LPC filter
%   v_lpccovar      - LPC analysis: covariance method
%   v_lpcconv       - Arbitrary conversion between LPC representations
%   v_lpcifilt      - inverse filter a speech signal
%   v_lpcrand       - create random stable filters
%   v_lpcrr2am      - Matrix with all LPC filters up to order p
%   v_lpcstable     - check for stability and force stable filters
%   v_lpc--2--      - Convert between alternative LPC representation
%
% Speech Synthesis
%   v_sapisynth     - Text-to-speech synthesis of a string or matrix 
%   v_glotros       - Rosenberg model of glottal waveform
%   v_glotlf        - Liljencrants-Fant model of glottal waveform
%
% Speech Enhancement
%   v_estnoiseg     - Estimate the noise spectrum from noisy speech using MMSE method
%   v_estnoisem     - Estimate the noise spectrum from noisy speech using minimum statistics
%   v_specsub       - Speech enhancement using spectral subtraction
%   v_ssubmmse      - Speech enhancement using MMSE estimate of spectral amplitude or log amplitude
%   v_ssubmmsev     - Speech enhancement using MMSE estimate and VAD-based noise estimation
%   v_specsubm      - (obsolete algorithm) Spectral subtraction 
%   v_spendred      - Speech Enhancement and Dereverberation (Doire's algorithm)
%
% Speech Coding
%   v_lin2pcmu      - Convert linear PCM to mu-law PCM
%   v_pcma2lin      - Convert A-law PCM to linear PCM
%   v_pcmu2lin      - Convert mu-law PCM to linear PCM
%   v_lin2pcma      - Convert linear PCM to A-law PCM
%   v_kmeanlbg      - Vector quantisation: LBG algorithm
%   v_kmeanhar      - Vector quantization: K-harmonic means
%   v_potsband      - Create telephone bandwidth filter
%   v_kmeans        - Vector quantisation: k-means algorithm
%
% Speech Recognition
%   v_ldatrace      - constrained Linear Discriminant Analysis to maximize trace(W\B)
%   v_melbankm      - Mel v_filterbank transformation matrix
%   v_melcepst      - Mel cepstrum frontend for recogniser
%   v_cep2pow       - Convert mel cepstram means & variances to power domain
%   v_pow2cep       - Convert power domain means & variances to mel cepstrum
%
% Signal Processing
%   v_addnoise      - Add noise to a signal at a chosen SNR
%   v_convfft       - 1-dimensional convolution/corrolation using FFT
%   v_ditherq       - Add dither and quantize a signal
%   v_filterbank    - Apply a bank of IIR filters to a signal
%   v_findpeaks     - Find peaks in a signal or spectrum
%   v_maxfilt       - Running maximum filter
%   v_meansqtf      - Output power of a filter with white noise input
%   v_momfilt       - Generate running moments
%   v_resample      - Resamples a signal: identical to MATLAB resample but removes filter transients
%   v_schmitt       - Pass a signal through a v_schmitt trigger
%   v_sigalign      - Align a clean refeence with a noisy signal
%   v_teager        - Calculate the Teager energy waveform
%   v_windinfo      - Calculate window properties and figures of merit
%   v_windows       - Window function generation
%   v_zerocros      - Find interpolated zero crossings
%
% Information Theory
%   v_huffman       - Generate Huffman code
%   v_entropy       - Calculate v_entropy and conditional v_entropy
%
% Computer Vision
%   v_imagehomog    - Apply a homography transformation to an image with bilinear interpolation
%   v_polygonarea   - Calculate the area of a polygon
%   v_polygonwind   - Test if points are inside or outside a polygon
%   v_polygonxline  - Find where a line crosses a polygon
%   v_qrabs         - Absolute value of a real quaternion
%   v_qrdivide      - divide two real quaternions (or invert one)
%   v_qrdotdiv      - elmentwise division of two real quaternion arrays
%   v_qrdotmult     - elmentwise multiplication of two real quaternion arrays
%   v_qrmult        - multiply two real quaternion arrays
%   v_qrpermute     - permute the indices of a quaternion array
%   v_rectifyhomog  - Apply rectifing homographies to a set of cameras to make their optical axes parallel
%   v_rot--2--      - Convert between different representations of rotations
%   v_roteucode     - decode a string specifying a sequence of Euler angle rotations
%   v_rotqrmean     - Find the average of several v_rotation quaternions
%   v_rotqrvec      - Apply a quaternion rotation to an array of 3D vectors
%   v_sphrharm      - forward and inverse spherical harmonic transform using uniform, Gaussian
%                     or arbitrary inclination (elevation) grids and a uniform azimuth grid.
%   v_upolyhedron   - Calculate the vertex coordinates and other characteristics of a uniform polyhedron
%
% Printing and Display functions
%   v_axisenlarge   - Selectively enlarge figure axis for clarity
%   v_cblabel       - Add a label onto the colorbar
%   v_figbolden     - Make a figure bold and adjust colours for printing clearly
%   v_fig2emf       - Make a figure bold and save as a windows metafile
%   v_fig2pdf       - Make a figure bold and save as pdf, eps or ps
%   v_frac2bin      - Convert numbers to fixed-point binary strings
%   v_lambda2rgb    - convert wavelength to XYZ or RGB colour triplets
%   v_sprintsi      - Print a value with an SI multiplier
%   v_sprintcpx     - Print a complex number with real and imaginary parts
%   v_texthvc       - write text on a plot with specified alignment and colour
%   v_tilefigs      - Arrange all figures on the screen
%   v_colormap    - Set and plot colormap information
%   v_xticksi       - Label x-axis tick marks using SI multipliers
%   v_yticksi       - Label y-axis tick marks using SI multipliers
%   v_xyzticksi     - Helper function for v_xticksi and v_yticksi
%
% Voicebox Parameters and System Interface
%   v_hostipinfo    - Get information about the computer name and internet connections
%   v_regexfiles    - Recursively find files that match a regular expression pattern
%   v_unixwhich     - Search the WINDOWS system path for an executable program (like UNIX which)
%   v_voicebox      - Global installation-dependent parameters
%   v_winenvar      - Obtain WINDOWS environment variables
%   v_voicebox_update - Update matlab files in the current folder to include the v_ prefix where needed
%
% Utility Functions
%   v_atan2sc       - arctangent function that returns the sin and cos of the angle
%   v_besselratio   - calculate the Bessel function ratio: besseli(v+1,x)./besseli(v,x)
%   v_besselratioi  - calculate the inverse of v_besselratio [only for v=0]
%   v_bitsprec      - Rounds values to a precision of n bits
%   v_choosenk      - All choices of k elements out of 1:n without replacement
%   v_choosrnk      - All choices of k elements out of 1:n with replacement
%   v_dlyapsq       - Solve the discrete lyapunov equation
%   v_dualdiag      - Simultaneously diagonalise two hermitian matrices
%   v_finishat      - Estimate the finishing time of a long loop
%   v_fopenmkd      - Like FOPEN() but creates any missing directories/folders
%   v_gammalns      - Calculates log(gamma(x)) for signed real-valued x
%   v_horizdiff     - Estimate the horizontal difference between two functions of x
%   v_hypergeom1f1  - Confluent Hypergeometric function or Kummer's M function
%   v_logsum        - Calculates log(sum(exp(x))) without overflow/underflow
%   v_minspane      - calculate the minimum (or shortest) spanning tree
%   v_mintrace      - find a row permutation to minimize the trace of a matrix
%   v_m2htmlpwd     - Create HTML documentation of matlab routines in the current directory
%   v_nearnonz      - Replace each zero element with the nearest non-zero element
%   v_paramsetch    - Set a parameter structure and do valididty checks
%   v_permutes      - All n! permutations of 1:n
%   v_quadpeak      - Find quadratically-interpolated peak in a 2D array
%   v_rotation      - Generate v_rotation matrices
%   v_skew3d        - Generate 3x3 skew symmetric matrices
%   v_zerotrim      - Remove empty trailing rows and columns
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Copyright (c) 1998-2019 Mike Brookes
%   Version: $Id: Contents.m 10863 2018-09-21 15:39:23Z dmb $
%
%   VOICEBOX is a MATLAB toolbox for speech processing.
%   Home page: http://www.ee.ic.ac.uk/hp/staff/dmb/v_voicebox/v_voicebox.html
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

