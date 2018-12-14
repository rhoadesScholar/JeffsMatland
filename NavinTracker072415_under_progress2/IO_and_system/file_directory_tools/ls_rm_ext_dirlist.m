function listout = ls_rm_ext_dirlist(ls_or_rm, directoryListFilename, extension)
% ls_rm_ext_dirlist(ls_or_rm, directoryListFilename, ext)

if(nargin < 2)
    disp('usage: ls_rm_ext_dirlist(ls_or_rm, directoryListFilename, ext)')
    return;
end

if(nargin < 3)
    extension = '*';
    if(ls_or_rm=='rm')
        disp(sprintf('Warning ... this will delete all the files in all the directories listed in %s', directoryListFilename))
        yn =  input('Are you sure you want to do this??? (y/n)\n','s');
        if(yn(1)=='n' || yn(1)=='N')
            return
        end
    end
end

if(iscell(directoryListFilename))
    file_ptr = fopen('temp','w');
    for(j=1:length(directoryListFilename))
        fprintf(file_ptr,'%s\n',directoryListFilename{j});
    end
    fclose(file_ptr);
    
    file_ptr = fopen('temp','rt');
    dummystringCellArray = textscan(file_ptr,'%s');
    fclose(file_ptr);
    delete('temp');
else
    
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
        
        file_ptr = fopen('temp','rt');
        dummystringCellArray = textscan(file_ptr,'%s');
        fclose(file_ptr);
        delete('temp');
    else
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
            dummystringCellArray = textscan(file_ptr,'%s');
            fclose(file_ptr);
        end
    end
end

directoryList = char(dummystringCellArray{1});

if(ls_or_rm=='ls')
    if(nargout>0)
        listout = [];
    end
end

if(extension(1)=='.')
    extension = extension(2:end);
end

k=1;
for i = 1:length(directoryList(:,1))
    
    % convert file paths automatically to the correct directory seperator
    directoryList(i,:) = filesep_convert(directoryList(i,:));
    
    PathName = deblank(directoryList(i,:));
    
    command = sprintf('%s(''%s%s*.%s'')', ls_or_rm, PathName, filesep,extension);
    
    % disp([command,';'])
    
    
    if(ls_or_rm=='ls')
        temp_out = eval(command);
        if(~isempty(temp_out))
            if(nargout>0)
                for(j=1:length(temp_out(:,1)))
                    listout{k} = sprintf('%s%s%s',PathName,filesep,temp_out(j,:));
                    k=k+1;
                end
            else
                for(j=1:length(temp_out(:,1)))
                    disp(sprintf('%s%s%s',PathName,filesep,temp_out(j,:)))
                end
            end
        end
        clear('temp_out');
    else
        eval(command);
    end
    
    
end

return;
end


