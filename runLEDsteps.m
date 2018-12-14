function runLEDsteps(durations, stim)% durations is nx2 array of [duration of pause before stim, duration of stim]
% stim is vector of length n of LED intensities in range [0:1]
    DAQ = 'Dev2';%MAKE SURE IS SET TO CORRECT DEVICE
    devices = daq.getDevices;
    s = daq.createSession('ni');
    addAnalogOutputChannel(s,DAQ, 0,'Voltage');
    s.Rate = 5000;
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
        datestr(now,'mmmm dd, yyyy HH:MM:SS.FFF AM')
        h = waitbar(0/length(stim),'Optogenetic stimulation in progress...',...
                'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
        fprintf('g = %0.2f \n', g)
        outputSingleScan(s,0)
        
        tic
        next = 0;
        for i = 1:size(durations,1)
            next = next + durations(i, 1);
            while toc < next
                waitbar(toc/sum(sum(durations)), h);
                
                if getappdata(h,'canceling')
                    break
                end
            end
            outputSingleScan(s,stim(i)*g)
            toc
            next = next + durations(i, 2);
            while  toc < next
                waitbar(toc/sum(sum(durations)), h);
                
                if getappdata(h,'canceling')
                    break
                end
            end
%             pause(durations(i,1))
%             outputSingleScan(s,stim(i)*g)
%             waitbar(sum(sum(durations(1:i,:)))/sum(sum(durations)), h);
%             pause(durations(i,2))
            outputSingleScan(s,0)
            toc
            if getappdata(h,'canceling')
                break
            end
        end
        delete(h)
        answer = questdlg('Do another run?');
        if strcmp(answer, 'Cancel')
            newG = inputdlg('New gain value: ', 'Adjust Optostim gain', 1, {num2str(g)});
            g = str2num(newG{:});
            if (g<=5) && (g>=0)
                answer = 'Yes';
            end
        end
    end
end