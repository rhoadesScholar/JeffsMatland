function clean_child_files

global Prefs;

currentdir = pwd;

cd(tempdir);

dummystring = sprintf('child_command_script_%d_*',Prefs.PID);

child_file_names = ls(dummystring);

for(i=1:length(child_file_names(:,1)))
    rm(child_file_names(i,:)); 
end

cd(currentdir);

return;
end
