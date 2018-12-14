function [x,y, dir, abs_delta_dir] = point_on_line_d_away_from_P(m,yint,x0,y0,direction,d)


x1 = x0;
y1 = m*x1 + yint;

a = double(1+m^2);
b = double(2*(m*yint -y1*m-x1));
c = double(x1^2 + yint^2 -2*y1*yint + y1^2 - d^2);

% if((b^2 - 4*a*c)<0)
%     sprintf('DISCRIMINANT NEGATIVE!!!!!')
%     sprintf('%f\t\tm=%f yint=%f x0=%f y0=%f dir=%f d=%f',(b^2 - 4*a*c), m,yint,x0,y0,direction,d)
%     pause;
% end

% two solutions to the quadratic ... one ahead of the track, the other
% backtracking (antiparallel)
x = (-b + sqrt(b^2 - 4*a*c))/(2*a);
y = m*x + yint;
dy = -(y-y1);
if(abs(dy)<eps)
    dy=eps;
end
dir = atan((x-x1)/dy )*360/(2*pi);	    % In degrees, 0 = Up ("North")
if(dy<0)
    if( dir <= 0)
        dir = dir + 180;
    else
        dir = dir - 180;
    end
end
pos_dir = dir;
pos_x = x;
pos_y = y;
pos_delta = abs(delta_direction(dir, direction));


% neg soln
x = (-b - sqrt(b^2 - 4*a*c))/(2*a);
y = m*x + yint;
dy = -(y-y1);
if(abs(dy)<eps)
    dy=eps;
end
dir = atan((x-x1)/dy )*360/(2*pi);	    % In degrees, 0 = Up ("North")
if(dy<0)
    if( dir <= 0)
        dir = dir + 180;
    else
        dir = dir - 180;
    end
end
neg_delta = abs(delta_direction(dir, direction));
neg_dir = dir;
neg_x = x;
neg_y = y;

if(neg_delta < pos_delta) % negative is better
    x  = neg_x;
    y = neg_y;
    dir = neg_dir;
    abs_delta_dir = neg_delta;
else
    x  = pos_x;
    y = pos_y;
    dir = pos_dir;
    abs_delta_dir = pos_delta;
end

return;
end
