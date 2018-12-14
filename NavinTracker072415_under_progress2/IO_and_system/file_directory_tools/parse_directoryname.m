% find all the files w/ suffix in the directory, or in the list of
% directories in the directoryListFilename file ...returns a cell array
% whos elements are the names of the relevant files in the specified
% directories

function filelist = parse_directoryname(directoryListFilename, suffix)

file_ptr = fopen(directoryListFilename,'rt');

if(file_ptr == -1) % directoryListFilename is not an actual file, but is a directory
    file_ptr = fopen('temp','w');
    fprintf(file_ptr,'%s\n',directoryListFilename);
    fclose(file_ptr);

    file_ptr = fopen('temp','rt');
    dummystringCellArray = textscan(file_ptr,'%s');
    fclose(file_ptr);
    delete('temp');
else % is a file that lists directories
    [pathstr, FilePrefix, ext] = fileparts(directoryListFilename);
    dummystringCellArray = textscan(file_ptr,'%s');
    fclose(file_ptr);
end

directoryList = char(dummystringCellArray{1});

fL=0;
for(i=1:length(directoryList(:,1)))

    % convert file paths automatically to the correct directory seperator
    directoryList(i,:) = filesep_convert(directoryList(i,:));

    PathName = deblank(directoryList(i,:));
    dummystring = sprintf('%s%s*%s',PathName,filesep,suffix);
    dirfilelist = dir(dummystring);
    
    for(j=1:length(dirfilelist))
        fL=fL+1;
        filelist{fL} = sprintf('%s%s%s',PathName,filesep,dirfilelist(j).name);
    end
    
end

return;
end
