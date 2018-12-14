function Track = reframe_Track(Track, new_first_frame_number)
% Track = reframe_Track(Track, new_first_frame_number)
% renumbers Frames for Track elements dependent on frame number
% Reorientations, Reversals matrix, Time, etc

if(nargin<2)
    new_first_frame_number = 1;
end

if(length(Track)>1)
    for(i=1:length(Track))
        Track(i) = reframe_Track(Track(i), new_first_frame_number);
    end
    return;
end

numFrames = length(Track.Frames);

clear('Track.Frames');
Track.Frames = zeros(1,numFrames,'single');

Track.Frames(1) = new_first_frame_number;
for(i=2:numFrames)
    Track.Frames(i) = Track.Frames(i-1)+1;
end

clear('Track.Time');
Track.Time = double(Track.Frames/Track.FrameRate);

return;
end
