function [ClickX ClickY] = clickPos(hObject, eventdata)
hfig = get(hObject, 'parent');
ClickPoint = get(gca,'Currentpoint');
ClickX = ClickPoint(1,1);
ClickY = ClickPoint(1,2);

return;
end