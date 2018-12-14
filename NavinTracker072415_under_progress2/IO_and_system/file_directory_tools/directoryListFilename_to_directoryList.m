function directoryList = directoryListFilename_to_directoryList(directoryListFilename)
% directoryList = directoryListFilename_to_directoryList(directoryListFilename))
% converts directoryListFilename (either a file listing directories or the
% target directory itself) to the actual list of directories directoryList matrix 

if(directoryListFilename=='*')
    file_ptr = fopen('temp','w');
    x = dir;
    for(i=1:length(x))
        if(x(i).isdir == 1 && strcmp(x(i).name,'.')==0 && strcmp(x(i).name,'..')==0)
            fprintf(file_ptr,'%s\n',x(i).name);
        end
    end
    clear('x');
    
    fclose(file_ptr);
    
    dummyname = tempname;
    file_ptr = fopen(dummyname,'rt');
    dummystringCellArray = textscan(file_ptr,'%s');
    fclose(file_ptr);
    delete(dummyname);
    clear('dummyname');
else
    file_ptr = fopen(directoryListFilename,'rt');
    if(file_ptr == -1) % directoryListFilename is not an actual file, but is a directory
        
        dummyname = tempname;
        
        file_ptr = fopen(dummyname,'w');
        fprintf(file_ptr,'%s\n',directoryListFilename);
        fclose(file_ptr);
        
        
        file_ptr = fopen(dummyname,'rt');
        dummystringCellArray = textscan(file_ptr,'%s');
        fclose(file_ptr);
        delete(dummyname);
        clear('dummyname');
    else % is a file
        dummystringCellArray = textscan(file_ptr,'%s');
        fclose(file_ptr);
    end
end
directoryList = char(dummystringCellArray{1});

% convert file paths  to the correct directory seperator
for i = 1:length(directoryList(:,1))
    directoryList(i,:) = deblank(filesep_convert(directoryList(i,:)));
end

return;
end

