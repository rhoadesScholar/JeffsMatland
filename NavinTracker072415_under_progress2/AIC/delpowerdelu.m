function y = delpowerdelu(x,u,beta)


%a = beta(1);
a=8;
%b = beta(2);
b=3000;
n = beta(3);


F = n*((a.^(1-u)-b.^(1-u))./(u-1));
G = 1./(a.^(1-u) - b.^(1-u));
H = ((u-1).*(b.^(1-u)*log(b) - a.^(1-u)*log(a)))./((a.^(1-u)-b.^(1-u)).^2);

% y = -sum(log(x)) + F.*(G-H);

y = abs(-sum(log(x)) + F.*(G-H));

