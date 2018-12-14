function [y, A, B, C] = three_state_irreversible_kinetics(t, t0, A0, B0, C0, eA, eB, eC, k1, k2)

constraint=0;


if(A0<0)
    constraint = constraint + (A0)^2;
end

if(B0<0)
    constraint = constraint + (B0)^2;
end

if(C0<0)
    constraint = constraint + (C0)^2;
end

if(abs((A0+B0+C0)-1) > 1e-4)
    constraint = constraint + (A0)^2+ (B0)^2 + (C0)^2;
end

if(eA<0)
    constraint = constraint + (eA)^2;
end

if(eB<0)
    constraint = constraint + (eB)^2;
end

if(eC<0)
    constraint = constraint + (eC)^2;
end

if(k1 < 0)
    constraint = constraint + (k1)^2;
end

if(k2 < 0)
    constraint = constraint + (k2)^2;
end

if(constraint > 0)
    y = zeros(1,length(t)) + constraint;
    A=y; B=y; C=y;
    return;
end

dt = t - t0;

A = A0*exp(-k1*dt);

B = B0*exp(-k2*dt) + k1*A0*(exp(-k1*dt) - exp(-k2*dt) )/(k2-k1);

idx=find(t<t0);
A(idx) = A0;
B(idx) = B0;

C = 1 - (A + B);

y = eA*A + eB*B + eC*C ; %  + rand(1,length(t))/2;

return;
end

