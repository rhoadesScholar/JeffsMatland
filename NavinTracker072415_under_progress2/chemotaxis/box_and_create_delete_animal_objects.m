function [objects, num_worms, intens]  = box_and_create_delete_animal_objects(im, level, objects, num_worms, intens, wormsize)

centroids=[];
for(i=1:length(objects))
    centroids = [centroids; objects(i).Centroid];
end

hh = imrect;
boundingbox = getPosition(hh);

x_frame = [boundingbox(1) (boundingbox(1)+boundingbox(3))    (boundingbox(1)+boundingbox(3))   boundingbox(1)                   boundingbox(1)];
y_frame = [boundingbox(2) boundingbox(2)                     (boundingbox(2)+boundingbox(4))    (boundingbox(2)+boundingbox(4)) boundingbox(2)];

if(~isempty(centroids))
    idx_vector = inpolygon(centroids(:,1), centroids(:,2), x_frame, y_frame);
    
    % the rectangle contains pre-existing centroid ... mark for deletion
    if(sum(idx_vector)>0)
        objects(idx_vector) = [];
        num_worms(idx_vector) = [];
        intens(idx_vector) = [];
        return;
    end
end

object.Area=0;
for(x=boundingbox(1):(boundingbox(1)+boundingbox(3)))
    for(y=boundingbox(2):(boundingbox(2)+boundingbox(4)))
        if(im(round(y),round(x)) <= level)
            object.Area = object.Area+1;
        end
    end
end

num_this_box = round(object.Area/wormsize);
if(num_this_box < 1)
    num_this_box = 1;
end

object.Centroid(1) = (boundingbox(1) + (boundingbox(1)+boundingbox(3)))/2;
object.Centroid(2) = (boundingbox(2) + (boundingbox(2)+boundingbox(4)))/2;

object.BoundingBox = boundingbox;

object.MajorAxisLength = max(object.BoundingBox(3), object.BoundingBox(4));
minor_axis = min(object.BoundingBox(3), object.BoundingBox(4));

object.Eccentricity = sqrt(1 - object.MajorAxisLength^2/minor_axis^2);

objects = [objects; object];
num_worms = [num_worms num_this_box];
intens = [intens mean_object_intensity(object, im, level)];

return;
end
