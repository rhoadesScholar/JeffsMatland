function dot_fill(vertex_x, vertex_y, color, dot_density_x, dot_density_y, dot_size)

if(nargin<6)
    dot_size=1;
end
if(nargin<5)
    dot_density_y=50;
    dot_density_x=1000;
end

x_min = min(vertex_x);
x_max = max(vertex_x);
step_x = (x_max-x_min)/dot_density_x;
[s, idx] = sort(vertex_x);
sort_vertex_x = vertex_x(idx);
sort_vertex_y = vertex_y(idx);
x_val = x_min:step_x:x_max;
start_idx=1;
for(i=1:length(x_val))
    [a,b] = find_bracketing_indicies(sort_vertex_x, x_val(i));

    y_local = sort_vertex_y(a:b);
    y_min = min(y_local);
    y_max = max(y_local);
    step_y = (y_max-y_min)/dot_density_y;

    y_val = y_min:step_y:y_max;

    end_idx = start_idx+length(y_val)-1;

    p(start_idx:end_idx,1) = x_val(i);
    p(start_idx:end_idx,2) = y_val;
    start_idx=end_idx+1;

end






% x_min = min(vertex_x);
% x_max = max(vertex_x);
%
% y_min = min(vertex_y);
% y_max = max(vertex_y);
%
% step_x = (x_max-x_min)/dot_density_x;
% step_y = (y_max-y_min)/dot_density_y;
%
% x_val = x_min:step_x:x_max;
% y_val = y_min:step_y:y_max;
% start_idx=1;
% end_idx = length(y_val);
% for(i=1:length(x_val))
%     p(start_idx:end_idx,1) = x_val(i);
%     p(start_idx:end_idx,2) = y_val;
%     start_idx=end_idx+1;
%     end_idx=end_idx+length(y_val);
% end



node(:,1) = vertex_x;
node(:,2) = vertex_y;

in = inpoly(p,node); % in==1 if p is inside the polygon, 0 if outside

k=1;
for(i=1:length(in))
    if(in(i))
        dot_x(k) = p(i,1);
        dot_y(k) = p(i,2);
        k=k+1;
    end
end

markerstring = sprintf('.%s',color);
plot(dot_x, dot_y, markerstring, 'MarkerSize', dot_size);

clear('dot_x');
clear('dot_y');
clear('p');
clear('node');
clear('in');

return;
end


