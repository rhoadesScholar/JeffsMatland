function [objects, num_worms] = add_delete_worms_with_mouse(im, objects, num_worms)

global Prefs;

num_worm_text = sprintf('%s\n%s\n%s','To add worms, click the left mouse button','To remove worms, click the right mouse button',...
    'When finished, click the middle mouse button or hit return');

questdlg(num_worm_text, sprintf('PID %d Add/Delete worms',Prefs.PID), 'OK', 'OK');

box_dim = [];
areas = [];
ecc = [];
for(i=1:length(objects))
    if(num_worms(i)==1)
        box_dim = [box_dim objects(i).BoundingBox(3) objects(i).BoundingBox(4)];
        areas = [areas objects(i).Area];
        ecc = [ecc objects(i).Eccentricity];
    end
end
mean_box_dim = nanmean(box_dim);
mean_area = nanmean(areas);
mean_ecc = nanmean(ecc);
clear('box_dim');
clear('areas');
clear('ecc');

button=0;


while(button~=2)
    
    view_picked_worms(objects, [], num_worms, im);
    
    zoom on;
    zoom reset;
    
    zoom off;
    [x,y, button] = ginput(1);
    
    
    if(button==1) % add worm
        obj.Area = mean_area;
        obj.Centroid(1) = x;
        obj.Centroid(2) = y;
        
        obj.BoundingBox(1) = x - mean_box_dim; 
        obj.BoundingBox(2) = y - mean_box_dim;
        obj.BoundingBox(3) = mean_box_dim;
        obj.BoundingBox(4) = mean_box_dim;
        
        obj.MajorAxisLength = mean_box_dim;
        obj.Eccentricity = mean_ecc;
        
        num_worms = [num_worms 1];
        objects(length(objects)+1) = obj;
        
        disp('added worm');
    end
    
    if(button==3) % remove worm
        mindist = 1e10;
        best_idx = 1;
        for(i=1:length(objects))
            
            dist = (x - objects(i).Centroid(1))^2 + (y - objects(i).Centroid(2))^2;
            
            if(dist < mindist)
               mindist = dist;
               best_idx = i;
            end
        end
        
        objects(best_idx) = [];
        
        num_worm_in_box = num_worms(best_idx);
        num_worms(best_idx) = [];
        
        disp([sprintf('removed %d worms in this object', num_worm_in_box)]);
    end
    
end


view_picked_worms(objects, [], num_worms, im);

close all

return;
end