function [x,y] = coords_from_circle_params(radius, center, stepsize)

if(nargin<3)
    stepsize=0.01;
end

theta = [0:stepsize:2*pi 2*pi 0];

x = radius*cos(theta) + center(1);
y = radius*sin(theta) + center(2);

return;
end
