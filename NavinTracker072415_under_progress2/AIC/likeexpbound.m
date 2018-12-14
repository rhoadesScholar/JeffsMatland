function L = likeexpbound(x,k,beta)

a = beta(1);
b = beta(2);
n = beta(3);

L = n*log(k) - n*log(exp(-k*a) - exp(-k*b)) - k*sum(x);