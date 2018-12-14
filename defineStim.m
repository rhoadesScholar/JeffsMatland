function stim = defineStim(

stim = stim/max(stim);

fileName = input('Filename: ', 's');
save(fileName, 'stim', 'cal', 'refed', 'speed');
    
return
end

function showStim
    plot([1465:13356], stim, 'LineWidth', 1, 'Color', 'r')
end