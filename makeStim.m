function stim = makeStim(cal, refed, speed)

stim = cal(refed==1);
stim = movmean(stim, 30, 'omitnan'); %#####$$$$SET SMOOTH FACTOR
% fin = find(stim <= 0,1);
% stim = stim(1:fin);

stim = stim/max(stim);

fileName = input('Filename: ', 's');
save(fileName, 'stim', 'cal', 'refed', 'speed');

return
end

function showStim
    plot(cal, 'Color', 'g')
    hold on
    yyaxis right
    plot(speed, 'Color', 'b')
    yyaxis left

%     stim = cal(refed==1);
%     stim = movmean(stim, 100, 'Endpoints', 'shrink', 'omitnan');
    
    plot([1465:13356], stim, 'LineWidth', 1, 'Color', 'r')
end