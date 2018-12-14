function lawn_edge = adjust_lawn_location(rawTracks, outer_edge)

% given the lawn and outer pen-line edges from the pen-drawing, re-adjust
% the location of the lawn based on the tracks. Since the lawn circle is
% drawn using a template, the radius should be pretty robust. However, the
% exact location of the drop of food used to form the lawn may not be robust

[outer_radius,old_center_x,old_center_y] = circle_from_coords(outer_edge(:,1), outer_edge(:,2));

p.occ = calc_pixel_occupancy(rawTracks);

[p.x, p.y] = find(p.occ >= rawTracks(1).FrameRate); % rawTracks(1).FrameRate); % *60;

p.xc = old_center_x;
p.yc = old_center_y;
dx=0;
dy=0;
p.r_maxlim = 2*outer_radius;
p.r_minlim = outer_radius/2;
p.center_lim = outer_radius;

fminsearchoptions = optimset('TolFun',1e-4,'display','off');
v = fminsearch(@(v) adjust_lawn_function(v,p), [0.9*outer_radius, dx, dy], fminsearchoptions);
radius = v(1);
center_x = v(2) + old_center_x;
center_y = v(3) + old_center_y;

disp([radius center_x center_y adjust_lawn_function(v,p)])

[x,y] = coords_from_circle_params(radius, [center_x, center_y]);
lawn_edge(:,1) = x;
lawn_edge(:,2) = y;

adjust_lawn_function;

return;
end

function score = adjust_lawn_function(v, p)

persistent best_score;
persistent num_func_calls;

score=0;

if(nargin==0)
    clear('best_score');
    clear('num_func_calls');
    return;
end

if(isempty(best_score))
    best_score=1000000;
    num_func_calls = 0;
end
num_func_calls = num_func_calls+1;

if(v(1) < p.r_minlim || v(1) > p.r_maxlim)
   score = score + 1000 + abs(v(1))^2;
end

if(abs(v(2)) >= p.center_lim)
    score = score + 1000 + abs(v(2))^2;
end
if(abs(v(3)) >= p.center_lim)
    score = score + 1000 + abs(v(3))^2;
end

r = v(1);
cx = p.xc + v(2);
cy = p.yc + v(3);

area = pi*r*r;

inlawn_indicies = incircle(p.x,p.y, r, [cx, cy]); 
len_inlawn = length(inlawn_indicies);
px=[];
for(i=1:len_inlawn)
    px = [px 1 ]; % p.occ( p.x(i), p.y(i) )  % 1
end

score = score - sum(px)/area; 

if(score <= best_score && mod(num_func_calls,10)==0)
    best_score = score;
    disp( [ num2str([num_func_calls score]),' ',timeString() ] );
end

return;
end

