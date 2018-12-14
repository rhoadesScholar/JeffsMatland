function h = blank_subplot(plot_rows,plot_columns,plot_number)

h=subplot(plot_rows,plot_columns,plot_number);

set(h,'YTick',[]); 
set(h,'YColor','w'); 
set(h,'XTick',[]); 
set(h,'XColor','w'); 
box off

return;
end
