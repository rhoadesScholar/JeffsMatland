function rm(filename)

warning off all

delete(filename);
return;



% % file does not exist
% if(file_existence(filename)==0)
%     return;
% end

% [actualfilename, path] = filename_from_partialpath(filename);
% 
% topdir = pwd;
% 
% if(~isempty(strfind(path,'*')))
%     staridx = strfind(path,'*');
%     
%     for(i=1:length(staridx))
%         d = path(1:staridx(i)-1);
%         cd(d);
%         localdirlist = ls('*');
%         s=size(localdirlist);
%         level2dir = pwd;
%         for(j=1:s(1))
%             if(isdir(localdirlist(j,:)))
%                 if(strcmp(localdirlist(j,:),'.')==0 && strcmp(localdirlist(j,:),'..')==0 )
%                     cd(localdirlist(j,:));
%                     rm(actualfilename);
%                     cd(level2dir);
%                 end
%             end
%         end
%         cd('../');
%     end
%     cd(topdir);
%     return;
% end
% 
% if(~isempty(path))
%     cd(path);
% end
% 
% delete(actualfilename);
% cd(topdir);

return;
end
