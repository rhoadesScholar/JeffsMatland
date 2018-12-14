function [y_new, x, y] = interpolate_and_fill_data(x_old, y_old, x_new)

xmin = min(x_new);
xmax = max(x_new);
num_contour_points = length(x_new);

x = x_old;
y = y_old;

if(isrow(x))
    x = x';
end
if(isrow(y))
    y = y';
end

if(x(1) > xmin)
   x = [xmin; x];
   y = [y(1); y];
end
if(x(end) < xmax)
   x(end+1) = xmax;
   y(end+1) = y(end);
end

[~,idx] = sort(x);
x = x(idx);
y = y(idx);
idx = find(x >= xmin & x <= xmax);
x = x(idx);
y = y(idx);

while(length(x)<5*num_contour_points)
    x2=[]; y2=[];
    for(i=1:length(x)-1)
        x2 = [x2; (x(i)+x(i+1))/2];
        y2 = [y2; (y(i)+y(i+1))/2];
    end
    x = [x; x2];
    y = [y; y2];
    
    [~,idx] = sort(x);
    x = x(idx);
    y = y(idx);
    idx = find(x >= xmin & x <= xmax);
    x = x(idx);
    y = y(idx);
end

y_new = [];
for(i=1:length(x_new))
    [~, idx] = find_closest_value_in_array(x_new(i), x);
    y_new = [y_new; y(idx)];
    y(idx)=[]; x(idx)=[];
end
t = [1:length(x_new)]';
ts = linspace(1, length(x_new), num_contour_points)';
y_new = interp1(t,y_new,ts);

% t = [1:length(x)]';
% ts = linspace(1, length(x), num_contour_points)';
% y_new = interp1(t,y,ts);

if(iscolumn(x_new))
    y_new = y_new';
end

return;
end
