function time_vector = string_to_time_vector(timestring)
% time_vector = string_to_time_vector(timestring)
% for 1:15:05pm on 3/10/10, timestring = '13:15:05 3/10/10'

dummystring = strrep(timestring, '/', ' ');
dummystring = strrep(dummystring, '_', ' ');
dummystring = strrep(dummystring, '.', ' ');
dummystring = strrep(dummystring, ':', ' ');

d = sscanf(dummystring, '%d'); % [Hour Minute Second Month Day Year]

% time_vector = [Year Month Day Hour Minute Second]

time_vector = [0 0 0 0 0 0];

time_vector(4) = d(1); % hour

time_vector(5) = d(2); % min

% seconds if given
if(length(d)==3 ||  length(d)==6)
    time_vector(6) = d(3);
end

if(length(d)<4) % only time, not date given ... assume same day
    return;
end

if(length(d)==6)
    time_vector(1) = d(6); % year
    time_vector(2) = d(4); % month
    time_vector(3) = d(5); % day
else
    time_vector(1) = d(5); % year
    time_vector(2) = d(3); % month
    time_vector(3) = d(4); % day
end

if(time_vector(1) < 2000)
    time_vector(1) = time_vector(1) + 2000;
end

return;
end
