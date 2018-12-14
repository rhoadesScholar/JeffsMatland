function [pixelsize, score] = calc_pixelsize_from_square_ring(Ring, actual_square_width, pixel_dim)

[pixelsize, score] = calc_pixelsize_by_fitting_square_ring(Ring, actual_square_width, pixel_dim);
return

s = [];
x = Ring.RingX;
y = Ring.RingY;

i=1;
while(i<length(x))
    idx = find(x == x(i));
    if(length(idx)==2)
       s = [s abs(y(idx(1)) - y(idx(2)))];
       x(idx)=[];
       y(idx)=[];
    else
        i=i+1;
    end
end


x = Ring.RingX;
y = Ring.RingY;

i=1;
while(i<length(y))
    idx = find(y == y(i));
    if(length(idx)==2)
       s = [s abs(x(idx(1)) - x(idx(2)))];
       x(idx)=[];
       y(idx)=[];
    else
        i=i+1;
    end
end 

pixelsize = actual_square_width/mean(s);

return;
end



function [pixelsize, bestscore] = calc_pixelsize_by_fitting_square_ring(Ring, actual_square_width, pixel_dim)

global Prefs;

pixelsize = Prefs.DefaultPixelSize;

anglelim = pi/3; % 0.2;

% x = [Cx, Cy, s, phi ] square centered at (Cx, Cy) w/ side of s pixels,
% tilted at angle phi
fminsearchoptions = optimset('MaxFunEvals',5000);

% best_x = [bracketed_rand(pixel_dim/4, 3*pixel_dim/4), bracketed_rand(pixel_dim/4, 3*pixel_dim/4), ...
%             bracketed_rand(0.5*pixel_dim, 1.5*pixel_dim), bracketed_rand(-anglelim, anglelim)];
        
best_x = [pixel_dim/2, pixel_dim/2, pixel_dim, 0];    
bestscore = obj_function(best_x, Ring, pixel_dim);      
for(i=1:12)
    if(i==1)
        x0 = best_x;
    else
        x0 = [bracketed_rand(pixel_dim/4, 3*pixel_dim/4), bracketed_rand(pixel_dim/4, 3*pixel_dim/4), ...
             bracketed_rand(0.5*pixel_dim, 1.5*pixel_dim), bracketed_rand(-anglelim, anglelim)];
    end
    
    x = fminsearch(@(x) obj_function(x,Ring,pixel_dim), x0,fminsearchoptions);
    
    score = obj_function(x, Ring, pixel_dim);
    
    if(score < bestscore)
        bestscore = score;
        best_x = x;
    end
end
x = best_x;

pixelsize = actual_square_width/x(3);
if(bestscore>1e6)
    pixelsize=NaN;
end


% square_points = calc_squarepoints(x(1), x(2), x(3), x(4)); square_points(17,:) = square_points(1,:);
% disp([sprintf('%f\t%f\t%f\t%f',x(1), x(2), x(3), 180*x(4))])
% hold on;
% plot(square_points(:,1), square_points(:,2), '.y');
% hold off;
% axis('ij');
% axis([0 pixel_dim 0 pixel_dim]);
% pause

return;
end

function score = obj_function(x, Ring, pixel_dim)

square_points = calc_squarepoints(x(1), x(2), x(3), x(4));
score = square_points_to_ring_dist(square_points, Ring)/size(square_points,1);

if(x(3) > 1*pixel_dim || x(3) < 0.8*pixel_dim)
    score = score+1e6;
end

if(abs(x(4)) > 0.2)
    score = score+1e6;
end

return;
end

function d = square_points_to_ring_dist(square_points, Ring)

d = 0;
for(i=1:length(square_points(:,1)))

    X = square_points(i,1)*Ring.ComparisonArrayX;
    Y = square_points(i,2)*Ring.ComparisonArrayY;

    RingDX = Ring.RingX - X;
    RingDY = Ring.RingY - Y;

    D = RingDX.^2 + RingDY.^2;
    D1 = min(D);

    d = d + D1;
end

return;
end

function square_points = calc_squarepoints(Cx, Cy, s, phi)

% center at Cx, Cy
half_s = (s/2);
quarter_s = (s/16);

i=0;
% upper
for(j=Cx-half_s:quarter_s:Cx+half_s)
   i=i+1;
   square_points(i,2) = Cy + half_s;
   square_points(i,1) = j;
end

% right
for(j=Cy+half_s:-quarter_s:Cy-half_s)
   i=i+1;
   square_points(i,1) = Cx + half_s;
   square_points(i,2) = j;
end

% lower
for(j=Cx+half_s:-quarter_s:Cx-half_s)
   i=i+1;
   square_points(i,2) = Cy - half_s;
   square_points(i,1) = j;
end

% left
for(j=Cy-half_s:quarter_s:Cy+half_s)
   i=i+1;
   square_points(i,1) = Cx - half_s;
   square_points(i,2) = j;
end


% rotate all by phi 
for(i=1:length(square_points(:,1)))
    [square_points(i,1), square_points(i,2)] = rotate_point(square_points(i,1), square_points(i,2), phi);
end

return;
end
