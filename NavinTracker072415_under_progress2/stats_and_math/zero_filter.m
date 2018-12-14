function x = zero_filter(x)
% x = zero_filter(x) if x(i)<0, x(i)=0

x(find(x<0))=0;

return;
end
