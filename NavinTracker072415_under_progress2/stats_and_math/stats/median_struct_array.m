function m = median_struct_array(inputStruct,field)
% m = median_struct_array(inputStruct,field)
% returns the median value of field in all the elements in the struct array inputStruct

if(~isfield(inputStruct,field))
    m=[];
    return;
end

x=[];
for(i=1:length(inputStruct))
    x = [x inputStruct(i).(field)]; 
end

m = nanmedian(x);

m=m(1);

return;

end
