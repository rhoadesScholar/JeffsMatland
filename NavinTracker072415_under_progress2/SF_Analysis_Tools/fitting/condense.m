function [y I] = condense(x)

I = zeros(length(x),1);

j=1;
for m=2:length(x)
    if x(m)==x(m-1);
        I(j) = m;
        j=j+1;
    end
end

I = trim(I,1);
x(I) = [];
y = x;