function old_file_flag = does_this_file_need_making(filename, inp_target_date)
% old_file_flag = does_this_file_need_making(filename, inp_target_date)
% returns 0 if the file is newer than target_date; 1 if it is older
% default inp_target_date is '9/15/10'


target_date=[];
if(nargin<2)
    inp_target_date = '11/8/10';
end

 

dummystring = strrep(inp_target_date, '/', ' ');
dummystring = strrep(dummystring, '_', ' ');
dummystring = strrep(dummystring, '.', ' ');

d = sscanf(dummystring, '%d');

target_date(1) = d(3);
target_date(2) = d(1);
target_date(3) = d(2);
target_date(4) = 0;
target_date(5) = 0;
target_date(6) = 0;
if(target_date(1) < 2000)
    target_date(1) = target_date(1) + 2000;
end

tdate = datenum(target_date);

old_file_flag = 0;

fdate = file_age(filename);

if(fdate < tdate)
    old_file_flag=1;
    return
end


return;
end
