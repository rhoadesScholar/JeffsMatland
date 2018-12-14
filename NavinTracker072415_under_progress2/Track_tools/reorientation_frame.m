function reori_idx = reorientation_frame(Track, frame)
% reori_idx = reorientation_frame(Tracks, frame)
% if frame is in a reorientation, returns the index of Track.Reorientations
% else []

reori_idx=[];

if(isempty(Track.Reorientations))
    return;
end

i=1;
while(i<=length(Track.Reorientations))
    if(frame >= Track.Reorientations(i).start && frame <= Track.Reorientations(i).end)
        reori_idx = i;
        return;
    end    
    i=i+1; 
end

return;
end
