function v_imagescnu(x,y,v,db)
% Plot image with non-uniform rectangular patches
%
%  Usage:   v_imagescnu(log10(1:2:9),pow2(1:4),rand(5,3));
%
%  Inputs:  x(nx) or x(nx+1)    x-axis patch centres or boundaries
%           y(ny) or y(ny+1)    y-axis patch centres or boundaries
%           v(nx,ny)            Values to plot
%           db                  dB range to plot relative to peak (+ve for mag, -ve for power, 0 [default] for linear)
%
if nargin<4
    db=0;               % default to linear scale
end
[nx,ny]=size(v);
x=x(:)';                % make x a row vector
y=y(:)';                % make y a row vector
if length(x)==nx
    if nx==1
        x=-0.5:0.5;
    else
        x=0.5*[3*x(1)-x(2) x(1:nx-1)+x(2:nx) 3*x(nx)-x(nx-1)];
    end
elseif length(x)~=nx+1
    error('size(v)=(%d,%d) so length(x) must be %d or %d',nx,ny,nx,nx+1);
end
if any(x(2:nx+1)-x(1:nx)<=0)
    error('x values must be monotonically increasing');
end
if length(y)==ny
    if ny==1
        y=-0.5:0.5;
    else
        y=0.5*[3*y(1)-y(2) y(1:ny-1)+y(2:ny) 3*y(ny)-y(ny-1)];
    end
elseif length(y)~=ny+1
    error('size(v)=(%d,%d) so length(y) must be %d or %d',nx,ny,ny,ny+1);
end
if any(y(2:ny+1)-y(1:ny)<=0)
    error('y values must be monotonically increasing');
end
if db~=0
    v=abs(v);
    dbmul=(db>0)*10+10;
    v=dbmul*log10(max(v,max(v(:))*10^(-abs(db)/dbmul)));
end
ix=reshape(repmat((1:nx)',1,ny),1,nx*ny);
iy=reshape(repmat(1:ny,nx,1),1,nx*ny);
patx=[x(ix);x(ix+1);x(ix+1);x(ix)];
paty=[y(iy);y(iy);y(iy+1);y(iy+1)];
clf;
patch(patx,paty,v(:),'EdgeColor', 'none');
axis([x(1) x(nx+1) y(1) y(ny+1)]);
