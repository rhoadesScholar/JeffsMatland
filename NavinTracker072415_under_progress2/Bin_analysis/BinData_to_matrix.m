function v = BinData_to_matrix(BinData, fieldnames, starttime, endtime)
% function v = BinData_to_matrix(BinData, fieldnames)
% collapses the fields fieldnames in BinData to a matrix
% v is the values matrix; each row is a attribute
% use for PCA

if(nargin<2)
    fieldnames=[];
end

if(nargin<4)
    starttime=BinData(1).time(1);
    endtime = BinData(1).time(end);
end

% actually a BinData array, so create seperate matrix for each fieldname
if(length(BinData)>1)
   v = [];
   for(i=1:length(BinData))
       m = BinData_to_matrix(BinData(i), fieldnames, starttime, endtime);
       for(j=1:size(m,1))
          v(i,:,j) = m(j,:);  
       end
   end
   return
end

if(isempty(fieldnames))
    [instantaneous_fieldnames, freq_fieldnames, inst_n_fields, freq_n_fields] = get_BinData_fieldnames(BinData);
    fieldnames = [instantaneous_fieldnames freq_fieldnames];
end

v=[];

for(i=1:length(fieldnames))
   if(length(BinData.(fieldnames{i})) == length(BinData.time))
       idx = find(BinData.time >= starttime & BinData.time <= endtime);
   else
       idx = find(BinData.freqtime >= starttime & BinData.freqtime <= endtime);
   end
   
   v = [v; BinData.(fieldnames{i})(idx)];
end

return;
end
