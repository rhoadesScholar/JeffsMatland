function [x,y] = intersect_two_lines(m1, b1, m2, b2)
% return point of intersection for y=m1*x+b1 and y=m2*x+b2

x=[];
y=[];
if(m1==m2)
    return;
end

x = (b2-b1)/(m1-m2);

y = m1*x + b1;

return;
end
