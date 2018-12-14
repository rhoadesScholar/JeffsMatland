function listout = append_field_to_struct_ext_dirlist(directoryListFilename, extension, targetfieldname, defaultvalue)
% listout = append_field_to_struct_ext_dirlist(directoryListFilename, extension, targetfieldname, defaultvalue)

if(nargout > 0)
    listout = [];
end

if(nargin < 3)
    disp('usage: append_field_to_struct_ext_dirlist(directoryListFilename, extension, targetfieldname, defaultvalue)')
    return;
end

if(isnumeric(defaultvalue))
    dummy = defaultvalue;
    clear('defaultvalue');
    defaultvalue = num2str(dummy);
    clear('dummy');
end

% add ".mat" to extension if not already there
if(isempty(strfind(extension,'.mat')))
    extension = sprintf('%s.mat',extension);
end

directoryList = directoryListFilename_to_directoryList(directoryListFilename);

for i = 1:length(directoryList(:,1))
    PathName = directoryList(i,:); 
    
    dummystring = sprintf('%s%s*.%s',PathName,filesep, extension);
    filelist = dir(dummystring);
    
    
    for j=1:length(filelist)
        
        
        filename = sprintf('%s%s%s',PathName,filesep,filelist(j).name);
        
        wh = whos('-file',filename);
        structname = wh.name;
        struct_array_length = wh.size(1)*wh.size(2);
        clear('wh');
        
        load(filename);
        
        
        for(r=1:struct_array_length)
            command = sprintf('~isfield(%s(%d),''%s'')',structname,r,targetfieldname);
            if(eval(command))
                command = sprintf('%s(%d).%s = %s;',structname, r, targetfieldname, defaultvalue);
                eval(command);
            else
                command = sprintf('isempty(%s(%d).%s)',structname,r,targetfieldname);
                if(eval(command))
                    command = sprintf('%s(%d).%s = %s;',structname, r, targetfieldname, defaultvalue);
                    eval(command);
                end
            end
        end
        
        save(filename, structname);
        
        clear(structname);
        command = sprintf('clear(''%s'');', structname);
        eval(command);
        
    end

end

return;
end
