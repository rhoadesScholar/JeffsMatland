function [status, result] = launch_matlab_command(command, forkflag)
% [status, result] = launch_matlab_command(command, forkflag)
% command should be an m file in the current directory
% forkflag 0 launches a child waits for it to finish (default)
% forkflag 1 launches a child and returns to the calling function
% calling function needs to call clean_child_files to remove some tempfiles

global Prefs;
Prefs = define_preferences(Prefs);

if(nargin<2)
    forkflag=0;
end

ncp = non_core_path;

currentdir = pwd;

cd(tempdir);

pid = randint(10000);
mfile_name = sprintf('child_command_script_%d_%d.m', Prefs.PID, pid);
fp = fopen(mfile_name,'w');

fprintf(fp,'function child_command_script_%d_%d()\n\n',Prefs.PID, pid);
fprintf(fp,'desktop = com.mathworks.mde.desk.MLDesktop.getInstance;');
fprintf(fp,'desktop.restoreLayout(''All but Command Window Minimized'');');
fprintf(fp,'cd %s;\n',currentdir);
fprintf(fp,'restoredefaultpath;\n');
fprintf(fp,'addpath ''%s''\n',ncp);
fprintf(fp,'global Prefs; Prefs=[];\n');
fprintf(fp,'%s;\n',command);
fprintf(fp,'exit;\n');
fprintf(fp,'end\n');
fprintf(fp,'\n');

fclose(fp);

cat_text_files(mfile_name,which('non_core_path'),mfile_name);


if(forkflag==0) % launch child and wait for the child to finish
    syscommand = sprintf('%s child_command_script_%d_%d',Prefs.matlab_exec_path,Prefs.PID,pid);
    
    disp([sprintf('launched child MATLAB process for %s\t%s',command, timeString())])
    
    tic
    [status, result] = run_command(syscommand);
    disp([sprintf('child process completed %s',timeString())])
    toc
    
    rm(mfile_name);
    
    
else % launch child and return to the calling function while the child is running
    syscommand = sprintf('%s child_command_script_%d_%d &',Prefs.matlab_exec_path,Prefs.PID,pid);
    disp([sprintf('launched child MATLAB process %s',timeString())])
    [status, result] = run_command(syscommand);
end

cd(currentdir);

return;

end
   