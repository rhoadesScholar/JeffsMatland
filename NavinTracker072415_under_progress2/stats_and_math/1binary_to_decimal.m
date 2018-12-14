function b2d = binary_to_decimal(a)

n = 9; % 18;
m = 17; % 18;


b2d = [];
for(i=1:(n+m):length(a))
    b2d = [b2d  a(i:(i+(n+m)-1))*pow2(n-1:-1:-m).'];
end

return;
end
