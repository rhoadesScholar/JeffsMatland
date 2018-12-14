function [m, field_array] = mean_struct_array(inputStruct,field)
% [m, field_array] = mean_struct_array(inputStruct,field)
% returns the mean value m of field in all the elements in the struct array inputStruct
% field_array has the actual values

if(nargin<1)
    disp([sprintf('[m, field_array] = mean_struct_array(inputStruct,field)')])
    disp([sprintf('returns the mean value of field in all the elements in the struct array inputStruct')])
    disp([sprintf('field_array has the actual values')])
    return
end

if(~isfield(inputStruct,field))
    m=[];
    return;
end

field_array=[];
for(i=1:length(inputStruct))
    field_array = [field_array inputStruct(i).(field)];
end

m = nanmean(field_array);

m=m(1);

return;

end
