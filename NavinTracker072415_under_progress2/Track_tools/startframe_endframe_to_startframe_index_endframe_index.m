function [startframe_index, endframe_index] = startframe_endframe_to_startframe_index_endframe_index(Tracks, startframe, endframe)

startframe_index = 1;
endframe_index = length(Tracks.Frames);

first_frame = min_struct_array(Tracks,'Frames');
last_frame = max_struct_array(Tracks,'Frames');

[m,b] = fit_line([first_frame last_frame],[startframe_index  endframe_index]);

startframe_index = round(b + m*startframe);
endframe_index = round(b + m*endframe);

return;
end
