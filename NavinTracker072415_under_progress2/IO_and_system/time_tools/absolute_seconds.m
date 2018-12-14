% returns the number of seconds since CLOCK_ZERO 12-Jan-2012 13:41:59 
% clock vector t

function a = absolute_seconds(t)

month_days = [0 31 29 31 30 31 30 31 31 30 31 30];

a = 365*24*3600*(t(1)-2012) + month_days(uint64(t(2)))*24*3600 + (t(3)-1)*24*3600 +  t(4)*3600 + t(5)*60 + t(6);

% a = t(4)*3600 + t(5)*60 + t(6);

return;
end
