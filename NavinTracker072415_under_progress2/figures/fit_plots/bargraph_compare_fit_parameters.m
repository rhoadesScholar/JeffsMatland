function h = bargraph_compare_fit_parameters(fitting_struct_array, colors, parameter_name)

bw_legend = [];
bw_title = '';
bw_xlabel = '';
bw_ylabel = parameter_name;

units='';
if(regexpi(bw_ylabel,'speed'))
    units = 'mm/sec';
else
    if(regexpi(bw_ylabel,'freq'))
        units = '/min';
    else
        if(regexpi(bw_ylabel,'angle'))
            units = 'degrees';
        end
    end
end
bw_ylabel = fix_title_string(sprintf('%s\n(%s)',bw_ylabel, units));

idx = find_string_in_cell_array(fitting_struct_array(1).f.param, parameter_name);

if(isempty(idx))
    error(sprintf('Cannot find %s parameter_name input to bargraph_compare_fit_parameters', parameter_name));
    return;
end

barvalues = [];
barerrors = [];
cmap = [];
for(i=1:length(fitting_struct_array))
    barvalues = [ barvalues fitting_struct_array(i).un_norm_m_avg(idx) ];
    barerrors = [ barerrors fitting_struct_array(i).un_norm_m_std(idx) ];
    
    if(ischar(colors{i}))
        cmap = [cmap; str2rgb(colors{i})];
    else
        cmap = [cmap; colors{i} ];
    end
end

% errorline(1:length(fitting_struct_array), barvalues, barerrors,'.');

for(i=1:length(fitting_struct_array))
    strainnames{i} = fitting_struct_array(i).Name;
end

barweb(barvalues, barerrors, 1, strainnames, bw_title, bw_xlabel, bw_ylabel, cmap, bw_legend);

return;
end
