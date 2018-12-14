function errorbar_bargraph(x, y, y_err, cmap)
% function errorbar_bargraph(x, y, y_err, cmap)

if(nargin<4)
    cmap = colormap('jet');
end

bar_h=bar(x,y);
bar_child=get(bar_h,'Children');
set(bar_child,'CData',x);
hold on;
errorbar(x,y,y_err,'k.','MarkerSize',eps)
colormap(cmap);

hold off;

return;
end

