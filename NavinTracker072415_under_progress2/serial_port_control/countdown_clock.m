function countdown_clock(time)

questdlg(sprintf('Start the %d sec countdown',time),sprintf('Start the %d sec countdown',time),'Start','Start'); 

h = waitbar(0,sprintf('Starting in %d sec ...',time));
len = length([time:-1:1]);
for(i=time:-1:1)
    waitbar((len-i)/len,h,sprintf('%d sec left',i))
    pause(1);
end
delete(h);

% disp([sprintf('Press any key to start the %d sec countdown',time)])
% pause
% 
% disp([sprintf('Starting in %d sec ...',time)])       
% 
% for(i=time:-1:1)
%     disp([num2str(i) ' sec left'])     
%     pause(1)
% end

beep;
disp(['Start at ' timeString()])
beep;

return;
end
