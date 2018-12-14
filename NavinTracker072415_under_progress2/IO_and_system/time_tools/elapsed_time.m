function seconds_elapsed = elapsed_time(start_time_string, end_time_string)
% seconds_elapsed = elapsed_time(start_time_string, end_time_string)

if(nargin==0)
    disp('usage: seconds_elapsed = elapsed_time(start_time_string, end_time_string)')
    return
end

start_time_vector = string_to_time_vector(start_time_string);
end_time_vector = string_to_time_vector(end_time_string);

seconds_elapsed = etime(end_time_vector, start_time_vector);

return;
end
