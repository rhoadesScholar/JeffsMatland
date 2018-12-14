function best_level = find_optimal_threshold_endpoint_chemotaxis(im, MaxWormArea, MinWormArea)


firstflag=1;
best_level = 0.3;
for(level = 0.3:0.025:0.9)
    
    BW = im2bw(im, level);
    [L,n] = bwlabel(~BW); 
    
    objects = regionprops(L, {'Area'});
    
    clear('BW'); clear('L'); 
    
    num_objects = length(objects);
    areas=[];
    for(i=1:num_objects)
        areas =[areas objects(i).Area];
    end
    clear('objects');
    
    num_worms = length(find(areas<=MaxWormArea & areas>=MinWormArea));
    
    %disp(num2str([level num_objects num_worms num_objects/num_worms abs(num_worms - num_objects)]))
    
    score = num_objects/num_worms;
        if(firstflag==1)
            best_score = score;
            prev_score = score;
            firstflag=0;
        end
    if(score < best_score)
        best_score = score;
        best_level = level;
    end
%     if(prev_score <  score)
%         break
%     end    
    
    prev_score = score;
    
end

best_level = best_level+0.025;

return;
end