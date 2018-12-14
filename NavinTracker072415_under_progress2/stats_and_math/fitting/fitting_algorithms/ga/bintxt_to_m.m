function m = bintxt_to_m(bintxt)
% m = chr_to_m(chr)
% breaks a chromosome binary string into a vector of decimal numbers (m)

global GA_prefs;

m=[];
i=1;
while(i<=GA_prefs.bintxt_length)
   binary_txt =  bintxt(i:i+GA_prefs.word_length-1);
   m = [m binary_to_number(binary_txt)];
   i=i+GA_prefs.word_length;
end

return;
end
