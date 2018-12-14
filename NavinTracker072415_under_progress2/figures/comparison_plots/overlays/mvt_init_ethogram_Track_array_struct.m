function [hh, ymax] = mvt_init_ethogram_Track_array_struct(Track_array_struct, colors, stimulus, plot_rows, plot_columns, plot_location, mvt, xaxis_vector)

hh=[];
ymax=[];
warning('mvt_init_ethogram_Track_array_struct is deprecated');
return;

ymin=1e10;
ymax=1e10;
for(i=1:length(Track_array_struct))
    [hh, ymax_current] = mvt_init_ethogram(Track_array_struct(i).Tracks, stimulus, plot_rows, plot_columns, plot_location, mvt, colors{i}, xaxis_vector);
    if(ymax_current < ymax)
        ymax = ymax_current;
    end
    
    if(min_struct_array(Track_array_struct(i).Tracks,'Frames') < ymin)
        ymin = min_struct_array(Track_array_struct(i).Tracks,'Frames');
    end
    
    hold on;
end

ylim([ymin ymax]);

set(gca, 'color', 'none');

return;
end
