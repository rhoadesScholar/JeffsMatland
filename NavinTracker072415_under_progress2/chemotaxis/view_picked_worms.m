function h=view_picked_worms(objects, object_idx, num_worms, im)

global Prefs;

h=figure('Name',sprintf('PID %d',Prefs.PID),'NumberTitle','off');
imshow(im);
hold on;

for(i=1:length(objects))
    if(objects(i).BoundingBox(3) > 0 && objects(i).BoundingBox(4) > 0)
        rectangle('Position',objects(i).BoundingBox,'EdgeColor','w');
    end
end

if(isempty(num_worms) && isempty(object_idx))
    for(i=1:length(objects))
        text(objects(i).Centroid(1), objects(i).Centroid(2),num2str(objects(i).Area),'color','b');
    end
    hold off
    return;
end

if(isempty(num_worms))
    for(i=1:length(objects))
        idx = find(object_idx == i);
        if(isempty(idx))
            text(objects(i).Centroid(1), objects(i).Centroid(2),num2str(objects(i).Area),'color','b');
        else
            text(objects(i).Centroid(1), objects(i).Centroid(2),num2str(objects(i).Area),'color','g');
        end
    end
    hold off
    return
end

if(isempty(object_idx))
    for(i=1:length(objects))
        if(are_these_equal(num_worms(i),floor(num_worms(i))))
            text(objects(i).Centroid(1), objects(i).Centroid(2),sprintf('%d',num_worms(i)),'color','r');
        else
            text(objects(i).Centroid(1), objects(i).Centroid(2),sprintf('%.1f',num_worms(i)),'color','r');
        end
    end
    hold off
    return;
end

if(~isempty(object_idx))
    for(i=1:length(objects))
        idx = find(object_idx == i);
        if(~isempty(idx))
            if(are_these_equal(num_worms(idx),floor(num_worms(idx))))
                text(objects(i).Centroid(1), objects(i).Centroid(2),sprintf('%d',num_worms(idx)),'color','r');
            else
                text(objects(i).Centroid(1), objects(i).Centroid(2),sprintf('%.1f',num_worms(idx)),'color','r');
            end
        else
            text(objects(i).Centroid(1), objects(i).Centroid(2),num2str(objects(i).Area),'color','g');
        end
    end
    hold off
    return
end

return;
end
