function clickGotoFrame(hObject, eventdata)
[ClickX ClickY] = clickPos(hObject, eventdata);
% display(ClickX);
% display(ClickY);

hfig = get(hObject, 'parent');
gotoFrame(hfig, round(ClickX));
