function [m, b] = line_from_two_points(x1, y1, x2, y2)

m = (y2 - y1)/(x2 - x1);

if(isinf(abs(m)))
    m = sign(m)*rand*1e19;
end

b = y1 - m*x1;

return;
end
