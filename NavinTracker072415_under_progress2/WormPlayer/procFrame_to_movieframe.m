function Mov = procFrame_to_movieframe(procFrame, height, width)
% Mov = procFrame_to_movieframe(procFrame, height, width)

Mov.cdata=[];
Mov.colormap=[];

Mov.cdata = zeros(height,width,3)+255;

for(j=1:length(procFrame.worm))
    
    [y_coord, x_coord] = find(procFrame.worm(j).image==1);
    
    x = x_coord + floor(procFrame.worm(j).bound_box_corner(1));
    y = y_coord + floor(procFrame.worm(j).bound_box_corner(2));
    
    for(q=1:length(x))
        Mov.cdata(y(q),x(q),:) = [0 0 0];
    end
    
    clear('y_coord');
    clear('x_coord');
    clear('y');
    clear('x');
    
end

Mov.cdata = uint8(Mov.cdata);

return

end
