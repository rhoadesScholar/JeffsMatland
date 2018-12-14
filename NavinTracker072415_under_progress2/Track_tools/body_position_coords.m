function coords = body_position_coords(Track, position_of_interest) 
% coords = [x1 y1; x2 y2; ... ] xy coords of the given body point (default 'head') for the track
% 

if(nargin<1)
    disp('usage: coords = body_position_coords(Track, <position_of_interest>), coords = [x,y] of position_of_interest = ''head'' default')
    return;
end

if(nargin<2)
    position_of_interest = 'head';
end
position_of_interest = lower(position_of_interest);

coords = zeros(length(Track.body_contour),2) + NaN;

for(i=1:length(Track.body_contour))
    coords(i,:) = [Track.SmoothX(i) Track.SmoothY(i)];
    
    j = Track.body_contour(i).(position_of_interest);
    if(j>0)
        coords(i,:) = [Track.body_contour(i).x(j) Track.body_contour(i).y(j)];
    else
        j = Track.body_contour(i).midbody;
        if(j>0)
            coords(i,:) = [Track.body_contour(i).x(j) Track.body_contour(i).y(j)];
        end
    end
    
    if(sum(coords(i,:))==0)
        coords(i,:) = [NaN NaN];
    end
end

return;
end
