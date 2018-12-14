function z = bukin6(x)
% min at [-10 1]

z = 1e9;

if(x(1)<-15)
    return;
end
if(x(1)>-5)
    return;
end
if(abs(x(2))>3)
    return;
end

z = (100*sqrt(abs(x(2) - 0.01*x(1)^2)) +  0.01*abs(x(1)+10));

return;
end
