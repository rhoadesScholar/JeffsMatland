function y = delexpdelk(x,k,beta)

a = beta(1);
%a=1;
b = beta(2);
%b=1000;
n = beta(3);

% y = n./k - n*((b*exp(-k*b) - a*exp(-k*a))./(exp(-k*a)-exp(-k*b))) - sum(x);

y = abs(n./k - n*((b*exp(-k*b) - a*exp(-k*a))./(exp(-k*a)-exp(-k*b)))...
    - sum(x));