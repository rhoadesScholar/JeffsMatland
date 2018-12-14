function summary_directory_attribute(dirname, attribute, stat_type, timerange)
% summary_directory_attribute(dirname, attribute, stat_type, timerange)
% attribute = 'speed', 'body_angle', 'Rev_freq', etc
% stat_type = 'mean', 'max', or 'min'
% timerange = time window of interest (default over the entire range
% tab-delimited file in dirname.attribute.txt
% example: summary_directory_attribute('sra6_chop', 'Rev_freq') output in sra6_chop.summary.Rev_freq.txt


if(isempty(dirname))
    dirname = pwd;
end

if(nargin<2)
    attribute = 'speed';
end

if(nargin<3)
    stat_type = 'mean';
end

if(nargin<4)
    timerange = [0 1e6];
end

t1 = timerange(1); 
t2 = timerange(2); 

BinData_array = load_BinData_arrays(sprintf('%s%s%s',dirname,filesep,ls(sprintf('%s%s*avg.BinData_array.mat',dirname,filesep))));
    
t2 = min(t2, max_struct_array(BinData_array,'time'));

dummystring = sprintf('%s.summary.%s.txt',dirname,attribute);
file_ptr = fopen(dummystring,'wt');

fprintf(file_ptr,'name\t%s %s %.1f to %.1f sec\tstd. dev.\tnum animals\n',stat_type, attribute,t1, t2);

[value, stddev, ~, ~] = segment_statistics(BinData_array, attribute, stat_type, t1, t2);
n=0;
for(i=1:length(BinData_array))
    index = find(BinData_array(i).time >= t1  &  BinData_array(i).time <= t2);
    n = n + ceil(nanmean(BinData_array(i).n(index)));
end

fprintf(file_ptr,'%s\t%f\t%f\t%d\n','average',value,stddev,n);

for(i=1:length(BinData_array))
    [value, stddev, ~, ~] = segment_statistics(BinData_array(i), attribute, stat_type, t1, t2);
    index = find(BinData_array(i).time >= t1  &  BinData_array(i).time <= t2);
    n = ceil(nanmean(BinData_array(i).n(index)));
    fprintf(file_ptr,'%s\t%f\t%f\t%d\n',BinData_array(i).Name,value,stddev,n);
end

fclose(file_ptr);

return;
end
