function [AIC w L values dists] = aic(x,a,c)

% f1(x) = Cx^-u, x>=a, i.e. powerlaw
%f2(x) = k*exp(-k*(x-a)), x>=a, i.e. exponential
%f3(x) =(b*k1*exp(-k1*(x-a)) + (1-b)*k2*exp(-k2*(x-a))); i.e.2 exp
%f4(x) = gaussian
%f5(x) = lognorm
%NOTE: beta0 should be: 1 = fraction, 2 & 3 should be tau.
if nargin ==1
    beta0 = 0;
end

n = length(x);
%a = min(x);
%c = max(x);
values = zeros(3,2);
dists = ['pwrlaw';'expntl';'dblexp';'gaussd';'lgnorm'];

%f1(x) = bounded power law

beta = [a c n];
u2 = fminsearch(@(u) delpowerdelu(x,u,beta),2);
L(1) = likepowerbound(x,u2,beta);
param(1) = 1;
values(1) = u2;

%f2(x) = bounded exponent

beta = [a c n];
k2 = fminsearch(@(k) delexpdelk(x,k,beta),2);
L(2) = likeexpbound(x,k2,beta);
param(2) = 1;
values(2,1) = k2^-1;

%f3(x) =(b*k1*exp(-k1*(x-a)) + (1-b)*k2*exp(-k2*(x-a))); i.e.2 exp
% beta = ratedouble(x,beta0);
beta0 = [.5 25 125];
beta_dbl = fminsearch(@(beta2) divlike2exp(x,beta2,beta),beta0);
L(3) = like2exp(x,beta_dbl,beta);
param(3) = 3;
values(3,1:3) = [beta_dbl(1) beta_dbl(2) beta_dbl(3)];


% f4(x) = (1/sqrt(2*pi*sigma^2)).*exp(-((x-mu).^2)./(2*sigma^2)) i.e. gauss
% mu = sum(x)./n;
% sigma = sqrt(sum((x-mu).^2)./n);
% L(4) = -n*log(2*pi*sigma^2)./2 - sum((x-mu).^2)./(2*sigma^2);
% param(4) = 2;
% values(4,1:2) = [mu sigma];

% f5(x) = (1/sqrt(2*pi*sigma^2)).*exp(-((log(x)-mu).^2)./(2*sigma^2)) i.e.
% lognorm
% mu = sum(log(x))./n;
% sigma = sqrt(sum((log(x)-mu).^2)./n);
% L(5) = -n*log(2*pi*sigma^2)./2 - sum((log(x)-mu).^2)./(2*sigma^2) - sum(log(x));
% param(5) = 2;
% values(5,1:2) = [mu sigma];



AIC = -2*L +2*param;

del = AIC - ones(1,length(AIC))*min(AIC);

wsum = sum(exp(-del/2));

w = exp(-del/2)/wsum;


% %f1(x) = Cx^-u, x>=a, i.e. powerlaw
% u = 1-n/(n*log(a) - sum(log(x)));
% L(1) = n*log(u-1) + n*(u-1)*log(a) - u*sum(log(x));
% param(1) = 1;
% values(1,1) = u;
% 
% %f2(x) = kexp(-k*(x-a)), x>=a, i.e. exponential
% k = ((sum(x)/n) - a)^-1;
% L(2) = n*log(k) + n*k*a - k*sum(x);
% param(2) = 1;
% values(2,1) = k;


% 
% 
%f3(x) =(b*k1*exp(-k1*(x-a)) + (1-b)*k2*exp(-k2*(x-a))); i.e.2 exp

% beta2(2) = beta2(2)^-1;
% beta2(3) = beta2(3)^-1;
% C = zeros(2,length(x));
% C(1,1) = min(x);
% C(2,:) = x;
% 
% beta = steepest(@delexp2delbeta,@Jdelexp2delbeta,beta2,C,100);

