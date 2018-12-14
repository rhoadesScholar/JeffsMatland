function h = rasterx(xdata,yrange, color)

h = [];
for i = 1:length(xdata)
    hl = line(repmat(xdata(i),1,2),yrange,'Color',color, 'LineWidth',1);
    h = [h hl];
end

return;
end

