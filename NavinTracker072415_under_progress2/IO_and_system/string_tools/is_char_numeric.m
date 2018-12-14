function yes_no = is_char_numeric(inputchar)

numerics = '0123456789';

yes_no=0;

for(i=1:length(numerics))
    if(inputchar == numerics(i))
        yes_no=1;
        return;
    end
end

return;
end
