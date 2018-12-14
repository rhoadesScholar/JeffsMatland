function z = holder_table(x)
% min at +/-[8.05502 9.66459]


z = 1e9;

if(abs(x(1))>10) 
    return;
end 

if(abs(x(2))>10) 
    return; 
end

z = -abs((sin(x(1))*cos(x(2)))*(exp(abs(1 - sqrt(x(1)^2+x(2)^2)/pi))));


return;
end
