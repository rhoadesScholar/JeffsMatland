function current_dirname = current_directory
% current_dirname = current_directory
% returns just the name of the current directory
% example:
% >> cd D:\under_progress2\Tracking
% >> current_directory
% ans =
% Tracking

dirpath = '';

dirpath = pwd;
i= length(pwd);
while(dirpath(i)~=filesep)
    i = i-1;
end
i=i+1;
current_dirname = dirpath(i:end);

return;
end