function age_of_file = file_age(filename)
% age_of_file = file_age(filename)
% returns 0 if file does not exist
% returns file age as datenum output for the date, not the time

age_of_file = 0;

fp_info = dir(filename);
if(isempty(fp_info))
    return;
end

file_datevec = datevec(fp_info.date);

age_of_file = datenum(file_datevec);

return;
end
