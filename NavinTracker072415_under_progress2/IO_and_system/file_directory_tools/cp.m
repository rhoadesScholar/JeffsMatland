function cp(oldname,newname)

copyfile(oldname,newname);

% if ispc
%     dummy = sprintf('copy %s %s',oldname,newname);
%     dos(dummy);
% else
%     dummy = sprintf('cp %s %s',oldname,newname);
%     unix(dummy);
% end

return;
end
