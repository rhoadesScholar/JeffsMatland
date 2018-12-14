function [difference_matrix, std_matrix, error_matrix, n_matrix] = stimulus_on_off_difference_bargraph(figure_handle, bindata_array, attribute, ...
    stattype, pre_time, on_time, off_time, inputcolors)
% [difference_matrix, std_matrix, error_matrix, n_matrix] = stimulus_on_off_difference_bargraph(figure_handle, bindata_array, attribute, stattype, ...
%                                                   pre_time, on_time, off_time, inputcolors)


colors = [];
if(nargin<8)
    colors(1,:) = [0 1 1]; % cyan for on
    color_end_index = 2;
    colors(color_end_index,:) = [0.7 0.7 0.7]; % gray for off
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

for(i=1:length(BinData_array)) 
    strainnames{i} = BinData_array(i).Name;
end

t = [pre_time; on_time; off_time ];
[barvalues, barstd, barerrors, barn] = comparative_bargraph(0, bindata_array, attribute, stattype, t);


difference_matrix=[];
error_matrix=[];
std_matrix = [];

legend_names{1} = sprintf('ON response'); cmap(1,:) =  colors(1,:);
legend_names{2} = sprintf('OFF response'); cmap(2,:) =  colors(2,:);

for(i=1:length(strainnames))
    
    % j=2 for on - pre
    % j=3 for off - pre
    for(j=2:3)
        k=j-1;
        difference_matrix(i,k) = barvalues(i,j)-barvalues(i,1);
        error_matrix(i,k) = sqrt(barerrors(i,1)^2 + barerrors(i,j)^2);
        std_matrix(i,k) = sqrt(barstd(i,1)^2 + barstd(i,j)^2);
        
        n_matrix(i,k) = round((barn(i,1)+barn(i,j))/2);
        
        if(j==3)
            disp([sprintf('%s\t\t%f\t%f\t%d\t%f',strainnames{i}, difference_matrix(i,2), std_matrix(i,2), n_matrix(i,2), error_matrix(i,2))])
        end
    end
end


if(figure_handle>0)
    figure(figure_handle(1));
    if(length(figure_handle)>1)
        subplot(figure_handle(2),figure_handle(3),figure_handle(4));
    end
    
    if(length(t(:,1))>1)
        barweb(difference_matrix, error_matrix, 1, strainnames, '', '', '', cmap, []);
    else
        errorbar_bargraph(1:length(strainnames), difference_matrix, error_matrix, cmap);
        set(gca, 'xticklabel', strainnames, 'box', 'off', 'ticklength', [0 0],  'xtick',1:length(strainnames));
    end
    
    set(gca,'XTickLabel',strainnames);
    
    % title(fix_title_string(attribute),'FontSize',18,'FontName','Helvetica','HorizontalAlignment','center');  % 3.5,0.95,
    
    ylabelstring = sprintf('delta\n%s',fix_title_string(attribute));
    ylabel(ylabelstring);
    
    xlabelstring = fix_title_string('strain');
    hx = xlabel(xlabelstring);
    fontsize = scaled_fontsize_for_subplot(figure_handle(2),figure_handle(3));
    set(gca,'FontSize',fontsize);
    set(hx,'FontSize',fontsize);
    
    % figure_handle = legend(legend_names, 'Location','best');
    % set(figure_handle,'Interpreter','none');
end

return;
end
