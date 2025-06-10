function [i,f]=v_interval(x,y,m)
%V_INTERVAL Classify X values into a set of contiguous intervals with boundaries from Y [I,F]=(X,Y,M)
%
% Usage:    x=[1.6 2 3.8 0 6.5];    % test values (not necessarily monotonic)
%           y=[1 2 3 5 6];          % define boundaries of four unequal intervals (y must be increasing)
%       [i,f]=v_interval(x,y);      % classify into intervals using default options 'eE'
%                                   %    i=[1 2 3 1 4] and f=[0.6 0 0.4 -1 1.5]
%
%  Inputs:  x(nx)   Vector of test values
%           y(ny)   Vector of monotonically increasing interval boundaries: interval i is [ y(i) , y(i+1) )
%           m(nx)   string of mode options
%                   if x(j)<y(1)
%                       'e' extrapolate: set i(j)=1 and f(j)<0 [default]
%                       'c' clip: set i(j)=1 and f(j)=0
%                       'n' NaN: set i(j)=f(j)=NaN
%                       'z' zero: set i(j)=0 and f(j)<0
%                   if x(j)>=y(ny)
%                       'E' set i(j)=ny-1 and f(j)>1 [default]
%                       'C' set i(j)=ny-1 and f(j)=1
%                       'N' set i(j)=f(j)=NaNj
%                       'Z' set i(j)=ny and f(j)>1
%
% Outputs:  i(nx)   Input x(j) lies in the interval  [y(i(j)),y(i(j)+1)]
%           f(nx)   f(j)=(x(j)-y(i(j)))/(y(i(j)+1))-y(i(j))) is the fractional position of x(j) within the interval.
%                   Note that f(j) lies in the range [0,1) provided that y(1) <= x(j) < y(ny)
%
if nargin<3
    m='';
end
[d,e,r]=v_sort([x(:)']);        % find order of x values
[d,e,j]=v_sort([y(:)' x(:)']);
ny=numel(y);
k=j(ny+1:end)-r;                % next lower element of y for each x (in range [0,ny])
i=max(min(k,ny-1),1);           % force to lie in range [1,ny-1]
f=(x-y(i))./(y(i+1)-y(i));      % fractional position within the interval
klo=k<1;
if any(klo)
    if any(m=='c')
        f(klo)=0;
    elseif any(m=='n')
        i(klo)=NaN;
        f(klo)=NaN;
    elseif any(m=='z')
        i(klo)=0;
    end
end
khi=k>=ny;
if any(khi)
    if any(m=='C')
        f(khi)=1;
    elseif any(m=='N')
        i(khi)=NaN;
        f(khi)=NaN;
    elseif any(m=='Z')
        i(khi)=ny;
    end
end
i=reshape(i,size(x));           % force shape to match x
f=reshape(f,size(x));           % force shape to match x