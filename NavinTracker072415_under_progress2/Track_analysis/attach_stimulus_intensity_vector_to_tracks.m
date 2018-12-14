function Tracks = attach_stimulus_intensity_vector_to_tracks(Tracks, stimulus)

maxframe = 0; 
for(t=1:length(Tracks))
   if(Tracks(t).Frames(end) > maxframe)
       maxframe = Tracks(t).Frames(end);
   end
end

stimvector = zeros(1, maxframe);

if(isempty(stimulus))
    for(t=1:length(Tracks))
        Tracks(t).stimulus_vector = single(stimvector(Tracks(t).Frames(1):Tracks(t).Frames(end)));
    end
    clear('framestim');
    clear('stimvector');
    return;
end

% convert the stimulus matrix into Time
framestim =  stimulus;
framestim(:,1) = framestim(:,1)*Tracks(1).FrameRate;
framestim(:,2) = framestim(:,2)*Tracks(1).FrameRate;

for(i=1:length(framestim(:,1)))
    stimvector(framestim(i,1):framestim(i,2)) = str2num(sprintf('%d%d',stimvector(framestim(i,1):framestim(i,2)), framestim(i,3)));
end

for(t=1:length(Tracks))
    Tracks(t).stimulus_vector = single(stimvector(Tracks(t).Frames(1):Tracks(t).Frames(end)));
end

clear('framestim');
clear('stimvector');

return;
end
