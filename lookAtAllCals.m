days = dir;
days = days(3:end);
days = days([days(:).isdir]);
days = {days(:).name};
if isempty(dir([days{1} '/*.mat']))
    slash = '\';
else
    slash = '/';
end

for d = 1:length(days)
    files = dir([days{d} slash '*.mat']);
    files = files(arrayfun(@(x) ~contains(files(x).name, 'lawnFile'), 1:length(files)));
    notes = dir([days{d} slash 'notes*.txt']);
    try
        load([files(end).folder slash files(end).name]);
        %check if need re-getCals
        notesID = fopen([notes(end).folder slash notes(end).name]);
        notes = textscan(notesID, '%s');
        notes = notes{1};
        fclose(notesID);
        theseCals = dir([days{d} slash '*.an*.txt']);
        %theseCals = {theseCals(:).name};
        theseCals = cellfun(@(a) [a ':'], {theseCals(:).name}, 'UniformOutput', false);
        if any(~ismember(theseCals, notes))
            warning('Need to get the all the calcium tracks.')
            cd(days{d})
            getCalTracks
            cd ..
            try
                files = dir([days{d} slash '*.mat']);
                load([files(end).folder slash files(end).name]);
            end
        end
    catch
        warning('Need to get the all the calcium tracks.')
        cd(days{d})
        try
            getCalTracks
        catch
            cd ..
            continue
        end
        cd ..
        try
            files = dir([days{d} slash '*.mat']);
            load([files(end).folder slash files(end).name]);
        end
    end
end

vs = whos('calTracks_*');
vs = {vs(:).name};
for b = 1:length(vs)
eval(sprintf('cals{%i} = %s', b, vs{b}));
end

[allTracks, wormsUsed, calMats, avgs, stdErr] = showPooledAvgCalTracks(cals, {}, [5 10]);
[speedAvgs, calAvgs, speedPmat, calPmat] = analysis_calData_jeff(calMats)