function f = file_existence(filename)
% f = file_existence(filename) 0 if does not exist, 1 if it does

f = fopen(filename,'r');
if(f==-1) % file does not exist
   f=0;
   return;
end

fclose(f);
f = 1;
return;


return;



% f = exist(filename);
% 
% if(f == 2) % file exists 
%     f=1;
%     return;
% end
% 
% f = 0; % file does not exist, or it is a directory
% 
% % wait 1 sec and try again
% pause(1);
% f = exist(filename);
% 
% if(f == 2) % file exists 
%     f=1;
%     return;
% end
% f = 0; % file does not exist, or it is a directory


