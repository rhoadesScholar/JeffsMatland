function [y, A, B] = two_state_irreversible_kinetics(t, t0, A0, eA, eB, k)

dt=t-t0;

A = A0*exp(-k*dt);

idx = find(t<t0);

A(idx) = A0;

B = 1 - A;

y = eA*A + eB*B;


return;
end

