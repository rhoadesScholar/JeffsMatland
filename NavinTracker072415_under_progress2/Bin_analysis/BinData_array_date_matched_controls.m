function BinData_array = BinData_array_date_matched_controls(experimental_dir, control_dir)
% BinData_array = BinData_array_date_matched_controls(experimental_dirs, control_dir)
% BinData_array(1) = control average BinData from the dates of the experiment
% BinData_array(2) = experimental average BinDatas

dummystring = sprintf('%s%s*.BinData.mat',experimental_dir,filesep);
fileinfo = dir(dummystring);


k=1;
for(i=1:length(fileinfo))
    if(isnumeric(fileinfo(i).name(1)))
        dates{k} = get_file_prefix(fileinfo(i).name);
        k=k+1;
    else
        experiment_filename = fileinfo(i).name;
    end
end

control_BinData_array =[];
for(k=1:length(dates))
    filenames = get_filenames_with_same_prefix_and_suffix(control_dir, dates{k}, 'BinData.mat');
    for(j=1:length(filenames))
        control_BinData_array =[control_BinData_array load_BinData(sprintf('%s%s%s',control_dir,filesep,filenames{j}))];
    end
end

BinData_array(1) = mean_BinData_from_BinData_array(control_BinData_array);

BinData_array(2) = load_BinData(experiment_filename);

return;
end
