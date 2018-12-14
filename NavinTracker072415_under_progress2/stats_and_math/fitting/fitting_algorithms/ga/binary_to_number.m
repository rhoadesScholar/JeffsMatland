function d = binary_to_number(binary_text)
%  d = binary_to_number(binary_text)

d = Fr_bin2dec(binary_text(2:end));

if(binary_text(1)=='-')
    d = -d;
end

return;

% special function
% last four binary "digits" are exponent
% 24-bit numbers 0 -> 65535 

global GA_prefs;

mant = bin2dec(binary_text(1:GA_prefs.mant_length));
xp = bin2dec(binary_text(GA_prefs.mant_length_plus1:GA_prefs.word_length));

d = mant*2^-xp; 

return;
end

