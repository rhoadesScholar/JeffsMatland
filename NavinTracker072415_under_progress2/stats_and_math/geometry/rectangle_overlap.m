function overlap_flag = rectangle_overlap(rect1, rect2)
% overlap_flag = rectangle_overlap(rect1, rect2)
% rect = [x_ulc y_ulc w h], ulc = upper left corner

overlap_flag = 0;

if(rect2(1) > (rect1(1) + rect1(3)))
    return;
end

if(rect2(2) < (rect1(2) - rect1(4)))
    return;
end

if((rect2(1) + rect2(3)) < rect1(1))
    return;
end

if((rect2(2) - rect2(4)) > rect1(2))
    return;
end


overlap_flag = 1;

return;
end
