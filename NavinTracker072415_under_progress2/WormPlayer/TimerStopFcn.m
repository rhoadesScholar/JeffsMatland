function TimerStopFcn(hco, user) %hbutton, eventStruct, hfig)

ud = get(hco,'userdata');     % hco = timer object
hfig = ud.hfig;

playMovie('', '', hfig);

end