function U = underline(S, fontsize)

if(nargin<2)
    fontsize = 14;
end

fontsize = fontsize+4;

p='';
for n = 1:(length(S)+5)
    p=[p '\_'];
end

U = ['_{\fontsize{' num2str(fontsize) '}^{' S '}_{^{' p '}}}'];

return;
end
