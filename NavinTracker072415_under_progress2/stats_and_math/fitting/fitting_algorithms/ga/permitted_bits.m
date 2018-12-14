function allowed_bits = permitted_bits(bit_sign)

allowed_bits = [-1 0 1];
if(bit_sign>0)
    allowed_bits = [0 1];
    return;
end
if(bit_sign<0)
    allowed_bits = [0 -1];
    return;
end

return;
end

