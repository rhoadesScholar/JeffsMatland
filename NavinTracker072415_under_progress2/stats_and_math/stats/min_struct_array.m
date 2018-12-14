function m = min_struct_array(inputStruct,field)
% m = min_struct_array(inputStruct,field)
% returns the min value of field in all the elements in the struct array inputStruct

if(nargin<1)
    disp('usage: m = min_struct_array(inputStruct,field)');
    return
end

if(~isfield(inputStruct,field))
    m=[];
    return;
end

x=[];
for(i=1:length(inputStruct))
    x = [x min(inputStruct(i).(field))]; 
end

if(isempty(x))
    m=[];
    return;
end

m = min(x);

m=m(1);

return;

end
