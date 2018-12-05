function n=v_voicebox_update(fn,m)
%V_VOICEBOX_UPDATE update v_voicebox calls by prefixing with 'v_'
%  Inputs: fn   file or folder name to update [default: current folder]
%          m    'r' to search recursively through the folder tree
%               's' silent mode: do not print out statistics
%               'v' verbose: list files as they are updated
%               'V' extra verbose: list files even if not updated
%               'b' do not backup old file
%
% Outputs: n    number of files updated
%
% This routine is not all that smart. Words that match the function names
% included in the 'vbn' list below will be updated even if they are inside
% strings (except for the last string on a line). Local variables that
% share the name of a v_voicebox function will also be modified.
%
% vbp lists function names that may have an argument list
% vbn lists function names that may be called without arguments
vbp='activlev|activlevg|atan2sc|axisenlarge|bark2frq|berk2prob|besselratio|besselratioi|bitsprec|cblabel|ccwarpf|cent2frq|cep2pow|choosenk|choosrnk|convfft|correlogram|distchar|distchpf|disteusq|distisar|distispf|distitar|distitpf|ditherq|dlyapsq|dualdiag|dypsa|enframe|entropy|erb2frq|estnoiseg|estnoisem|ewgrpdel|fig2emf|fig2pdf|figbolden|filtbankm|filterbank|finishat|fopenmkd|frac2bin|fram2wav|frq2bark|frq2cent|frq2erb|frq2mel|frq2midi|fxpefac|fxrapt|gammabank|gammalns|gausprod|gaussmix|gaussmixd|gaussmixg|gaussmixk|gaussmixm|gaussmixp|gaussmixt|glotlf|glotros|gmmlpdf|histndim|hostipinfo|huffman|hypergeom1f1|imagehomog|importsii|irdct|irfft|kmeanhar|kmeanlbg|lambda2rgb|ldatrace|lin2pcma|lin2pcmu|lognmpdf|logsum|lpcaa2ao|lpcaa2dl|lpcaa2rf|lpcao2rf|lpcar2am|lpcar2cc|lpcar2db|lpcar2ff|lpcar2fm|lpcar2im|lpcar2ls|lpcar2pf|lpcar2pp|lpcar2ra|lpcar2rf|lpcar2rr|lpcar2zz|lpcauto|lpcbwexp|lpccc2ar|lpccc2cc|lpccc2db|lpccc2ff|lpccc2pf|lpcconv|lpccovar|lpccw2zz|lpcdb2pf|lpcdl2aa|lpcff2pf|lpcfq2zz|lpcifilt|lpcim2ar|lpcis2rf|lpcla2rf|lpclo2rf|lpcls2ar|lpcpf2cc|lpcpf2ff|lpcpf2rr|lpcpp2cw|lpcpp2pz|lpcpz2zz|lpcra2ar|lpcra2pf|lpcra2pp|lpcrand|lpcrf2aa|lpcrf2ao|lpcrf2ar|lpcrf2is|lpcrf2la|lpcrf2lo|lpcrf2rr|lpcrr2am|lpcrr2ar|lpcss2zz|lpcstable|lpczz2ar|lpczz2cc|lpczz2ss|m2htmlpwd|maxfilt|maxgauss|meansqtf|mel2frq|melbankm|melcepst|midi2frq|minspane|mintrace|modspect|momfilt|mos2pesq|nearnonz|normcdflog|overlapadd|paramsetch|pcma2lin|pcmu2lin|pdfmoments|peak2dquad|permutes|pesq2mos|phon2sone|polygonarea|polygonwind|polygonxline|potsband|pow2cep|prob2berk|psycdigit|psycest|psycestu|psychofunc|qrabs|qrdivide|qrdotdiv|qrdotmult|qrmult|qrpermute|quadpeak|randfilt|randiscr|randvec|rdct|readaif|readau|readcnx|readflac|readhtk|readsfs|readsph|readwav|rectifyhomog|regexfiles|rfft|rhartley|rnsubset|rotation|rotax2qr|roteu2qr|roteu2ro|rotmc2qc|rotmr2qr|rotpl2ro|rotqc2mc|rotqc2qr|rotqr2ax|rotqr2eu|rotqr2mr|rotqr2qc|rotqr2ro|rotqrmean|rotqrvec|rotro2eu|rotro2pl|rotro2qr|rsfft|sapisynth|schmitt|sigalign|skew3d|snrseg|sone2phon|soundspeed|specsub|specsubm|spendred|spgrambw|sphrharm|sprintcpx|sprintsi|ssubmmse|ssubmmsev|stdspectrum|stoi2prob|teager|texthvc|tilefigs|txalign|unixwhich|upolyhedron|usasi|vadsohn|voicebox|vonmisespdf|wavread|wavwrite|winenvar|writehtk|writewav|xticksi|xyzticksi|yticksi|zerocros|zerotrim|zoomfft';
if nargin<2 || isempty(m)
    m='';
end
lm=lower(m);
if nargin<1 || isempty(fn)
    fn='.'; % do files in current folder
end
if exist(fn,'dir')
    ff=v_regexfiles('\.m$',fn,char('n'+('r'-'n')*any(m=='r')));
elseif exist(fn,'file')
    ff={fn};
else
    error('first argument must be a file or folder name');
end
n=0;
for i=1:length(ff)
    fid=fopen(ff{i},'rt');
    s=fread(fid,'*char')';
    fclose(fid);
    t=regexprep(s,['\<(' vbp ')\>(?![^''\n]*''[^''\n]*\n)'],'v_$1'); % keyword unless followed by a single quote somewhere on the same line
    if numel(t)>numel(s)
        if ~any(m=='b')
            if ~movefile(ff{i},[ff{i} '.old'])
                error(sprintf('Cannot rename %s\n',ff{i}));
            end
        end
        fid=fopen(ff{i},'wt');
        if fid<0
            error(sprintf('Cannot write to %s\n',ff{i}));
        end
        fwrite(fid,t,'*char');
        fclose(fid);
        n=n+1;
        if any(lm=='v')
            nch=floor((length(t)-length(s))/2);
            if nch>1
                fprintf(1,'%d changes in %s\n',nch,ff{i});
            else
                fprintf(1,'%d change in %s\n',nch,ff{i});
            end
        end
    elseif any(m=='V')
        fprintf(1,'No changes in %s\n',ff{i});
    end
end
if ~any(m=='s')
    if any(lm=='v') && n>0
        fprintf(1,'===========\n');
    end
    if length(ff)>1
        fprintf(1,'%d of %d files updated\n',n,length(ff));
    else
        fprintf(1,'%d of %d file updated\n',n,length(ff));
    end
end
