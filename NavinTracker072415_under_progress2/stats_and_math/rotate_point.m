% rotate x,y by phi radians

function [xprime, yprime] = rotate_point(x,y,phi)

sin_phi = sin(phi);
cos_phi = cos(phi);

xprime = x*cos_phi + y*sin_phi;
yprime = -x*sin_phi + y*cos_phi;

return;
end
