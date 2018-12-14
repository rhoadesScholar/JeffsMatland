function fileprefix = get_file_prefix(filename)
% fileprefix = get_file_prefix(filename)

if(nargin==0)
    disp([sprintf('usage: fileprefix = get_file_prefix(filename)\n\tfor filename = ''blahblah.fgh'', returns ''blahblah''')])
    return
end

[pathstr, fileprefix] = fileparts(filename);
[pathstr, fileprefix2] = fileparts(fileprefix);

if(strcmp(fileprefix,fileprefix2)==0)
    fileprefix = get_file_prefix(fileprefix2);
end


return;
end
