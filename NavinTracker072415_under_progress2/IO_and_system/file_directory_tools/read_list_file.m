function lineList = read_list_file(filename)
% lineList = read_list_file(filename)
% lineList is a string array ... each element is a word from filename

file_ptr = fopen(filename,'rt');
dummystringCellArray = textscan(file_ptr,'%s');
fclose(file_ptr);

for i = 1:length(dummystringCellArray{1})

    % convert file paths automatically to the correct directory seperator
    elel = filesep_convert(dummystringCellArray{1}(i));
    
    lineList{i} = char(elel);

end

return;
end
