function single_track_stimulusShade(Track)

stimulus_image = zeros(1,max(Track.Frames),3)+1;

if(nansum(Track.stimulus_vector)>0)
    for(j=1:length(Track.stimulus_vector))
        stimulus_image(1,Track.Frames(j),:) = stimulus_colormap(Track.stimulus_vector(j));
    end
end

image(stimulus_image);
box('off');
set(gca,'ytick',[]);

clear('stimulus_image');

return;
end
