function time_string = seconds_to_time_colon_string(time_in_sec)

if(time_in_sec<0)
    time_string = sprintf('-%s',datestr(datenum(0,0,0,0,0,abs(double(time_in_sec))),'MM:SS'));
    return;
end

time_string = datestr(datenum(0,0,0,0,0,double(time_in_sec)),'MM:SS');

return;
end
