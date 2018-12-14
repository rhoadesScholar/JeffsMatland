function fitting_master(bindata_file_list_filename, stimulus)  

global Prefs;
Prefs = define_preferences(Prefs);

if(nargin<2)
   stimulus = [];
else
    if(~isnumeric(stimulus))
        stimulus = load_stimfile(stimulus);
    end
end

file_ptr = fopen(bindata_file_list_filename,'rt');

if(file_ptr == -1) % is directory not file
    file_ptr = fopen('temp.txt','w');
    fprintf(file_ptr,'%s\n',bindata_file_list_filename);
    fclose(file_ptr);
    
    file_ptr = fopen('temp.txt','rt');
    dummystringCellArray = textscan(file_ptr,'%s');
    fclose(file_ptr);
    bindata_filelist = char(dummystringCellArray{1});
    rm('temp.txt');
else
    dummystringCellArray = textscan(file_ptr,'%s');
    fclose(file_ptr);
    bindata_filelist = char(dummystringCellArray{1});
end

for i = 1:length(bindata_filelist(:,1))
    
    [localpath, prefix, ext] = fileparts(bindata_filelist(i,:));
    
    if(~isempty(localpath))
        if(localpath(end)~=filesep)
            localpath(end+1) = filesep;
        end
        localpath = filesep_convert(localpath);
        
        prefix = prefix_from_path(localpath);
    else
        [localpath, prefix, ext] = fileparts(prefix);
        [localpath, prefix, ext] = fileparts(prefix);
        localpath = '';
    end
    
    working_file = sprintf('%s.fit.working',prefix);
    bindata_file = sprintf('%s.psth.BinData.mat',prefix);
        
    fit_file = sprintf('%s.fit.pdf',prefix);
    
    disp([bindata_file])
   
    cwd = pwd;
    
    if(~isempty(localpath))
        cd(localpath);
    end
    
    if(file_existence(bindata_file))
        if(file_existence(working_file)==0)
            fp = fopen(working_file,'w'); fclose(fp);
            BinData = load_BinData(bindata_file,'-mat');
            if(file_existence(fit_file)==0)
                global_fit_BinData(BinData, stimulus, '', prefix);
            else
                load(sprintf('%s.fit_structs.mat',prefix));
                load(sprintf('%s.fitting_struct.mat',prefix));
                master_plot_fitting_struct(fit_structs, fitting_struct, stimulus, '', prefix);
                clear('fit_structs');
                clear('fitting_struct');
            end
            rm(working_file);
        end
    end
    
    cd(cwd);
end

return;
end
