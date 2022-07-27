function [x,io]=v_istftw(y,so,iop)
%V_ISTFTW converts a time-frequency domain signal back into the time domain with the inverse Short-time Fourier Transform [X,IO]=(Y,SO,IOP)
%
% For usage information, see v_stftw().
%
%  Inputs: y(f,k,...)	STFT (frame=f, freq=k)
%          so           The 'so' output from the call to v_stftw.
%                       If processing the signal in chunks, this should come from
%                       the v_stftw call corresponding to the most recent
%                       chunk.
%          iop          The 'io' output from the previous chunk's call to v_istftw.
%                       Omit for the first chunk or else use iop=[].
%
% Outputs: x(t,...)     Output signal
%          io           structure used in subsequent call as the iop argument to
%                       alllow processing in chunks. Omit this argument for
%                       the final chunk.
%
% Revision History
%    2022-04-10 First version
sy=size(y);
nf=sy(1);
nc=prod(sy(3:end));
% extract quantities from so structure
nh=so.nh;                       % frame hop
nt=so.nt;                       % length of transform
ws=nh*nt*so.wa;                 % synthesis window for perfect reconstruction
nw=length(ws);                  % length of window
ov=nw/nh;                       % overlap factor (always an integer)
if nargin>2 && isstruct(iop)
    md=iop.md;                 	% remaining samples to delete at the start
    xx=iop.xx;                 	% tail from previous call
    mx=iop.mx;                 	% cumulative number of output samples
else                            % first chunk if iop input is missing
    md=nh*(ov-1)*so.me;         % number of samples to delete at the start of the signal
    xx=zeros(0,nc,1);           % no tail from previous call
    mx=0;                       % cumulative number of output samples
end
if nf>0
    y=v_irfft(reshape(y,[sy(1:2) nc]),nt,2);    % inverse dft
    y=y(:,1:nw,:).*repmat(ws,nf,1,nc);          % truncate to nw and apply output window
    om=min(ov,nf);                              % number of occupied overlap sets
    if numel(xx)>0
        x=zeros(nw+nh*(nf-1),nc,min(ov,nf+1));	% space for output including saved data
        x(1:size(xx,1),:,end)=xx;               % insert output speech tail (already overlap-added)
    else
        x=zeros(nw+nh*(nf-1),nc,om);            % space for output
    end
    for i=1:om
        nm=nw*(1+floor((nf-i)/ov));             % number of samples in this column
        x(1+(i-1)*nh:nm+(i-1)*nh,:,i)=reshape(permute(y(i:ov:nf,:,:),[2 1 3]),nm,nc); % concatenate every ov'th frame
    end
    x=sum(x,3);                                 % perform the overlap-add
    if nargout>1
        t0=nw-nh-1;
        io.xx=x(end-t0:end,:);                  % save tail for overlap-adding next chunk
        x(end-t0:end,:)=[];                     % ... and remove it
    end
    if md>0
        mdd=min(md,size(x,1));
        x(1:mdd,:)=[];                          % delete initial samples
        md=md-mdd;
    end
    if so.mp==0 && size(x,1)>0 && mx+size(x,1)>so.mx
        x(end+so.mx-mx-size(x,1)+1:end,:)=[];   % delete unwanted samples at the end
    end
    if nargout>1
        io.md=md;                               % save number of sampes to delete at start
        io.mx=mx+size(x,1);                     % cumulative number of output samples
    end
    if nc>1
        x=reshape(x,[size(x,1) sy(3:end)]);
    end
else                                            % no input frames
    if nargout>1                                % io output required
        if nargin>2
            io=iop;                             % copy from input structure if available
        else
        end
    end
    if nc>1
        x=zeros([0 sy(3:end)]);
    else
        x=[];
    end
end





