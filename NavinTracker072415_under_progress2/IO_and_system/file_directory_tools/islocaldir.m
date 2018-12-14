function islocal = islocaldir(inputname)

if(nargin<1)
    inputname = pwd;
end

filename = fullpath_from_filename(inputname);

if(ismac)
    islocal = 0;
    if(isempty(strfind(filename,'Volumes')))
        islocal = 1;
    end
    return;
end

if(filename(1)=='\' || filename(1)=='/')
    islocal = 0;
else
    islocal = 1;
end

return;
end
