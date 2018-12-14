function [Movsubtract, timestamp] = background_subtracted_frame(MovieName, Frame, background, timestamp_coords)


if(nargin<4)
    timestamp_coords = [];
end

timestamp = 0;

Mov = aviread_to_gray(MovieName, Frame);

Movsubtract = max((background - double(Mov.cdata))./255, 0);
Movsubtract = Movsubtract./max(max(Movsubtract));

%Movsubtract = (1 - min( double(Mov.cdata+1)./(background+1), 1));

if(isempty(timestamp_coords))
    return;
end

if(nargout>1)
    timestamp = timestamp_from_image(Mov.cdata, timestamp_coords);
end


%   black out timer pixels
if(~isempty(timestamp_coords))
    Movsubtract(timestamp_coords(1):timestamp_coords(2), timestamp_coords(3):timestamp_coords(4)) = 0;
end
  

return;
end
