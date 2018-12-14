function  d2b = decimal_to_binary(a, bitsize)

d2b = [];
for(i=1:length(a))
    d2b = [d2b fix(rem(a(i)*pow2(-(bitsize(i,1)-1):bitsize(i,2)),2)) ];
end

return;
end
