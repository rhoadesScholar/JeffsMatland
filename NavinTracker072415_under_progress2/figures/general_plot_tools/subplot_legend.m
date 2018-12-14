function h = subplot_legend(legend_text, legend_colors, plot_rows, plot_columns, plot_location, varargin)

h = subplot(plot_rows, plot_columns, plot_location(1));

box_flag=1;
linestyle_text = '''linewidth'',2' ;

i=1;
while(i<=length(varargin))
    if(strcmpi(varargin(i),'box')==1)
        i=i+1;
        if(strcmpi(varargin(i),'on')==1)
            box_flag=1;
        else
            box_flag=0;
        end
        i=i+1;
    else
        if(strcmpi(varargin(i),'linestyle')==1)
            i=i+1;
            linestyle_text = varargin(i);
            i=i+1;
        else
            if(strncmpi(varargin(i),'len',3)==1)
               i=i+1;
               seglength = varargin(i);
               i=i+1;
            end
        end
    end
end

if(length(legend_text) ~= length(legend_colors))
    error('number of elements for legend_text and legend_colors must be equal');
    return;
end


for(i=1:length(legend_text))
    cmd = sprintf('plot([0,0],[0.1,0.1],''color'',legend_colors{i},');
    cmd = sprintf('%s%s)',cmd,linestyle_text);
    
    eval(cmd);

    hold on;
end
axis([0 1 0 1]);

for(i=1:length(legend_text))
    new_legend_text{i} = fix_title_string(legend_text{i});
end
legend(new_legend_text);

set(gca,'ytick',[]);
set(gca,'xtick',[]);

box off;
% set(h,'YColor','w');
% set(h,'XColor','w');
% plot([1 0],[0 0],'w');
% plot([0 0],[0 1],'w');

if(box_flag==0)
   legend('boxoff'); 
end

axis off;

set(gca, 'color', 'none');

return;
end
