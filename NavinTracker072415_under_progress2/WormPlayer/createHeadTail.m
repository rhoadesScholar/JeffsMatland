% by Navin
function frame = createHeadTail(frame, body_contour)

if(length(body_contour.x)>3)
    if(body_contour.head > 0)
        frame(floor(body_contour.y(body_contour.head)), floor(body_contour.x(body_contour.head)), :) = [0 0 255]; % blue head
    end
    
    if(body_contour.midbody>0)
        frame(floor(body_contour.y(body_contour.midbody)), floor(body_contour.x(body_contour.midbody)), :) = [0 255 0]; % green  midbody
    end
    
    if(body_contour.tail>0)
        frame(floor(body_contour.y(body_contour.tail)), floor(body_contour.x(body_contour.tail)), :) = [255 0 0]; % red  tail
    end
end

return
end
