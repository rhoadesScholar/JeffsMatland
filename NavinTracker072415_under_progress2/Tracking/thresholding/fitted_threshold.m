% fit a double exponential to the semilog pixel intensity distribution
% try threshold level = p_crit value at the intersection of the two exponentials

function fitLevel = fitted_threshold(Movsubtract)

v = double(matrix_to_vector(Movsubtract));
v_non0 = v(find(v>0));

[y,x] = hist(v_non0,sqrt(length(v)));
y_non0 = find(y>0); 
x = x(y_non0); y = y(y_non0);
max_y = max(y);

eqn = sprintf('f(t)=abs(A)*exp(-t/abs(a))+abs(B)*exp(-t/abs(b)); A=%f; B=%f; a=0.005; b=0.08;log',max_y,sqrt(max_y));

f = ezfit(x,y, eqn);
fitLevel = t_crit(abs(f.m(1)), abs(f.m(3)), abs(f.m(2)), abs(f.m(4)));

if(~isreal(fitLevel))
    fitLevel = (abs(f.m(1))*abs(f.m(3)) + abs(f.m(2))*abs(f.m(4)))/(abs(f.m(1)) + abs(f.m(2)));
end

if(fitLevel<=0.001)
    fitLevel = 0.01;
end

if(fitLevel>=1)
    fitLevel = 0.99;
end

clear('v');
clear('v_non');
clear('x');
clear('y');
clear('y_non0');
clear('f');

return;
end
