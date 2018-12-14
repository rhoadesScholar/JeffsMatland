function my_struct = init_struct(myfields, n)
% my_struct = init_struct(myfields)
% initiates my_struct w/ empty fields

if(nargin<2)
    n=1;
end

for(k=1:n)
    for(i=1:length(myfields))
        my_struct(k).(myfields{i}) = [];
    end
end

return;
end
