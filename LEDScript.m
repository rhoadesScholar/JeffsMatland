DAQ = 'Dev2';%MAKE SURE IS SET TO CORRECT DEVICE
devices = daq.getDevices;
s = daq.createSession('ni');
addAnalogOutputChannel(s,DAQ, 0,'Voltage');
s.Rate = 5000;
% for i = 1:3
%     outputSingleScan(s,2)
%     pause(1)
%     outputSingleScan(s,0)
%     pause(1)
% end
%FOR TRIGGERED STIM

d = 0.1;%SET DELAY BETWEEN STIM INTENSITY CHANGE
g = 4;%SET GAIN FOR STIM INTENSITY$#$#$#$#$#$#$#$#$#$#$#$#$#$#$
% t = [5.0000    5.0000    5.0000    5.0000    5.0000    5.0000    5.0000    4.5000    4.0000    3.0000    2.0000   1.0000    0.5000    0.1000   0]; %SET STIM TRAIN

answer = 'No';
while ~strcmp(answer, 'Yes')
    newG = inputdlg('New gain value: ', 'Adjust Optostim gain', 1, {num2str(g)});
    g = str2num(newG{:});
    if (g<=5) && (g>=0)
        answer = 'Yes';
    end
end

while strcmp(answer, 'Yes')
    disp('Press key with video start.');
    pause
    tic
    disp('Started. Press for stim.');
    pause
    toc
    datestr(now,'mmmm dd, yyyy HH:MM:SS.FFF AM')
    h = waitbar(0/length(stim),'Optogenetic stimulation in progress...',...
            'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
    fprintf('g = %0.2f \n', g)
    for i = 1:length(stim)
        if ~isnan(stim(i))
            outputSingleScan(s,stim(i)*g)
        end
        waitbar(i/length(stim), h);
        pause(d)
        if getappdata(h,'canceling')
            break
        end
    end
    delete(h)
    outputSingleScan(s,0)    
    answer = questdlg('Do another run?');
    if strcmp(answer, 'Cancel')
        newG = inputdlg('New gain value: ', 'Adjust Optostim gain', 1, {num2str(g)});
        g = str2num(newG{:});
        if (g<=5) && (g>=0)
            answer = 'Yes';
        end
    end
end