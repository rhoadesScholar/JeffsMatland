function fullname = fullpath_from_filename(filename)

curDir = pwd;
[pathstr, name, ext] = fileparts(filename);
if(~isempty(pathstr))
    cd(pathstr);
end
fullpath = pwd; % full (absolute) path
cd(curDir); % get back to where you were

if(isempty(ext))
    fullname = sprintf('%s%s%s',fullpath,filesep,name);
else
    fullname = sprintf('%s%s%s%s',fullpath,filesep,name,ext);
end

return;
end
