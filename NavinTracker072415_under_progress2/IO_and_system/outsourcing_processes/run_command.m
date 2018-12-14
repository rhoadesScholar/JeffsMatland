% wrapper for sending commands to the system
% deals w/ the UNC directory-name problem

function [status, result] = run_command(command)

if(isunix)
    [status, result] = system(command);
    return;
end

if(isUNC == 0) % the current directory is in the C:\ format
    [status, result] = system(command);
    return;
end

currentdir = pwd;

% change directory to tempdir (which should be non-UNC), and then come back
% to the current directory
cd(tempdir);
[status, result] = system(command);
cd(currentdir);

return;

end 
    
