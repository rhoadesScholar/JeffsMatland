function b2d = binary_to_decimal(a, bitsize)


b2d = [];
i=1; j=1;
while(i<=length(a))
    b2d = [b2d  a(i:(i+(bitsize(j,1)+bitsize(j,2))-1))*pow2(bitsize(j,1)-1:-1:-bitsize(j,2)).'];
    i = i+bitsize(j,1)+bitsize(j,2);
    j=j+1;
end

return;
end


