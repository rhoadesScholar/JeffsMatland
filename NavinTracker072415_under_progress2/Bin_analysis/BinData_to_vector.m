function [t, v] = BinData_to_vector(BinData, fieldnames, starttime, endtime)
% function [t, v] = BinData_to_vector(BinData, fieldnames)
% collapses the fields fieldnames in BinData to a vector
% t are the times, v are the values
% use for simultaneous fits

if(nargin<2)
    fieldnames=[];
end

if(nargin<4)
    starttime=BinData.time(1);
    endtime = BinData.time(end);
end

if(isempty(fieldnames))
    [instantaneous_fieldnames, freq_fieldnames, inst_n_fields, freq_n_fields] = get_BinData_fieldnames(BinData);
    fieldnames = [instantaneous_fieldnames freq_fieldnames];
end

t=[];
v=[];


for(i=1:length(fieldnames))
   if(length(BinData.(fieldnames{i})) == length(BinData.time))
       idx = find(BinData.time >= starttime & BinData.time <= endtime);
       t = [t BinData.time(idx)];
   else
       idx = find(BinData.freqtime >= starttime & BinData.freqtime <= endtime);
       t = [t BinData.freqtime(idx)];
   end
   
   v = [v BinData.(fieldnames{i})(idx)];
end

return;
end
