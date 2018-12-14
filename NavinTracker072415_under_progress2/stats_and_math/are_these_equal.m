function n = are_these_equal(a,b,epsilon)
% n = a_b_equal(a,b) returns 1 if a and b are within epsilon (1e-4), else 0

if(nargin<3)
    epsilon = 1e-4;
end

n=0;

if(abs(a-b)<=epsilon)
    n=1;
end

return;
end
