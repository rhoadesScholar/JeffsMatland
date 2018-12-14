function fit_worm_staring_script(directoryListFilename)


file_ptr = fopen(directoryListFilename,'rt');
dummystringCellArray = textscan(file_ptr,'%s');
fclose(file_ptr);
directoryList = char(dummystringCellArray{1});

for i = 1:length(directoryList(:,1))
    
    % directoryList(i,:) = filesep_convert(directoryList(i,:));
   
    strain_name = deblank(directoryList(i,:));
    
    disp([strain_name])
    pdf_file = sprintf('%s%s%s.fit.pdf',strain_name, filesep, strain_name);
    working_file = sprintf('%s%s%s.fit.working',strain_name, filesep, strain_name);
    bindata_file = sprintf('%s%s%s_1min.BinData.mat',strain_name, filesep, strain_name);
    
    if(file_existence(bindata_file))
        if(file_existence(working_file)==0)
            if(file_existence(pdf_file)==0)
            fp = fopen(working_file,'w'); fclose(fp);
            load(bindata_file);
            global_fit_BinData(BinData, [], strain_name, strain_name);
            rm(working_file);
            end
        end
    end
end

return;
end
