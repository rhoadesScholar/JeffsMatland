function [x,y,closed_flag] = close_polygon(x,y,tr)
% [x,y] = close_polygon(x,y)
% given x,y coords of a polygon
% find points with only one adjacent neighbor and interpolate to close

closed_flag = 1;

if(isempty(x))
    return;
end

col_vec = 1;
if(size(x,1)==1)
    col_vec = 0;
    x = x';
    y = y';
end


num_points = length(x);

num_adj = zeros(1,num_points);

i=1;
while(i<=num_points)
    if(num_adj(i)<2)
        j=1;
        while(j<=num_points)
            if(j~=i)
                if(abs(x(i)-x(j))<=1)
                    if(abs(y(i)-y(j))<=1)
                        num_adj(i) = num_adj(i) + 1;
                    end
                end
            end
            j=j+1;
            if(num_adj(i)>=2)
                j = num_points+10;
            end
        end
    end
    i=i+1;
end

end_idx = find(num_adj<2);
if(isempty(end_idx))
    return;
end

closed_flag = 0;

i=1;
while(i<length(end_idx))
    
    [m,b] = fit_line(x([end_idx(i) end_idx(i+1)]), y([end_idx(i) end_idx(i+1)]));
    
    new_x = [min(x(end_idx(i)), x(end_idx(i+1))):max(x(end_idx(i)), x(end_idx(i+1)))]';
    
    new_y = m*new_x + b;
    
    x = [x; new_x];
    y = [y; new_y];
    i=i+2;
end

if(nargin<3)
    [x,y] = close_polygon(x,y,1);
end

[x,y]=polysort(x,y);

if(col_vec==0)
    x = x';
    y = y';
end

return;
end
