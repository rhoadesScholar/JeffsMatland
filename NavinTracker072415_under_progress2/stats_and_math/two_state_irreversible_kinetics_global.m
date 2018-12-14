function [y_vector, A, C] = two_state_irreversible_kinetics_global(t_vector, t0, A0, C0, k1,  ...
                                                                                a1,a2,a3, c1,c2,c3)

constraint=0;
eA_vector = [a1 a2 a3];
eC_vector = [c1 c2 c3];


t = t_vector(1:length(t_vector)/length(eA_vector));

if(A0<0)
    constraint = constraint + (A0)^2;
end

if(C0<0)
    constraint = constraint + (C0)^2;
end

if(abs((A0+C0)-1) > 1e-4)
    constraint = constraint + (A0)^2+ (C0)^2;
end

if(k1 < 0)
    constraint = constraint + (k1)^2;
end


for(i=1:length(eA_vector))
    if(eA_vector(i)<0)
        constraint = constraint + (eA_vector(i))^2;
    end
    
    if(eC_vector(i)<0)
        constraint = constraint + (eC_vector(i))^2;
    end
end

if(constraint > 0)
    y_vector = zeros(1,length(t)*length(eA_vector)) + constraint;
    A=zeros(1,length(t)); C=A;
    return;
end

dt = t - t0;

A = A0*exp(-k1*dt);


idx=find(t<t0);
A(idx) = A0;

C = 1 - A;

y_vector = [];
for(i=1:length(eA_vector))
    y = eA_vector(i)*A + eC_vector(i)*C ; %  + rand(1,length(t))/2;
    y_vector = [y_vector y];
end

return;
end
