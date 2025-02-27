% driverLinearPoisson1d1pSolver Driver for solving the linear one-dimensional 
% Poisson equation $-u''(x) = f(x,\mu)$ on $[a,b]$ depending on the real
% parameter $\mu$. Linear or quadratic finite elements can be used.

clc
clear variables
clear variables -global
close all

%
% User-defined settings
%

%mu = -0.8;  sigma = 0.2;  f = @(t) gaussian(t,mu,sigma);
%mu = 0.1;  f = @(t) mu * t .* ((-mu <= t) & (t <= mu));
%mu = 4;  f = @(t) (t-1).^mu;
%f = @(t) 50 * t .* cos(2*pi*t);
%mu = 0.25;  f = @(t) 2 * atan(mu * t/2);
%v = @(t) 1 + 0*t;
%mu = 0.5;  f = @(t) 2*(t >= mu) - 1*(t < mu);

%v = @(t) nu*(t < 0) + (nu + nu*t).*(t >= 0);
%v = @(t) 1*(t < nu) + 4*(t >= nu);
%v = @(t) gaussian(t,0,nu);
%v = @(t) 1 + (t+1).^nu;
%v = @(t) 1*(t < -0.5) + nu*(-0.5 <= t & t <= 0.5) + 1*(t > 0.5);
%f = @(t) - mu*(t < 0) + 2*mu*(t >= 0);
%f = @(t) -gaussian(t,-mu,0.8) + gaussian(t,mu,0.8);
%f = @(t) 2*(t >= mu) - 1*(t < mu);
%f = @(t) gaussian(t,mu,0.1);

%v = @(t) 1 + 0*t;  dv = @(t) 0*t;
%v = @(t) t.^2;  dv = @(t) 2*t;
%v = @(t) t.^(-2);  dv = @(t) -2*t.^(-3);
%v = @(t) abs(t);  dv = @(t) -(t < 0) + (t >= 0);
%f = @(t) pi*pi*sin(pi*t);

%a = 0;  b = 2*pi;
%v = @(t) exp(t);  dv = @(t) exp(t);
%f = @(x) exp(sin(x)) .* (sin(x) - cos(x).^2);

%a = 0;  b= 2*pi;
%v = @(t) log(t);  dv = @(t) 1./t;
%f = @(t) -(cos(t).^2)./(2+sin(t)) + log(2+sin(t)).*sin(t);

%a = -1;  b = 1;
%v = @(t) t.^(-2);  dv = @(t) -2*(t.^(-3));
%f = @(t) exp(t.^2) .* (2+4*t.^2);
%BCLt = 'D';  BCLv = exp(-1);
%BCRt = 'P';  BCRv = 0;

load(['../datasets/NonLinearPoisson1d3pSVD/NonLinearPoisson1d3p_FEP1_' ...
    'SVDunif_a-1.57_b1.57_D_D_mu11.00_mu23.00_nu11.00_nu23.00_xi1-0.50_xi20.50_' ...
    'K500_Nmu10_Nnu10_Nxi10_N1000_L25_Nte50.mat']);

a = -pi/2;  b = pi/2;  K = 500;
v = @(u) exp(u);  dv = @(u) exp(u);
%v = @(u) u.^2;  dv = @(u) 2*u;
%mu = 0.5;  nu = 1;  f = @(t) -gaussian(t,mu,0.1) + nu*gaussian(t,-mu,0.1);
%mu = 2;  f = @(t) 1;
%mu = 1;  nu = 1;  f = @(t) mu*mu*(1 + cos(mu*t).^2 + 2*sin(mu*t)) ./ (nu*(2+sin(mu*t)).^3);
%idx = 15;  mu = mu_te(idx);  nu = nu_te(idx);  
%f = @(t) nu*mu*mu*exp(nu*(2+sin(mu*t))).*(sin(mu*t) - nu*cos(mu*t).^2);
%f = @(t,mu,nu) nu.*nu.*mu.*mu.*(2+sin(mu.*t)).*(-2*nu.*cos(mu.*t).^2 + ...
%    2*nu.*sin(mu.*t) + nu.*sin(mu.*t).^2);

idx = 46;
mu = mu_te(idx);  nu = nu_te(idx);  k = xi_te(idx);
u = @(x) nu*exp(k*x).*(2+sin(mu*x));
du = @(x) nu*exp(k*x).*(k*(2+sin(mu*x)) + mu*cos(mu*x));
ddu = @(x) nu*exp(k*x).*(k*k*(2+sin(mu*x)) + k*mu*cos(mu*x) + ...
    mu*k*cos(mu*x) - mu*mu*sin(mu*x));
f = @(x) - exp(u(x)) .* (du(x).^2 + ddu(x));

BCLt = 'D';  bclv = @(mu,nu,k) nu.*exp(k*a).*(2+sin(mu*a));  BCLv = bclv(mu,nu,k);
BCRt = 'D';  bcrv = @(mu,nu,k) nu.*exp(k*b).*(2+sin(mu*b));  BCRv = bcrv(mu,nu,k);

%
% Run
%

% Solve
%[x,u1] = LinearPoisson1dFEP1(a, b, K, f, BCLt, BCLv, BCRt, BCRv);
%[x,u] = NonLinearPoisson1dFEP1Newton(a, b, K, v, dv, g, BCLt, BCLv, BCRt, BCRv);
[x,u_fs] = NonLinearPoisson1dFEP1(a, b, K, v, dv, f, BCLt, BCLv, BCRt, BCRv);
%[x,alpha] = NonLinearPoisson1dFEP1ReducedNewton(a, b, K, v, dv, g, BCLt, BCLv, ...
%    BCRt, BCRv, VL);
%[x,alpha_off,rhs_off] = NonLinearPoisson1dFEP1Reduced(a, b, K, v, dv, f, BCLt, BCLv, ...
%    BCRt, BCRv, VL, 'off');
[x,alpha_on,rhs_on] = NonLinearPoisson1dFEP1Reduced(a, b, K, v, dv, f, BCLt, BCLv, ...
    BCRt, BCRv, VL, 'on');
%alpha_ls = VL \ u;

% Plot
%figure;
hold on;
%plot(x,u_fs);
plot(x,u(x));
%plot(x,VL*alpha_off)
plot(x,VL*alpha_on)
title('Solution to Poisson equation')
xlabel('$x$')
ylabel('$u(x)$')
grid on
%axis equal
xlim([a b])
%legend('Full','Reduced', 'Reduced (Jacobian)','location','best')


