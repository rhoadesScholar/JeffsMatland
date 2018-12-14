function [grid, gridlines_x, gridlines_y] = generate_grid_from_corners(corners, grid_size)
% define grid for square plates and fill in with blank_level grid_width lines
% gridlines [m1 b1; m2 b2; ... ; m_n b_n] eqns for gridlines
% grid is [x1 y1 x2 y2 x3 y3; x1 y1 x2 y2 x3 y3; .... x1 y1 x2 y2 x3 y3] grid squares

x=[];
y=[];
for(s=1:3)
    dx = corners(s+1,1) - corners(s,1);
    dy = corners(s+1,2) - corners(s,2);
    sidelen=sqrt((dx)^2+(dy)^2);
    for(q=0:grid_size)
        x(s,q+1) =  corners(s,1) + dx*(q/grid_size);
        y(s,q+1) =  corners(s,2) + dy*(q/grid_size);
    end
    
end

dx = corners(1,1) - corners(4,1);
dy = corners(1,2) - corners(4,2);
sidelen=sqrt((dx)^2+(dy)^2);
for(q=0:grid_size)
    x(4,q+1) =  corners(4,1) + dx*(q/grid_size);
    y(4,q+1) =  corners(4,2) + dy*(q/grid_size);
end



% gridlines between (x(i,n),y(i,n)) and (x(i+2,grid_size+1-n),y(i+2,grid_size+1-n))
xall = min(min(x)):1:max(max(x));
yall = min(min(y)):1:max(max(y));

m_vert=[]; b_vert=[];
vert_gridlines_x=[]; vert_gridlines_y=[]; 
i=1;
for(n=1:grid_size+1)
    [m, b] = line_from_two_points(x(i,n),y(i,n), x(i+2,grid_size+2-n),y(i+2,grid_size+2-n));
    m_vert = [m_vert m]; b_vert = [b_vert b];
%     yline = m*xline + b;
    
    [m, b] = line_from_two_points(y(i,n),x(i,n), y(i+2,grid_size+2-n),x(i+2,grid_size+2-n));
    xline = m*yall + b;
    
    vert_gridlines_x = [vert_gridlines_x xline];
    vert_gridlines_y = [vert_gridlines_y yall];
end

m_horiz=[]; b_horiz=[];
horiz_gridlines_x=[]; horiz_gridlines_y=[]; 
i=2;
for(n=1:grid_size+1)
    [m, b] = line_from_two_points(x(i,n),y(i,n), x(i+2,grid_size+2-n),y(i+2,grid_size+2-n));
    m_horiz = [m_horiz m]; b_horiz = [b_horiz b];
    yline = m*xall + b;
    
    horiz_gridlines_x = [horiz_gridlines_x xall];
    horiz_gridlines_y = [horiz_gridlines_y yline];
    
end

gridlines_x = round([horiz_gridlines_x vert_gridlines_x]);
gridlines_y = round([horiz_gridlines_y vert_gridlines_y]);

grid = [];
for(i=1:grid_size+1)
    for(j=1:grid_size+1)
        [x0,y0] = intersect_two_lines(m_horiz(i), b_horiz(i), m_vert(j), b_vert(j));
        grid = [grid; x0 y0];
    end
end
 
return
end

