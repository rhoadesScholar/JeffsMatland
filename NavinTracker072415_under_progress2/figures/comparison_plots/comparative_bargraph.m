function [barvalues, barstd, barerrors, barn] = comparative_bargraph(figure_handle, bindata_array, attribute, stattype, t_vector, inputcolors)
% [barvalues, barstd, barerrors, barn] = comparative_bargraph(figure_handle, bindata_array, attribute, stattype, t_vector, inputcolors)

for(i=1:length(bindata_array))
    strainnames{i} = bindata_array(i).Name;
end

t = t_vector;

colors = [];
if(nargin<6)
    colors(1,:) = [0.7 0.7 0.7]; 
    color_end_index = 2;
    colors(color_end_index,:) = [0.7 0.7 0.7]; 
else
    color_end_index = length(inputcolors);
    for(i=1:length(inputcolors))
        if(ischar(inputcolors{i}))
            colors(i,:) =  str2rgb(inputcolors{i});
        else
            colors(i,:) = inputcolors{i};
        end
    end
end

for(i=1:length(strainnames))
    
    
    for(j=1:length(t(:,1)))
        
        [barvalues(i,j), barstd(i,j), barerrors(i,j), barn(i,j)] = segment_statistics(bindata_array(i), attribute, stattype, t(j,1), t(j,2));

        if(j >= color_end_index)
            cmap(j,:)  = colors(color_end_index,:);
        else
            cmap(j,:) =  colors(j,:);
        end

        legend_names{j} = sprintf('%.1f-%.1f',t(j,1), t(j,2));
        
    end

    if(figure_handle>0)
        disp([sprintf('%s\t\t%f\t%f\t%d\t%f',strainnames{i}, barvalues(i), barstd(i), barn(i), barerrors(i))])
    end
    
end

if(figure_handle>0)
    figure(figure_handle(1));
    if(length(figure_handle)>1)
        subplot(figure_handle(2),figure_handle(3), figure_handle(4));
    end
    
    if(length(t(:,1))>1)
        barweb(barvalues, barerrors, 1, strainnames, '', '', '', cmap, []);
    else
        errorbar_bargraph(1:length(strainnames), barvalues, barerrors, cmap);
        set(gca, 'xticklabel', strainnames, 'box', 'off', 'ticklength', [0 0],  'xtick',1:length(strainnames));
    end
    
    set(gca,'XTickLabel',strainnames);
    
    % title(fix_title_string(attribute),'FontSize',18,'FontName','Helvetica','HorizontalAlignment','center');  % 3.5,0.95,
    
    ylabelstring = sprintf('%s',fix_title_string(attribute));
    ylabel(ylabelstring);
    
    xlabelstring = fix_title_string('strain');
    hx = xlabel(xlabelstring);
    if(length(figure_handle)>1)
        fontsize = scaled_fontsize_for_subplot(figure_handle(2),figure_handle(3));
        set(gca,'FontSize',fontsize);
        set(hx,'FontSize',fontsize);
    end
    xticklabel_rotate([],45,[],'interpreter','none');
    
    % figure_handle = legend(legend_names, 'Location','best');
    % set(figure_handle,'Interpreter','none');
end

return;
end
