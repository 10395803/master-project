% driverHeterogeneousViscosityLinearPoisson1d2pReductionAnalysis 
% Some post-processing for the reduction modeling applied to one-dimensional 
% linear Poisson equation $-(v(x,\nu) u'(x))' = f(x,\mu)$ on $[a,b]$ in the 
% unknown $u = u(x)$, where $\mu \in [\mu_1,\mu_2]$ and $\nu \in [\nu_1,\nu_2]$
% are real parameters. The ODE is then completed with Dirichlet, Neumann or
% Periodic bounday conditions, yielding a Boundary Value Problem (BVP). 
% The reduced basis has been obtained through, e.g., SVD and the reduced solution
% has been computed through the direct method, i.e. solving the reduced model.
% Note: for the moment (08-03-2017) we just consider a uniform sampling, i.e. 
% the values for $\mu$ and $\nu$ used to compute the snapshots are placed in 
% the nodes of a Cartesian grid on $[\mu_1,\mu_2] \times [\nu_1,\nu_2]$ with 
% uniform spacing along both directions.

clc
clear variables
clear variables -global
close all

%
% User-defined settings:
% a         left boundary of the domain
% b         right boundary of the domain
% K         number of grid points
% v         viscosity $v = v(x,\nu)$ as handle function
% f         force field $f = f(x,\mu)$ as handle function
% mu1       lower bound for $\mu$
% mu2       upper bound for $\mu$
% nu1       lower bound for $\nu$
% nu2       upper bound for $\nu$
% BCLt      kind of left boundary condition
%           - 'D': Dirichlet, 
%           - 'N': Neumann, 
%           - 'P': periodic
% BCLv      value of left boundary condition
% BCRt      kind of right boundary condition
%           - 'D': Dirichlet, 
%           - 'N': Neumann, 
%           - 'P': periodic
% BCLv      value of right boundary condition
% solver    solver
%           - 'FEP1': linear finite elements
%           - 'FEP2': quadratic finite elements
% reducer   method to compute the reduced basis
%           - 'SVD': Single Value Decomposition, i.e. Proper
%					 Orthogonal Decomposition (POD)
% root      path to folder where the datasets have been stored
% suffix    suffix for file names (if any)

a = -1;  b = 1; 

% Suffix ''
%v = @(t,nu) 1*(t < -0.5) + nu*(-0.5 <= t & t <= 0.3) + 0.25*(t > 0.3);  
%f = @(t,mu) gaussian(t,mu,0.1); 
%mu1 = -1;  mu2 = 1;  nu1 = 1;  nu2 = 3;  suffix = '';
% Suffix '_bis'
%v = @(t,nu) 1 + (t+1).^nu;  
%f = @(t,mu) - 1*(t < mu) + 2*(t >= mu);  
%mu1 = -1;  mu2 = 1;  nu1 = 1;  nu2 = 3;  suffix = '_bis';
% Suffix '_ter'
%v = @(t,nu) 2 + sin(nu*pi*t);
%f = @(t,mu) - 1*(t < mu) + 2*(t >= mu);  
%mu1 = -1;  mu2 = 1;  nu1 = 1;  nu2 = 3;  suffix = '_ter';
% Suffix '_quat'
v = @(t,nu) 1*(t < -0.5) + nu*(-0.5 <= t & t <= 0.5) + 1*(t > 0.5);  
f = @(t,mu) sin(mu*pi*(t+1));  
mu1 = 1;  mu2 = 3;  nu1 = 1; nu2 = 5;  suffix = '_quat';

BCLt = 'D';  BCLv = 0;
BCRt = 'D';  BCRv = 0;
solver = 'FEP1';
reducer = 'SVD';
root = '../datasets';

%% Plot full and reduced solution for three values of $\mu$ and $\nu$. 
% This is useful to have some insights into the dependency of
% the solution on the parameters and which is best between uniform and random
% sampling method.

%
% User defined settings:
% K         number of grid points
% Nmu	    number of sampled values for $\mu$
% Nnu		number of sampled values for $\nu$
% L         rank of reduced basis
% Nte       number of testing samples

K = 100;  Nmu = 10;  Nnu = 50;  L = 10;  Nte = 50;

%
% Run
%

% Set handle to solver
if strcmp(solver,'FEP1')
    solverFcn = @HeterogeneousViscosityLinearPoisson1dFEP1;
elseif strcmp(solver,'FEP2')
    solverFcn = @HeterogeneousViscosityLinearPoisson1dFEP2;
end

% Get total number of snapshots
N = Nmu*Nnu;

% Select three values for $\mu$ and $\nu$
mu = mu1 + (mu2 - mu1) * rand(3,1);
%mu = [-0.455759 -0.455759 -0.455759];  
nu = nu1 + (nu2 - nu1) * rand(3,1);
%nu = [0.03478 0.5 0.953269];  

% Evaluate viscosity for the just set values for $\nu$
vis = cell(3,1);
for i = 1:3
    vis{i} = @(t) v(t,nu(i));
end

% Evaluate forcing term for the just set values for $\mu$
g = cell(3,1);
for i = 1:3
    g{i} = @(t) f(t,mu(i));
end

% Load data and get full and reduced solutions for uniform sampling
filename = sprintf(['%s/HeterogeneousViscosityLinearPoisson1d2pSVD/' ...
    'HeterogeneousViscosityLinearPoisson1d2p_%s_%sunif_a%2.2f_b%2.2f_%s%2.2f_%s%2.2f_' ...
    'mu1%2.2f_mu2%2.2f_nu1%2.2f_nu2%2.2f_K%i_Nmu%i_Nnu%i_N%i_L%i_Nte%i%s.mat'], ...
    root, solver, reducer, a, b, BCLt, BCLv, BCRt, BCRv, mu1, mu2, nu1, nu2, ...
    K, Nmu, Nnu, N, L, Nte, suffix);
load(filename);
[x, u1, alpha1_unif] = solverFcn(a, b, K, vis{1}, g{1}, BCLt, BCLv, BCRt, BCRv, UL);
ur1_unif = UL * alpha1_unif;
[x, u2, alpha2_unif] = solverFcn(a, b, K, vis{2}, g{2}, BCLt, BCLv, BCRt, BCRv, UL);
ur2_unif = UL * alpha2_unif;
[x, u3, alpha3_unif] = solverFcn(a, b, K, vis{3}, g{3}, BCLt, BCLv, BCRt, BCRv, UL);
ur3_unif = UL * alpha3_unif;

%{
% Load data and get reduced solutions for random sampling
filename = sprintf(['%s/HeterogeneousViscosityLinearPoisson1d2pSVD/' ...
    'HeterogeneousViscosityLinearPoisson1d2p_%s_%srand_a%2.2f_b%2.2f_%s%2.2f_%s%2.2f_' ...
    'mu1%2.2f_mu2%2.2f_nu1%2.2f_nu2%2.2f_K%i_Nmu%i_Nnu%i_N%i_L%i_Nte%i.mat'], ...
    root, solver, reducer, a, b, BCLt, BCLv, BCRt, BCRv, mu1, mu2, nu1, nu2, ...
    K, N, N, N, L, Nte);
load(filename);
[x, alpha1_rand] = solverFcn(a, b, K, g{1}, BCLt, BCLv, BCRt, nu(1), UL);
ur1_rand = UL * alpha1_rand;
[x, alpha2_rand] = solverFcn(a, b, K, g{2}, BCLt, BCLv, BCRt, nu(2), UL);
ur2_rand = UL * alpha2_rand;
[x, alpha3_rand] = solverFcn(a, b, K, g{3}, BCLt, BCLv, BCRt, nu(3), UL);
ur3_rand = UL * alpha3_rand;

%
% Plot distribution of sampling values for $\mu$ and $\nu$ when drawn from 
% a uniform distribution
%

% Open a new window
figure(1);

% Plot distribution for $\mu$
bin = 20;
subplot(1,2,1);
hold off
histogram(mu_tr,bin);
hold on
plot([mu1 mu2], Nmu/bin * [1 1], 'g')
plot(mu, zeros(size(mu)), 'rx', 'Markersize', 10);
title('Distribution of $\mu$')
xlabel('$\mu$')
legend('Random sampling', 'Uniform sampling', 'Test values', 'location', 'best')
grid on
xlim([mu1 mu2])

% Plot distribution for $\nu$
bin = 20;
subplot(1,2,2);
hold off
histogram(nu_tr,bin);
hold on
plot([nu1 nu2], Nnu/bin * [1 1], 'g')
plot(nu, zeros(size(nu)), 'rx', 'Markersize', 10);
title('Distribution of $\nu$')
xlabel('$\nu$')
legend('Random sampling', 'Uniform sampling', 'Test values', 'location', 'best')
grid on
xlim([nu1 nu2])
%}

%
% Compare solutions for three values of $\mu$
%

% Open a new window
figure(2);
hold off

% Plot and set the legend
plot(x(1:1:end), u1(1:1:end), 'b')
hold on
plot(x(1:1:end), ur1_unif(1:1:end), 'b--', 'Linewidth', 2)
%plot(x(1:1:end), ur1_rand(1:1:end), 'b:', 'Linewidth', 2)
plot(x(1:1:end), u2(1:1:end), 'r')
plot(x(1:1:end), ur2_unif(1:1:end), 'r--', 'Linewidth', 2)
%plot(x(1:1:end), ur2_rand(1:1:end), 'r:', 'Linewidth', 2)
plot(x(1:1:end), u3(1:1:end), 'g')
plot(x(1:1:end), ur3_unif(1:1:end), 'g--', 'Linewidth', 2)
%plot(x(1:1:end), ur3_rand(1:1:end), 'g:', 'Linewidth', 2)

% Define plot settings
str_leg = sprintf(['Full and reduced solution to Poisson equation ($k = %i$, ' ...
    '$n_{\\mu} = %i$, $n_{\\nu} = %i$, $l = %i$)'], ...
    K, Nmu, Nnu, L);
title(str_leg)
xlabel('$x$')
ylabel('$u$')
legend(sprintf('$\\mu = %f$, $\\nu = %f$, full', mu(1), nu(1)), ...
    sprintf('$\\mu = %f$, $\\nu = %f$, reduced', mu(1), nu(1)), ...
    ... %sprintf('$\\mu = %f$, $\\nu = %f$, reduced (random)', mu(1), nu(1)), ...
    sprintf('$\\mu = %f$, $\\nu = %f$, full', mu(2), nu(2)), ...
    sprintf('$\\mu = %f$, $\\nu = %f$, reduced', mu(2), nu(2)), ...
    ... %sprintf('$\\mu = %f$, $\\nu = %f$, reduced (random)', mu(2), nu(2)), ...
    sprintf('$\\mu = %f$, $\\nu = %f$, full', mu(3), nu(3)), ...
    sprintf('$\\mu = %f$, $\\nu = %f$, reduced', mu(3), nu(3)), ...
    ... %sprintf('$\\mu = %f$, $\\nu = %f$, reduced (random)', mu(3), nu(3)), ...
    'location', 'best')
grid on

%% A complete sensitivity analysis on the sampling method, the number of
% snapshots and the rank of the reduced basis: plot the maximum and average 
% error versus number of basis functions for different number of snapshots.
% In particular, in each plot we fix the number of samples for $\nu$ and we
% compare the error curves for different numbers of sampled values of $\mu$

%
% User defined settings:
% K     number of grid points
% Nmu   number of sampled values for $\mu$ (no more than four values)
% Nnu   number of sampled values for $\nu$
% L     rank of reduced basis

K = 100;  Nmu = [5 15 25 50];  Nnu = [5 15 25 50];  L = 1:25;  Nte = 50;

%
% Run
% 

% Grid spacing
dx = (b-a) / (K-1);

for k = 1:length(Nnu)
    % Get total number of samples
    N = Nmu * Nnu(k);
    
    % Get error accumulated error for all values of L and for even distribution 
    % of snapshot values of $\mu$
    err_max_unif = zeros(length(L),length(Nmu));
    err_avg_unif = zeros(length(L),length(Nmu));
    for i = 1:length(L)
        for j = 1:length(Nmu)
            filename = sprintf(['%s/HeterogeneousViscosityLinearPoisson1d2pSVD/' ...
                'HeterogeneousViscosityLinearPoisson1d2p_%s_%sunif_a%2.2f_b%2.2f_' ...
                '%s%2.2f_%s%2.2f_mu1%2.2f_mu2%2.2f_nu1%2.2f_nu2%2.2f_K%i_' ...
                'Nmu%i_Nnu%i_N%i_L%i_Nte%i%s.mat'], ...
                root, solver, reducer, a, b, BCLt, BCLv, BCRt, BCRv, mu1, mu2, ...
                nu1, nu2, K, Nmu(j), Nnu(k), N(j), L(i), Nte, suffix);
            load(filename);
            err_max_unif(i,j) = sqrt(dx)*max(err_svd_abs);
            err_avg_unif(i,j) = sqrt(dx)*sum(err_svd_abs)/Nte;
        end
    end
    
    %{
    % Get error accumulated error for all values of L and for random distribution 
    % of shapshot values for $\mu$
    err_rand = zeros(length(L),length(Nmu));
    for i = 1:length(L)
        for j = 1:length(Nmu)
            filename = sprintf(['%s/HeterogeneousViscosityLinearPoisson1d2pSVD/' ...
                HeterogeneousViscosityLinearPoisson1s2p_%s_%srand_a%2.2f_b%2.2f_' ...
                '%s%2.2f_%s%2.2f_mu1%2.2f_mu2%2.2f_nu1%2.2f_nu2%2.2f_K%i_' ...
                'Nmu%i_Nnu%i_N%i_L%i_Nte%i.mat'], ...
                root, solver, reducer, a, b, BCLt, BCLv, BCRt, BCRv, mu1, mu2, ...
                nu1, nu2, K, N(j), N(j), N(j), L(i), Nte);
            load(filename);
            err_rand(i,j) = sum(err_svd_abs);
        end
    end
    %}
    
    %
    % Maximum error
    %
    
    % Open a new window
    figure(2+2*k-1);
    hold off

    % Plot data and dynamically update legend
    marker_unif = {'bo-', 'rs-', 'g^-', 'mv-'};
    %marker_rand = {'bo:', 'rs:', 'g^:', 'mv:'};
    str_leg = 'legend(''location'', ''best''';
    for j = 1:length(Nmu)
        semilogy(L', err_max_unif(:,j), marker_unif{j});
        hold on
        %semilogy(L', err_rand(:,j), marker_rand{j});
        str_unif = sprintf('''$n_{\\mu} = %i$''', Nmu(j));
        %str_rand = sprintf('''$n_{\\mu} = %i$, random''', Nmu(j));
        str_leg = strcat(str_leg, ', ', str_unif);
        %str_leg = sprintf('%s, %s, %s', str_leg, str_unif, str_rand);
    end
    semilogy(L,s,'ko--')
    str_leg = sprintf('%s, ''Singular values'')', str_leg);
    eval(str_leg)

    % Define plot settings
    str_leg = sprintf('Maximum error in $L^2_h$-norm on test data set ($k = %i$, $n_{\\nu} = %i$, $n_{te} = %i$)', ...
        K, Nnu(k), Nte);
    title(str_leg)
    xlabel('$l$')
    ylabel('$||u - u^l||_{L^2_h}$')
    grid on    
    xlim([min(L)-1 max(L)+1])
    
    %
    % Average error
    %
    
    % Open a new window
    figure(2+2*k);
    hold off

    % Plot data and dynamically update legend
    marker_unif = {'bo-', 'rs-', 'g^-', 'mv-'};
    %marker_rand = {'bo:', 'rs:', 'g^:', 'mv:'};
    str_leg = 'legend(''location'', ''best''';
    for j = 1:length(Nmu)
        semilogy(L', err_avg_unif(:,j), marker_unif{j});
        hold on
        %semilogy(L', err_rand(:,j), marker_rand{j});
        str_unif = sprintf('''$n_{\\mu} = %i$''', Nmu(j));
        %str_rand = sprintf('''$n_{\\mu} = %i$, random''', Nmu(j));
        str_leg = strcat(str_leg, ', ', str_unif);
        %str_leg = sprintf('%s, %s, %s', str_leg, str_unif, str_rand);
    end
    semilogy(L,s,'ko--')
    str_leg = sprintf('%s, ''Singular values'')', str_leg);
    eval(str_leg)
    
    % Define plot settings
    str_leg = sprintf('Average error in $L^2_h$-norm on test data set ($k = %i$, $n_{\\nu} = %i$, $n_{te} = %i$)', ...
        K, Nnu(k), Nte);
    title(str_leg)
    xlabel('$l$')
    ylabel('$||u - u^l||_{L^2_h}$')
    grid on    
    xlim([min(L)-1 max(L)+1])
end

%% A complete sensitivity analysis on the sampling method, the number of
% snapshots and the rank of the reduced basis: plot the maximum and average
% error versus number of basis functions for different number of snapshots.
% In particular, in each plot we fix the number of samples for $\mu$ and we
% compare the error curves for different numbers of sampled values of $\nu$

%
% User defined settings:
% K     number of grid points
% Nmu   number of sampled values for $\mu$ 
% Nnu   number of sampled values for $\nu$ (no more than four values)
% L     rank of reduced basis

K = 100;  Nmu = [5 15 25 50];  Nnu = [5 10 15 25];  L = 1:25;  Nte = 50;

%
% Run
% 

for k = 1:length(Nmu)
    % Get total number of samples
    N = Nnu * Nmu(k);
    
    % Get error accumulated error for all values of L and for even distribution 
    % of snapshot values of $\mu$
    err_max_unif = zeros(length(L),length(Nnu));
    err_avg_unif = zeros(length(L),length(Nnu));
    for i = 1:length(L)
        for j = 1:length(Nnu)
            filename = sprintf(['%s/HeterogeneousViscosityLinearPoisson1d2pSVD/' ...
                'HeterogeneousViscosityLinearPoisson1d2p_%s_%sunif_a%2.2f_b%2.2f_' ...
                '%s%2.2f_%s%2.2f_mu1%2.2f_mu2%2.2f_nu1%2.2f_nu2%2.2f_K%i_' ...
                'Nmu%i_Nnu%i_N%i_L%i_Nte%i%s.mat'], ...
                root, solver, reducer, a, b, BCLt, BCLv, BCRt, BCRv, mu1, mu2, ...
                nu1, nu2, K, Nmu(k), Nnu(j), N(j), L(i), Nte, suffix);
            load(filename);
            err_max_unif(i,j) = max(err_svd_abs);
            err_avg_unif(i,j) = sum(err_svd_abs)/Nte;
        end
    end
    
    %{
    % Get error accumulated error for all values of L and for random distribution 
    % of shapshot values for $\mu$
    err_rand = zeros(length(L),length(Nnu));
    for i = 1:length(L)
        for j = 1:length(Nnu)
            filename = sprintf(['%s/HeterogeneousViscosityLinearPoisson1d2pSVD/' ...
                'HeterogeneousViscosityLinearPoisson1d2p_%s_%srand_a%2.2f_b%2.2f_' ...
                '%s%2.2f_%s%2.2f_mu1%2.2f_mu2%2.2f_nu1%2.2f_nu2%2.2f_K%i_' ...
                'Nmu%i_Nnu%i_N%i_L%i_Nte%i.mat'], ...
                root, solver, reducer, a, b, BCLt, BCLv, BCRt, BCRv, mu1, mu2, ...
                nu1, nu2, K, N(j), N(j), N(j), L(i), Nte);
            load(filename);
            err_rand(i,j) = sum(err_svd_abs);
        end
    end
    %}
    
    %
    % Maximum error
    %
    
    % Open a new window
    figure(10+2*k-1);
    hold off

    % Plot data and dynamically update legend
    marker_unif = {'bo-', 'rs-', 'g^-', 'mv-'};
    %marker_rand = {'bo:', 'rs:', 'g^:', 'mv:'};
    str_leg = 'legend(''location'', ''best''';
    for j = 1:length(Nnu)
        semilogy(L', err_max_unif(:,j), marker_unif{j});
        hold on
        %semilogy(L', err_rand(:,j), marker_rand{j});
        str_unif = sprintf('''$n_{\\nu} = %i$''', Nnu(j));
        %str_rand = sprintf('''$n_{\\nu} = %i$, random''', Nnu(j));
        str_leg = strcat(str_leg, ', ', str_unif);
        %str_leg = sprintf('%s, %s, %s', str_leg, str_unif, str_rand);
    end
    semilogy(L,s,'ko--')
    str_leg = sprintf('%s, ''Singular values'')', str_leg);
    eval(str_leg)

    % Define plot settings
    str_leg = sprintf('Maximum error $\\epsilon_{max}$ ($k = %i$, $n_{\\mu} = %i$, $n_{te} = %i$)', ...
        K, Nmu(k), Nte);
    title(str_leg)
    xlabel('$l$')
    ylabel('$\epsilon_{max}$')
    grid on    
    xlim([min(L)-1 max(L)+1])
    
    %
    % Average error
    %
    
    % Open a new window
    figure(10+2*k);
    hold off

    % Plot data and dynamically update legend
    marker_unif = {'bo-', 'rs-', 'g^-', 'mv-'};
    %marker_rand = {'bo:', 'rs:', 'g^:', 'mv:'};
    str_leg = 'legend(''location'', ''best''';
    for j = 1:length(Nnu)
        semilogy(L', err_avg_unif(:,j), marker_unif{j});
        hold on
        %semilogy(L', err_rand(:,j), marker_rand{j});
        str_unif = sprintf('''$n_{\\nu} = %i$''', Nnu(j));
        %str_rand = sprintf('''$n_{\\nu} = %i$, random''', Nnu(j));
        str_leg = strcat(str_leg, ', ', str_unif);
        %str_leg = sprintf('%s, %s, %s', str_leg, str_unif, str_rand);
    end
    semilogy(L,s,'ko--')
    str_leg = sprintf('%s, ''Singular values'')', str_leg);
    eval(str_leg)

    % Define plot settings
    str_leg = sprintf('Average error $\\epsilon_{avg}$ ($k = %i$, $n_{\\mu} = %i$, $n_{te} = %i$)', ...
        K, Nmu(k), Nte);
    title(str_leg)
    xlabel('$l$')
    ylabel('$\epsilon_{avg}$')
    grid on    
    xlim([min(L)-1 max(L)+1])
end

%% Fix the number of samples for both $\mu$ and $\nu$ and the rank of the basis
% (the optimal values should have been determined within the previous
% sections), then plot pointwise error

%
% User defined settings:
% K         number of grid points
% Nmu       number of sampled values for $\mu$ 
% Nnu       number of sampled values for $\nu$
% L         rank of reduced basis
% sampler   how the values for $\mu$ and $\nu$ should have been sampled for
%           computing the snapshots:
%           - 'unif': samples form a Cartesian grid
%           - 'rand': drawn from random uniform distribution
% Nte       number of testing samples

K = 100;  Nmu = 50;  Nnu = 15;  L = 12;  sampler = 'unif';  Nte = 50;

%
% Run
%

% Determine total number of training patterns
if strcmp(sampler,'unif')
    N = Nmu*Nnu;
elseif strcmp(sampler,'rand')
    N = Nmu*Nnu;  Nmu = N;  Nnu = N;
end

% Load data
filename = sprintf(['%s/HeterogeneousViscosityLinearPoisson1d2pSVD/' ...
    'HeterogeneousViscosityLinearPoisson1d2p_%s_%sunif_a%2.2f_b%2.2f_' ...
    '%s%2.2f_%s%2.2f_mu1%2.2f_mu2%2.2f_nu1%2.2f_nu2%2.2f_K%i_' ...
    'Nmu%i_Nnu%i_N%i_L%i_Nte%i%s.mat'], ...
    root, solver, reducer, a, b, BCLt, BCLv, BCRt, BCRv, mu1, mu2, ...
    nu1, nu2, K, Nmu, Nnu, N, L, Nte, suffix);
load(filename);

% Generate structured data out of scatter data (test samples randomly picked)
mu_g = linspace(mu1,mu2,1000);  nu_g = linspace(nu1,nu2,1000);
[MU,NU] = meshgrid(mu_g,nu_g);
Ea = griddata(mu_te, nu_te, err_svd_abs, MU, NU);
Er = griddata(mu_te, nu_te, err_svd_rel, MU, NU);

% Plot absolute value
figure(19);
contourf(MU,NU,Ea, 'LineStyle','none')
colorbar
str = sprintf('Absolute error ($k = %i$, $n_{\\mu} = %i$, $n_{\\nu} = %i$, $l = %i$)', ...
    K, Nmu, Nnu, L);
title(str);
xlabel('$\mu$')
ylabel('$\nu$')

% Plot absolute value
figure(20);
contourf(MU,NU,Er, 'LineStyle','none')
colorbar
str = sprintf('Relative error ($k = %i$, $n_{\\mu} = %i$, $n_{\\nu} = %i$, $l = %i$)', ...
    K, Nmu, Nnu, L);
title(str);
xlabel('$\mu$')
ylabel('$\nu$')

%% Plot basis functions

%
% User defined settings:
% K         number of grid points
% Nmu       number of sampled values for $\mu$
% Nnu       number of sampled values for $\nu$
% L         rank of reduced basis
% Nte       number of testing samples
% sampler   how the values for $\mu$ and $\nu$ should have been sampled for
%           computing the snapshots:
%           - 'unif': samples form a Cartesian grid
%           - 'rand': drawn from random uniform distribution
% Nte       number of testing samples

K = 100;  Nmu = 50;  Nnu = 15;  L = 12;  sampler = 'unif';  Nte = 50;

%
% Run
%  

% Load data
N = Nmu*Nnu;
filename = sprintf(['%s/HeterogeneousViscosityLinearPoisson1d2pSVD/' ...
    'HeterogeneousViscosityLinearPoisson1d2p_%s_%s%s_a%2.2f_b%2.2f_%s%2.2f_' ...
    '%s%2.2f_mu1%2.2f_mu2%2.2f_nu1%2.2f_nu2%2.2f_K%i_Nmu%i_Nnu%i_N%i_L%i_Nte%i%s.mat'], ...
    root, solver, reducer, sampler, a, b, BCLt, BCLv, BCRt, BCRv, mu1, mu2, ...
    nu1, nu2, K, Nmu, Nnu, N, L, Nte, suffix);
load(filename);

% Plot basis functions
for l = 1:L
    figure(20+l);
    plot(x,UL(:,l),'b')
    title(sprintf('Basis function $\\psi^{%i}$',l))
    xlabel('$x$')
    ylabel(sprintf('$\\psi^{%i}$',l));
    grid on
end