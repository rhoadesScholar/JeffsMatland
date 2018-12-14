function [outer_edge, radius, xc, yc] = outer_edge_check(background, outer_edge, inputradius)

if(nargin<2)
    outer_edge=[];
end
if(nargin<3)
    inputradius=[];
end

imshow(background);
set(gcf,'units','normalized');
set(gcf,'position',[0.25 0.25 0.5 0.5]);
hold on;

[radius, xc,yc] = circle_from_coords(outer_edge(:,1), outer_edge(:,2));

answer(1) = 'N';
if(~isempty(outer_edge))
    plot(outer_edge(:,1),outer_edge(:,2),'g');
    hold on
    plot(xc, yc, 'xg');
    answer = questdlg('Is the edge properly defined?', 'Circle Check', 'Yes', 'No', 'Yes');
end

if(answer(1) == 'Y')
    close all;
    pause(0.1);
    return;
end

while answer(1) == 'N'
    
    a = questdlg(sprintf('Selection type?'), 'Circle Check', 'Center/rim', 'edge points','Center/rim');
    
    if(a(1) == 'C')
        questdlg(sprintf('Select the center.\nHit return.'), 'Circle Check', 'OK', 'OK');
        [xc, yc] = ginput2('ob');
        hold on;
        
        if(isempty(inputradius))
            questdlg(sprintf('Select a point on the circle\nHit return.'), 'Circle Check', 'OK', 'OK');
            
            plot(xc,yc,'ob');
            [x2, y2] = ginput2('*r');
            
            hold on;
            plot(xc,yc,'ob');
            plot(x2,y2,'*r');
            radius = sqrt((xc-x2)^2 +  (yc-y2)^2  );
        else
            radius = inputradius;
        end
    else
        [X, Y] = roi_perimeter(background);
        clear('outer_edge');
        [radius, xc,yc] = circle_from_coords(Y, X);
    end
    
    [outer_edge(:,1), outer_edge(:,2) ] = coords_from_circle_params(radius, [xc,yc]);
    
    hold off
    imshow(background);
    hold on;
    plot(outer_edge(:,1),outer_edge(:,2),'r');
    hold on
    plot(xc, yc, 'ob');
    answer = questdlg('Is the edge properly defined?', 'Circle Check', 'Yes', 'No', 'Yes');
end
close all;
pause(0.1);

return;
end
