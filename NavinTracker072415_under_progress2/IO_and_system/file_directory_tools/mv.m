function mv(oldname,newname)

newoldname = oldname(3:end);
newnewname = newname(3:end);

newoldname = strrepl(newoldname, '\\', filesep);
newoldname = strrepl(newoldname, '//', filesep);

newnewname = strrepl(newnewname, '\\', filesep);
newnewname = strrepl(newnewname, '//', filesep);

newoldname = sprintf('%s%s',oldname(1:2),newoldname);
newnewname = sprintf('%s%s',newname(1:2),newnewname);

if(file_existence(newoldname))
    movefile(newoldname,newnewname);
end

return;
