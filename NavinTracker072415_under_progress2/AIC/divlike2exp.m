function oppL = divlike2exp(x,beta,beta_cond)

%DIVLIKE2EXP: This function calculates the divergence of the log-likelihood
%function (L) of the bounded double exponential over the three free parameters
% (b,k1,k2).
%Bounded double exponential = P/N.
% P = (b*k1*exp(-k1*x) + (1-b)*k2*exp(-k2*x));
% N = b*(exp(-k1*a) - exp(-k1*c)) + (1-b)*(exp(-k2*a) - exp(-k2*c));
% a = min(x)
% c = max(x)
% n = length(x)
% L = -n*log(N) + sum(log(P))
%
L = like2exp(x,beta,beta_cond);
oppL = -L;
% 
% b=beta(1);
% %b=.8;
% k1 = beta(2)^-1;
% %k2 = beta(1)^-1;
% %k1 = 64^-1;
% k2 = beta(3)^-1;
% %k2 = 456^-1;
% a = min(x);
% c = max(x);
% n = length(x);
% 
% P = b*k1*exp(-k1*x) + (1-b)*k2*exp(-k2*x);
% N = b*((exp(-k1*a)) - (exp(-k1*c))) + (1-b)*((exp(-k2*a)) - (exp(-k2*c)));
% 
% dPdb = k1*exp(-k1*x) - k2*exp(-k2*x);
% 
% dPdk1 = b*((exp(-k1*x))-(k1*x.*exp(-k1*x))); %%%%%%%the dot after x?
% 
% dPdk2 = (1-b)*(exp(-k2*x)-k2*x.*exp(-k2*x));
% 
% 
% dNdb = exp(-k1*a) - exp(-k1*c) - exp(-k2*a) + exp(-k2*c);
% 
% dNdk1 = b*((c*exp(-k1*c)) - (a*exp(-k1*a)));
% 
% dNdk2 = (1-b)*(c*exp(-k2*c) - a*exp(-k2*a));
% 
% dLdb = (-n/N)*dNdb + sum(dPdb./P);
% 
% dLdk1 = (-n/N)*dNdk1 + sum(dPdk1./P);
% 
% dLdk2 = (-n/N)*dNdk2 + sum(dPdk2./P);
% 
% divL = [dLdb dLdk1 dLdk2];
