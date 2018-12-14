for i = 1:24
    leave = (find([a.SWF18s30min(i).refed(2:end) - a.SWF18s30min(i).refed(1:end-1)] == -1) - find([a.SWF18s30min(i).refed(2:end) - a.SWF18s30min(i).refed(1:end-1)] == 1, 1))/600;
    comp = strcmpi(mat.SWF18s30min, a.SWF18s30min(i).name);
    used = find(comp);
    if ~isempty(used) && ~isempty(leave)
        fprintf('Used at i = %i and left after %0.2f minutes\n \r', used, leave);
    elseif used
        fprintf('Used at i = %i\n \r', used);
    else
        disp('Not used')
    end
    pause
end