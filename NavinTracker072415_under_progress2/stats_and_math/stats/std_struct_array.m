function m = std_struct_array(inputStruct,field)
% m = std_struct_array(inputStruct,field)
% returns the std_dev of field in all the elements in the struct array inputStruct

if(~isfield(inputStruct,field))
    m=[];
    return;
end

x=[];
for(i=1:length(inputStruct))
    x = [x inputStruct(i).(field)]; 
end

m = nanstd(x);

m=m(1);

return;

end
