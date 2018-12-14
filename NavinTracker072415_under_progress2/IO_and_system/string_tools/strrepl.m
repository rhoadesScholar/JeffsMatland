
function result = strrepl(origstr, findstr, replstr)

findlen = length(findstr);
origlen = length(origstr);

startch = strfind(origstr,findstr);

if length(startch) > 0
    endch = startch+findlen-1;
    result = [origstr(1:startch-1), replstr, origstr(endch+1:origlen)];
else
    result = origstr;
end

    
