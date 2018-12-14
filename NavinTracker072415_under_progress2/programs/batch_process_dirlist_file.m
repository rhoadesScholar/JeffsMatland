function batch_process_dirlist_file(functionname, directoryListFilename, vargin)
% function batch_process_dirlist_file(functionname, directoryListFilename, vargin)

if(nargin < 2)
    disp('usage: batch_process_dirlist_file(functionname, directoryListFilename, vargin)')
    return;
end

file_ptr = fopen(directoryListFilename,'rt');

if(file_ptr == -1) % directoryListFilename is not an actual file, but is a directory
    
    file_ptr = fopen('temp','w');
    fprintf(file_ptr,'%s\n',directoryListFilename);
    fclose(file_ptr);
    
    file_ptr = fopen('temp','rt');
    dummystringCellArray = textscan(file_ptr,'%s');
    fclose(file_ptr);
    delete('temp');
else % is a file
    
    [pathstr, FilePrefix, ext] = fileparts(directoryListFilename);

    if(strcmp(ext,'.avi')==1) % is a single avi file
        fclose(file_ptr);
       
        if(nargin>2)
            command = sprintf('%s(''%s'', %s);', functionname, directoryListFilename, vargin);
        else
            command = sprintf('%s(''%s'');', functionname, directoryListFilename);
        end
        
        eval(command);
        
        return;
    else % is a bona fide directory list file
        dummystringCellArray = textscan(file_ptr,'%s');
        fclose(file_ptr);
    end
end

directoryList = char(dummystringCellArray{1});

for i = 1:length(directoryList(:,1))
    
    % convert file paths automatically to the correct directory seperator
    directoryList(i,:) = filesep_convert(directoryList(i,:));
    
    PathName = deblank(directoryList(i,:));
    
    if(nargin>2)
        command = sprintf('%s(''%s'', %s);', functionname, PathName, vargin);
    else
        command = sprintf('%s(''%s'');', functionname, PathName);
    end
    
    disp([command]);
    eval(command);
        
end

return;
end

