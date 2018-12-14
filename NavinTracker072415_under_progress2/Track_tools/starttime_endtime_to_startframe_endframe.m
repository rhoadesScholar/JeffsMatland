function [startframe, endframe] = starttime_endtime_to_startframe_endframe(Tracks, starttime, endtime)

firstframe = min_struct_array(Tracks,'Frames');
lastframe = max_struct_array(Tracks,'Frames');

first_time = min_struct_array(Tracks,'Time');
last_time = max_struct_array(Tracks,'Time');

[m,b] = fit_line([first_time last_time],[firstframe  lastframe]);

startframe = round(b + m*starttime);
endframe = round(b + m*endtime);

return;
end
