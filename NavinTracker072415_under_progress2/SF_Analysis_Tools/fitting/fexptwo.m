function y = fexptwo(t,x)
%MM: This function calculates the 2nd order equation:
% y = B*exp-k(1)*t + (1-B)*exp-k(2)*t
%%Andrew Gordus
%
%May 2009
%
%-------------------------------------------------------------------------%


y = log(t(1)*exp(-x/t(2)) + (1-t(1))*exp(-x/t(3)));
