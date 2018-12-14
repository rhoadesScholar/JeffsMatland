function tau = t_crit(A,a,B,b)
% tau = t_crit(A,a,B,b)

tau = (log((A/a)/(B/b)))/(1/a - 1/b);

return;

end
