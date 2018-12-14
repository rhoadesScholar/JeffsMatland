function num_worms_vector = num_worms_per_frame(Tracks)
% num_worms_vector = num_worms_per_frame(Tracks)

attribute_matrix = create_attribute_matrix_from_Tracks(Tracks, 'Frames');

num_frames = size(attribute_matrix,2);
num_worms_vector = zeros(1,num_frames);
for(i=1:num_frames)
    num_worms_vector(i) = sum(~isnan(attribute_matrix(:,i)));
end

return;
end

% num_worms =[];
% min_frame = min_struct_array(Tracks,'Frames');
% max_frame = max_struct_array(Tracks,'Frames');
% for(ff = min_frame:max_frame)
%     track_idx_frame_idx = find_Track(Tracks, 'Frames', sprintf('==%d',ff) );
%     num_worms = [num_worms length(track_idx_frame_idx)];
% end

