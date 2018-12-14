function im2 = box_picked_objects(im, objects)

level = 0;

im2 = im;
for(i=1:length(objects))
    
    x=objects(i).BoundingBox(1);
    for(y=objects(i).BoundingBox(2):(objects(i).BoundingBox(2)+objects(i).BoundingBox(4)))
        im2(round(y),round(x)) = level;
    end
    x=(objects(i).BoundingBox(1)+objects(i).BoundingBox(3));
    for(y=objects(i).BoundingBox(2):(objects(i).BoundingBox(2)+objects(i).BoundingBox(4)))
        im2(round(y),round(x)) = level;
    end
    
    y=objects(i).BoundingBox(2);
    for(x=objects(i).BoundingBox(1):(objects(i).BoundingBox(1)+objects(i).BoundingBox(3)))
        im2(round(y),round(x)) = level;
    end
    
    y=(objects(i).BoundingBox(2)+objects(i).BoundingBox(4));
    for(x=objects(i).BoundingBox(1):(objects(i).BoundingBox(1)+objects(i).BoundingBox(3)))
        im2(round(y),round(x)) = level;
    end
       
end

return;
end