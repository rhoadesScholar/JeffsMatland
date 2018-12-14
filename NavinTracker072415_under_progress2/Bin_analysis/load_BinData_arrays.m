function [bindata_array, strainnames] = load_BinData_arrays(filename)
% [bindata_array, strainnames] = load_BinData_arrays(filename)
% filename file has the following format for each line
% label   blah.BinData.mat


if(iscell(filename))
    if(length(filename)>1)
        for(i=1:length(filename))
            bindata_array(i) = (load_BinData(filename{i})); 
            strainnames{i} = bindata_array(i).Name;
        end
        return;
    else
        f = filename{1};
        clear('filename');
        filename = f;
    end
end

if(~isempty(strfind(filename,'BinData_array.mat')))
    load(filename);
    
    if(exist('psth_BinData_array','var'))
        BinData_array = psth_BinData_array;
        clear('psth_BinData_array');
    end
    
    bindata_array = update_old_BinData(BinData_array);
    
    for(i=1:length(bindata_array))
        strainnames{i} = bindata_array(i).Name;
    end
    
    return;
end


file_ptr = fopen(filename,'rt');

tline = fgetl(file_ptr);
i=0;
while ischar(tline)

    words = words_from_line(tline);

    if(file_existence(words{2})==1)

        i=i+1;
        
        bindatafile = words{1};
        bindata_array(i) = load_BinData(bindatafile); % load(bindatafile);
        strainnames{i} = bindata_array(i).Name;
        
    end

    tline = fgetl(file_ptr);
end

fclose(file_ptr);

return;
end
