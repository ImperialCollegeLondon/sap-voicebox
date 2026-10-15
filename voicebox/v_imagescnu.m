function v_imagescnu(x,y,v,db)
% Plot image with non-uniform rectangular patches
%
%  Usage:   (1) v_imagescnu(log10(1:2:9),(1:3).^2,reshape(1:15,3,5));   % log x, quadratic y
%               colorbar; axis xy;                                      % add colorbar + invert y-axis
%
%  Inputs:  x(nx) or x(nx+1)    x-axis patch centres or boundaries
%           y(ny) or y(ny+1)    y-axis patch centres or boundaries
%           v(ny,nx)            Values to plot (if db is non-zero then abs(v) will be displayed)
%           db                  dB range to plot relative to peak (+ve for mag, -ve for power, 0 [default] for linear scale)
%
if nargin<4
    db=0;                                   % default to linear scale
end
[ny,nx]=size(v);
x=x(:)';                                    % make x a row vector
y=y(:)';                                    % make y a row vector
if length(x)==nx                            % need to convert from column-centres to column-edges
    if nx==1                                % if only one column ...
        x=x-0.5:x+0.5;                      % ... make it of unit width
    else
        x=0.5*[3*x(1)-x(2) x(1:nx-1)+x(2:nx) 3*x(nx)-x(nx-1)];  % place column-edges midway between centres
    end
elseif length(x)~=nx+1                      % error unless length(x) = either nx or nx+1
    error('size(v)=(%d,%d) so length(x) must be %d or %d',ny,nx,nx,nx+1);
end
if any(x(2:nx+1)-x(1:nx)<=0)                % check that x is monotonically increasing
    error('x values must be monotonically increasing');
end
if length(y)==ny                            % need to convert from row-centres to row-edges
    if ny==1                                % if only one row ...
        y=y-0.5:y+0.5;                      % ... make it of unit width
    else
        y=0.5*[3*y(1)-y(2) y(1:ny-1)+y(2:ny) 3*y(ny)-y(ny-1)];  % place row-edges midway between centres
    end
elseif length(y)~=ny+1                      % error unless length(y) = either ny or ny+1
    error('size(v)=(%d,%d) so length(y) must be %d or %d',ny,nx,ny,ny+1);
end
if any(y(2:ny+1)-y(1:ny)<=0)                % check that y is monotonically increasing
    error('y values must be monotonically increasing');
end
if db~=0                                    % db nonzero means a log colour scale
    v=abs(v); 
    dbmul=(db>0)*10+10;                     % db multiplier is 10 for power (db<0) or 20 for magnitude (db>0)
    v=dbmul*log10(max(v,max(v(:))*10^(-abs(db)/dbmul)));    % clip data to a range of abs(db)
end
ix=reshape(repmat(1:nx,ny,1),1,nx*ny);      % x index of each patch (column-major order)
iy=reshape(repmat((1:ny),1,nx),1,nx*ny);    % y index of each patch (column-major order)
patx=[x(ix);x(ix+1);x(ix+1);x(ix)];         % x-coordinates of patch corners in order low-left, low-right, high-right, high-left(one patch per column)
paty=[y(iy);y(iy);y(iy+1);y(iy+1)];         % y-coordinates of patch corners in order low-left, low-right, high-right, high-left(one patch per column)
if ~ishold
    cla;                                    % clear the axes unless hold is turned on
end
patch(patx,paty,v(:),'EdgeColor', 'none');  % plot the patches
axis([x(1) x(nx+1) y(1) y(ny+1)]);          % define the axis limits
axis ij;                                    % orient image to conform to imagesc()
