function touch(input_filename)

currentdir = pwd;

[pathstr, FilePrefix, ext] = fileparts(input_filename);

filename = FilePrefix;
if(~isempty(ext))
    filename = sprintf('%s%s',FilePrefix,ext);
end
if(isempty(pathstr))
    pathstr = pwd;
end

cd(pathstr);
targetdir = pwd;

cd(tempdir);
command = sprintf('touch %s',filename);
run_command(command);

newname = sprintf('%s%s%s',targetdir, filesep, filename);
mv(filename,newname);

cd(currentdir);

return;
end
