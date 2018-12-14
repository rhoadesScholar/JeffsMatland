    days = dir;
    days = days(3:end);
    days = days([days(:).isdir]);
    days = {days(:).name};
    for d = 1:length(days)
        files = dir([days{d} '\*.mat']);
        load([files(end).folder '\' files(end).name]);
    end
    
    vs = whos('calTracks_*');
    vs = {vs(:).name};
    for b = 1:length(vs)
    eval(sprintf('cals{%i} = %s', b, vs{b}))
    end
    
%     showPooledAvgCalTracks(cals, true, [5 10])