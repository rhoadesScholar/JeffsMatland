function outer_edge = find_drawn_lawn_edge(input_background, manual_flag)

% if manual_flag=0 don't bother doing the manual tracing now
if(nargin<2)
    manual_flag=1;
end

background = input_background;

s = size(background);

stopflag=0;
level=0.700;
level_limit = 0.2;
levelstep=0.0025;
bestlevel=0.700;
best_euler=1000;
best_bb=1000;
best_circum_ratio=1000;
best_len_bb = 0;
cycle=1;

while(cycle > 0)
    
    if(cycle == 2)
        background = input_background;
        level = 0.7;
        level_limit = 0.2;
        levelstep=0.0025;
        stopflag=0;
    elseif(cycle == 1)
        background = input_background;
        stopflag=0;
        levelstep=0.0025;
        level_limit = 0.001;
        level = 0.250;
        bline =  mean(background(:,1:end));
        for(i=1:length(bline))
            background(:,i) = background(:,i) - bline(i);
        end
        background = center_mask_background(background, nanmean(matrix_to_vector(background)));
    end
    
    while(stopflag==0)
        
        t1 = im2bw(background, level);
        t1 = ~t1;
        cc = bwconncomp_sorted(t1,'descend');
        
        % disp([level length(cc.PixelIdxList)])
        
        if(length(cc.PixelIdxList)>2)
            
            ring = zeros(s(1),s(2));
            ring(cc.PixelIdxList{2}) = 1;
            ring = bwmorph(ring,'spur');
            
            bb = bwboundaries(ring);
            
            if(length(bb)>=2)
                
                circum_ratio = length(bb{1})/length(bb{2});
                
                ed = bwmorph(ring,'spur'); ed = bwmorph(ed,'thin',Inf);
                q=1;
                while(q<=10)
                    ed = bwmorph(ed,'spur');
                    q=q+1;
                end
                
                
                if(abs(bweuler(ed)) < best_euler && length(bb) < best_bb && circum_ratio<=1 && length(bb{1})>100)
                    best_euler = abs(bweuler(ed));
                    best_bb = length(bb);
                    bestlevel = level;
                    best_circum_ratio = circum_ratio;
                    best_len_bb = length(bb{1});
                    
                    cycle = 0;
                    if(length(bb)==2 && circum_ratio<=1 && length(bb{1})>100 && abs(bweuler(ed))==0)
                        stopflag = 1;
                    end
                    
                    % disp([num2str(level) ' ' num2str(bweuler(ed)) ' ' num2str(length(bb)) ' '  num2str(circum_ratio)  ' ' num2str(length(bb{1}))  ' ' num2str(length(bb{2}))]);
                    % imshow(background); hold on; [r, c] = find(ed==1); plot(c,r,'.'); hold off;
                    % pause
                end
                
            end
        end
        
        level = level - levelstep;
        
        if(level <= level_limit)
            stopflag=1;
            if(best_euler <= 1 && best_circum_ratio<=1 && best_len_bb>100)
                cycle = 0;
            end
        end
        
    end
    
    if(cycle>0)
        cycle = cycle+1;
    end
    
    if(cycle==3)
        break;
    end
end

if(abs(bestlevel - 0.7) <= 1e-4)
    outer_edge=[];

    
    if(manual_flag == 1)
        disp([sprintf('Cannot find holepunch ... need to manually assign')]);
        disp([sprintf('Draw polygon to trace the holepunch circle')]);
        outer_edge = outer_edge_check(background, outer_edge);
    end
    
    return
end

level = bestlevel;
t1 = im2bw(background, level);
t1 = ~t1;
cc = bwconncomp_sorted(t1,'descend');

ring = zeros(s(1),s(2));
ring(cc.PixelIdxList{2}) = 1;
for(q=1:10)
    ring = bwmorph(ring,'spur');
end
ring = bwmorph(ring,'spur');
bb = bwboundaries(ring);

radius1 = circle_from_coords(bb{1}(:,1), bb{1}(:,2));
radius2 = circle_from_coords(bb{2}(:,1), bb{2}(:,2));

if(radius1 > radius2 )
    outer_edge = bb{1};
    inner_edge = bb{2};
else
    outer_edge = bb{2};
    inner_edge = bb{1};
end


circum_ratio = length(bb{1})/length(bb{2});
ed = bwmorph(ring,'spur'); ed = bwmorph(ed,'thin',Inf);
for(q=1:10)
    ed = bwmorph(ed,'spur');
end

% disp([num2str(bestlevel) ' ' num2str(best_euler) ' ' num2str(best_bb) ' '  num2str(circum_ratio)  ' ' num2str(length(bb{1}))  ' ' num2str(length(bb{2}))]);


[r, c] = find(ed==1); 
[outer_radius,xc,yc] = circle_from_coords(r, c);
[x,y] = coords_from_circle_params(outer_radius, [xc,yc]);
lawn_edge(:,1) = x;
lawn_edge(:,2) = y;


% [r, c] = find(ed==1);
% K = convhull(r,c);
% lawn_edge(:,1) = r(K);
% lawn_edge(:,2) = c(K);

clear('b');
clear('ring');
clear('ed');
clear('bb');
clear('cc');
clear('r'); clear('c');

return;
end


% radius = 90;
% center = [512, 512];
% rad = radius;
% numPoints = 100;
%
% imshow(background);
% hold on;
% theta = linspace(0,2*pi,numPoints);
% rho = ones(1,numPoints)*rad;
% [lawnX, lawnY] = pol2cart(theta, rho);
% lawnX=lawnX+center(1);
% lawnY=lawnY+center(2);
% drawcircle = plot(lawnX,lawnY,'g-');
% hold off;
%
% answer = questdlg('Is the circle properly defined?', 'Circle Check', 'Yes', 'No', 'Yes');
%
% while answer(1) == 'N'
%     prompt = {'Radius', 'Center X', 'Center Y'};
%     dlg_title = 'Enter new border coordinates';
%     num_lines = 1;
%     def = {num2str(radius), num2str(center(1)), num2str(center(2))};
%     ans = inputdlg(prompt,dlg_title,num_lines,def);
%     radius = str2double(ans(1));
%     center = [str2double(ans(2)), str2double(ans(3))];
%
%     hold on;
%     rad = radius;
%     theta = linspace(0,2*pi,numPoints);
%     rho = ones(1,numPoints)*rad;
%     [lawnX, lawnY] = pol2cart(theta, rho);
%     lawnX=lawnX+center(1);
%     lawnY=lawnY+center(2);
%     delete(drawcircle);
%     drawcircle = plot(lawnX,lawnY,'g-');
%     hold off
%     answer = questdlg('Is the circle properly defined?', 'Circle Check', 'Yes', 'No', 'Yes');
% end
% close all;
%
% %Produce border used for analysis of InLawn vs OffLawn
% hold on;
% theta = linspace(0,2*pi,numPoints);
% rho = ones(1,numPoints)*rad;
% [lawnX, lawnY] = pol2cart(theta, rho);
% lawnX=lawnX+center(1);
% lawnY=lawnY+center(2);
% drawcircle = plot(lawnX,lawnY,'y-');
% hold off;
%
% BW = roipoly(background,lawnX,lawnY);

