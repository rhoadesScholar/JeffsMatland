function  d2b = decimal_to_binary(a)

n = 9; % 18;
m = 17; % 18;

d2b = [];
for(i=1:length(a))
    d2b = [d2b fix(rem(a(i)*pow2(-(n-1):m),2)) ];
end

return;
end
