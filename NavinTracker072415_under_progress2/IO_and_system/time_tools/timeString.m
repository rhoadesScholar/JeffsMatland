% returns a string with the current time and date
% format: 12:18:22 12/13/2007
% with datestr format: 28-Mar-2005 15:36:23

function clockString = timeString()

clockString = datestr(now);

% currentTime = fix(clock);
% if(currentTime(6) < 10)
%     secString = sprintf('0%d',currentTime(6));
% else
%     secString = sprintf('%d',currentTime(6));
% end    
% 
% if(currentTime(5) < 10)
%     minString = sprintf('0%d',currentTime(5));
% else
%     minString = sprintf('%d',currentTime(5));
% end    
%     
% clockString = sprintf('%d:%s:%s %d/%d/%d',...
%     currentTime(4),minString,secString,...
%     currentTime(2),currentTime(3),currentTime(1));

return;
