function L = like2exp(x,beta,beta_cond)

b=beta(1);
%b=.8
k1 = beta(2)^-1;
k2 = beta(3)^-1;
%a = min(x);
a=beta_cond(1);

%c = max(x);
c = beta_cond(2);

if b > 0 && b < 1
% f1 = (b*k1*exp(-k1*(x-a)) + (1-b)*k2*exp(-k2*(x-a)));
f1 = (b*k1*exp(-k1*x) + (1-b)*k2*exp(-k2*x));
f2 = b*(exp(-k1*a) - exp(-k1*c)) + ((1-b)*(exp(-k2*a) - exp(-k2*c)));
f3 = f1/f2;
L = sum(log(f3));
else
    L = -10^10;
end