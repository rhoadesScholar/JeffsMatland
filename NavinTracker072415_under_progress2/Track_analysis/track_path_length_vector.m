function d_vector = track_path_length_vector(Track, startFrame_vector, endFrame_vector)

d_vector = [];

for(i=1:length(startFrame_vector))
    d_vector(i) = track_path_length(Track, startFrame_vector(i), endFrame_vector(i));
end

d_vector = d_vector';

return;
end
