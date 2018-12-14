% returns 1 if the current path is in the UNC (Universal Naming Convention) format

function state = isUNC() 

path = pwd;

state = 0;

if(path(1) == '\' || path(1) == '/') 
    state = 1;
    return;
end

return;
 
end
