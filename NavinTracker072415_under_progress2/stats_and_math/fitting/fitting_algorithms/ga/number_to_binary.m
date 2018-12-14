function binary_text = number_to_binary(rn)

if(length(rn)>1)
    binary_text='';
    for(i=1:length(rn))
        binary_text = sprintf('%s%s',binary_text,number_to_binary(rn(i)));
    end
    return;
end

binary_text = Fr_dec2bin(abs(rn));

[r,L] = right_left_decimal(binary_text);

len_r = length(r);
len_L = length(L);

if(len_r==17 && len_L==17)
    if(rn>=0)
        binary_text = sprintf('+%s',binary_text);
    else
        binary_text = sprintf('-%s',binary_text);
    end
    return;
end

if(len_L<17)
    zero_txt='';
    i=len_L;
    while(i<17)
        zero_txt = sprintf('%s0',zero_txt);
        i=i+1;
    end
    L = sprintf('%s%s',zero_txt,L);
end

if(len_L>17)
    L(18:end)=[];
end


if(len_r<17)
    zero_txt='';
    i=len_r;
    while(i<17)
        zero_txt = sprintf('%s0',zero_txt);
        i=i+1;
    end
    r = sprintf('%s%s',r,zero_txt);
end

if(len_r>17)
    r(18:end)=[];
end

binary_text = sprintf('%s.%s',L,r);

if(rn>=0)
    binary_text = sprintf('+%s',binary_text);
else
    binary_text = sprintf('-%s',binary_text);
end

% 17 digits right of decimal
% 17 digits left of decimal

return;

global GA_prefs;

[f,e] = log2(rn);

e = -e+GA_prefs.exp_length;
e_txt = dec2bin(e);

if(length(e_txt)>GA_prefs.exp_length)
    e_txt = e_txt(1:GA_prefs.exp_length);
else
    pre_zero='';
    for(q=1:GA_prefs.exp_length-length(e_txt))
        pre_zero = sprintf('0%s',pre_zero);
    end
    e_txt = sprintf('%s%s',pre_zero,e_txt);
end

f_txt = dec2bin(round(f*2^GA_prefs.exp_length));

if(length(f_txt)>GA_prefs.mant_length)
    f_txt = f_txt(1:GA_prefs.mant_length);
else
    pre_zero='';
    for(q=1:GA_prefs.mant_length-length(f_txt))
        pre_zero = sprintf('0%s',pre_zero);
    end
    f_txt = sprintf('%s%s',pre_zero,f_txt);
end


binary_text = sprintf('%s%s',f_txt,e_txt);

return;
end



