function local_inten = mean_object_intensity(object, im, level)

s = size(im);

local_inten=[];
for(p=round((object.BoundingBox(1))):round((object.BoundingBox(1) + object.BoundingBox(3))))
    for(q=round((object.BoundingBox(2))):round((object.BoundingBox(2) + object.BoundingBox(4))))
        if(q<=s(1) && p<=s(2))
           if(im(q,p)<=level)
                local_inten = [local_inten im(q,p)];
           end
        end
    end
end

% hist(local_inten);
% disp([nanmedian(local_inten) nanmean(local_inten) nansum(local_inten)])
% pause

local_inten = nansum(local_inten)/(object.Area); % nanmedian(local_inten);

return;
end
