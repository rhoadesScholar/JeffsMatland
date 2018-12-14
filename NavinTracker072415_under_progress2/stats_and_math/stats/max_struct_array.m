function m = max_struct_array(inputStruct,field)
% m = max_struct_array(inputStruct,field)
% returns the max value of field in all the elements in the struct array inputStruct

if(nargin<1)
    disp('m = max_struct_array(inputStruct,field)')
    return
end

if(~isfield(inputStruct(1),field))
    m=[];
    return;
end

x=[];
for(i=1:length(inputStruct))
    x = [x max(inputStruct(i).(field))]; 
end

if(isempty(x))
    m=[];
    return;
end

m = max(x);

m=m(1);

return;

end
