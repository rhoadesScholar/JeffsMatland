function [y, A, B] = two_state_reversible_kinetics(t, t0, A0, eA, eB, kf, kr)

sum_kf_kr = kf + kr;

A = (kr - (kr -A0*sum_kf_kr)*exp(-sum_kf_kr*(t-t0)))/sum_kf_kr;

B = 1 - A;

y = eA*A + eB*B;

return;
end

