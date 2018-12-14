function z = egg(x)
% min at [512 404.2319]

z = 1e9;

if(abs(x(1))>512) 
    return;
end 

if(abs(x(2))>512) 
    return; 
end

z = -(x(2)+47)*sin(sqrt(abs(x(2)+0.5*x(1)+47))) - x(1)*sin(sqrt(abs(x(1)-(x(2)+47)))) ;


return;
end
