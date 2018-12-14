function state = isfunction(functionname)

% default it is a function
state = 1;

if(exist(functionname)<=1)
   state=0; 
end

return;
end
