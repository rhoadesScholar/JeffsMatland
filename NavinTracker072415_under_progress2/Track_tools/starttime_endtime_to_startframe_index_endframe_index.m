function [startframe_index, endframe_index] = starttime_endtime_to_startframe_index_endframe_index(Tracks, starttime, endtime)

startframe_index = 1;
endframe_index = length(Tracks.Time);

first_time = min_struct_array(Tracks,'Time');
last_time = max_struct_array(Tracks,'Time');

[m,b] = fit_line([first_time last_time],[startframe_index  endframe_index]);

startframe_index = round(b + m*starttime);
endframe_index = round(b + m*endtime);

return;
end
