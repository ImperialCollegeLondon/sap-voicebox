function k=v_besratinv0(r)
% V_BESRATINV0 Inverse function of the Modified Bessel Ratio I1(k)/I0(k)
%
%  Inputs: r    Input argument in range [0,1] (scalar or matrix)
%
% Outputs: k    Ouput satisfying r=v_besselratio(k,0)=I1(k)/I0(k) (same shape as r)
%
% This routine is a translation of VKAPPA(R) from [2] which is described in [1] and is the
% inverse of r=v_besselratio(k,0). The precision is 8 siginficant digits.
% If the angle q has a von Mises distribution  (a.k.a. Tikhonov distributon) with mean m and
% concentration parameter k, then E(exp(jq)) = I1(k)/I0(k) exp(jm) so k=besratinv0(abs(E(exp(jq)))).
%
% Refs:
%  [1]	G. W. Hill. Evaluation and inversion of the ratios of Modified Bessel functions, I1(x)/I0(x)
%       and I1.5(x)/I0.5(x). ACM Transactions on Mathematical Software, 7(2): 199–208, June 1981.
%  [2]	G. W. Hill. Algorithm 571: Statistics for von Mises’ and Fisher’s distributions of directions:
%       I1(x)/I0(x) and I1.5(x)/I0.5(x) and their inverses [s14].
%       ACM Transactions on Mathematical Software, 7(2): 233–238, June 1981. doi: 10.1145/355945.355953.
%
% Revision History:
% 2022/04/21    Original Version

k=zeros(size(r));       % space for outputs
m1=r<=0.85;             % Use different algorithms for r<=0.85 and r>0.85
a=r(m1);
if ~isempty(a)          % r<=0.85 => Use adjusted inverse Taylor Series
    y=2./(1-a);
    x=a.*a;
    s=(((a-5.6076).*a+5.0797).*a-4.6494).*y.*x-1;           % Eqn (7) from [1]
    s=((((s.*x+15).*x+60).*x/360+1).*x-2).*a./(x-1);        % Eqn before (7) from [1]
    m2=a>=0.642;
    b=a(m2);
    if ~isempty(b)
        z=y(m2);
        y=((0.00048.*z-0.1589).*z+0.744).*z-4.2932;         % Two Eqns after (9) in [1]; -dk/dr
        t=s(m2);
        t=(v_besselratio(t,0,9)-b).*y+t;                    % 1st Newton-Raphson Iteration for 0.642<r<=0.85
        m3=b>=0.75;
        c=b(m3);
        if ~isempty(c)
            u=t(m3);
            t(m3)=(v_besselratio(u,0,9)-c).*y(m3)+u;        % 2nd Newton Iteration-Raphson for 0.75<=r<=0.85
        end
        s(m2)=t;        % update the outputs for values needing Newton iterations
    end
    k(m1)=s;            % update the outputs for values 0<=r<=0.85
end
a=r(~m1);
if ~isempty(a) % r>0.85 => Use continued fraction approximation
    y=2./(1-a);
    x=zeros(size(a));
    m2=a>0.95;
    x(m2)=32./(120*a(m2)-131.5+y(m2));                      % Eqn (8b) from [1] for 0.95<=r<=1
    x(~m2)=(-2326*a(~m2)+4317.5526).*a(~m2)-2001.035224;    % Eqn (8c) from [1] for 0.85<r<0.95 (sign-corrected)
    s=(y+1+3./(y-5-12./(y-10-x)))*0.25;
    m2=a<0.95;
    b=a(m2);
    if ~isempty(b)
        z=y(m2);
        y=((0.00048.*z-0.1589).*z+0.744).*z-4.2932;         % Two Eqns after (9) in [1]; -dk/dr
        t=s(m2);
        t=(v_besselratio(t,0,9)-b).*y+t;                    % 1st Newton-Raphson Iteration for 0.85<r<=0.95
        m3=b<=0.875;
        c=b(m3);
        if ~isempty(c)
            u=t(m3);
            t(m3)=(v_besselratio(u,0,9)-c).*y(m3)+u;        % 2nd Newton-Raphson Iteration for 0.85<r<=0.875
        end
        s(m2)=t;        % update the outputs for values needing Newton iterations
    end
    k(~m1)=s;           % update the outputs for values 0.85<r<=1
end
if ~nargout && sum(isfinite(k))>1
    plot(r,k);
    ylabel('k');
    xlabel('r = I_1(k)/I_0(k)');
end


