function [r,L] = right_left_decimal(number_txt)


% is an integer
if(isempty(findstr(number_txt,'.')))
   L =  number_txt;
   r = '';
   return;
end

i=1;
while(number_txt(i)~='.')
    i=i+1;
end
L = number_txt(1:i-1);
r = number_txt(i+1:end);

return;
end
