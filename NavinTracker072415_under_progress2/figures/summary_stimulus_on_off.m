function summary_stimulus_on_off(fignum, bindata_array, pre_time, on_time, off_time)

stattype = 'mean';
[instantaneous_fieldnames, freq_fieldnames] = get_BinData_fieldnames(bindata_array(1));

num_plot_rows = 5; % length(instantaneous_fieldnames) + length(freq_fieldnames);

plot_location = 0;
for(ii=1:2)
    
    if(ii==1)
        fn = instantaneous_fieldnames;
    else
        fn = freq_fieldnames;
    end
    
    for(p=1:length(fn))
        
        plot_location = plot_location + 1;
        figure_handle = [fignum  num_plot_rows 1 plot_location];
        
        attribute =  fn{p};
        [difference_matrix, std_matrix, error_matrix, n_matrix] = stimulus_on_off_difference_bargraph(figure_handle, bindata_array, attribute, stattype, pre_time, on_time, off_time);
        
        if(plot_location==num_plot_rows)
            fignum = fignum + 1;
            plot_location = 0;
        end
    end
end

return;
end


