function L = likepowerbound(x,u,beta)

%powerbound is loglikelihood function for bounded powerlaw.

a = beta(1);
b = beta(2);
n = beta(3);

L = n*log((u-1)/(a^(1-u) - b^(1-u))) - u*sum(log(x));