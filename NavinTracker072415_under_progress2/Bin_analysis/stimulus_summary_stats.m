function [values, stddev, errors, n, time_matrix] = stimulus_summary_stats(inputBinData, stimulus, attribute, stattype)
% [values, stddev, errors, n] = stimulus_summary_stats(BinData, stimulus, attribute)
% values(i,1) = before stim i; values(i,2) = min/max 1st half stimulus i, values(i,3) = mean 2nd half stimulus i, ...
% values(i,4) = min/max 1st half off-response, values(i,5) = mean 2nd half off-response,

if(nargin<4)
    stattype = [];
end

BinData = inputBinData(1);

time_matrix = [];

if(isempty(stimulus))
    global Prefs;
    
    if(strcmpi(Prefs.graph_no_stim_width_units,'percent')==1)
        stepsize = ceil(BinData.time(end))*(Prefs.graph_no_stim_width/100);
    else
        stepsize = Prefs.graph_no_stim_width;
        if(Prefs.graph_no_stim_width > (ceil(BinData.time(end))-floor(BinData.time(1)))/10)
            stepsize = (ceil(BinData.time(end))-floor(BinData.time(1)))/10;
        end
    end
    
    k=0;
    t1=min(BinData.time);
    while(t1<BinData.time(end))
        k=k+1;
        t2 = t1+stepsize;
        [values(k), stddev(k), errors(k), n(k)] = segment_statistics(inputBinData, attribute, 'mean', t1, t2);
        t1 = t2;
    end
    return;
end

if(~isnumeric(stimulus))
    if(strcmp(stimulus,'staring') || strcmp(stimulus,'stare'))
        k=1;
        
        % food
        idx = find(BinData.freqtime<=0);
        if(~isempty(idx))
            [values(k), stddev(k), errors(k), n(k)] = segment_statistics(inputBinData, attribute, 'mean', ...
                BinData.freqtime(idx(1)), BinData.freqtime(idx(end)));
            k=k+1;
            time_matrix = [time_matrix floor(BinData.freqtime(idx(1))) 0];
        end
        
        % 0-5min
        idx = find(BinData.freqtime>=0 & BinData.freqtime<=5*60);
        if(~isempty(idx))
            [values(k), stddev(k), errors(k), n(k)] = segment_statistics(inputBinData, attribute, 'mean', ...
                BinData.freqtime(idx(1)), BinData.freqtime(idx(end)));
            k=k+1;
            time_matrix = [time_matrix 0 5];
        end
        
        % 5-10
        idx = find(BinData.freqtime>=5*60 & BinData.freqtime<=10*60);
        if(~isempty(idx))
            [values(k), stddev(k), errors(k), n(k)] = segment_statistics(inputBinData, attribute, 'mean', ...
                BinData.freqtime(idx(1)), BinData.freqtime(idx(end)));
            k=k+1;
            time_matrix = [time_matrix 5 10];
        end
        
        % 10-15
        idx = find(BinData.freqtime>=10*60 & BinData.freqtime<=15*60);
        if(~isempty(idx))
            [values(k), stddev(k), errors(k), n(k)] = segment_statistics(inputBinData, attribute, 'mean', ...
                BinData.freqtime(idx(1)), BinData.freqtime(idx(end)));
            k=k+1;
            time_matrix = [time_matrix 10 15];
        end
        
        % 15-20
        idx = find(BinData.freqtime>=15*60 & BinData.freqtime<=20*60);
        if(~isempty(idx))
            [values(k), stddev(k), errors(k), n(k)] = segment_statistics(inputBinData, attribute, 'mean', ...
                BinData.freqtime(idx(1)), BinData.freqtime(idx(end)));
            k=k+1;
            time_matrix = [time_matrix 15 20];
        end
        
        % 20-30
        idx = find(BinData.freqtime>=20*60 & BinData.freqtime<=30*60);
        if(~isempty(idx))
            [values(k), stddev(k), errors(k), n(k)] = segment_statistics(inputBinData, attribute, 'mean', ...
                BinData.freqtime(idx(1)), BinData.freqtime(idx(end)));
            k=k+1;
            time_matrix = [time_matrix 20 30];
        end
        
        % 30-60
        idx = find(BinData.freqtime>=30*60 & BinData.freqtime<=60*60);
        if(~isempty(idx))
            [values(k), stddev(k), errors(k), n(k)] = segment_statistics(inputBinData, attribute, 'mean', ...
                BinData.freqtime(idx(1)), BinData.freqtime(idx(end)));
            k=k+1;
            time_matrix = [time_matrix 30 60];
        end
        
        time_matrix = time_matrix*60;
        return;
    end
    
    stepsize = BinData.freqtime(2) - BinData.freqtime(1);
    k=0;
    t1=min(BinData.time);
    while(t1<BinData.time(end))
        k=k+1;
        t2 = t1+stepsize;
        [values(k), stddev(k), errors(k), n(k)] = segment_statistics(inputBinData, attribute, 'mean', t1, t2);
        t1 = t2;
    end
    return;
end

stimlength = length(stimulus(:,1));

time_matrix(stimlength, 2*5)=0;
tmx = 1;

for(i=1:stimlength)
    
    k=0;
    
    t_on = stimulus(i,1);
    t_off = stimulus(i,2);
    if(i==length(stimulus(:,1))) % the last stimulus
        t_end = max(t_off, BinData.time(end));
    else
        t_end = stimulus(i+1,1);
    end
    
    % before stimulus i - half the time between end of stimulus i-1 and stimulus i
    if(i>1)
        t1 = t_on - (t_on - stimulus(i-1,2))/2;
    else
        t1 = min(0, BinData.time(1));
    end
    t2 = t_on;
    k=k+1;
    [values(i,k), stddev(i,k), errors(i,k), n(i,k)] = segment_statistics(inputBinData, attribute, 'mean', t1, t2);
    time_matrix(i,tmx:tmx+1) = [t1 t2]; tmx = tmx+2;
    
    
    stim_nan_flag=0;
    % stimulus i
    t1 = stimulus(i,1);
    t2 = stimulus(i,2);
    k=k+1;
    [values(i,k), stddev(i,k), errors(i,k), n(i,k)] = segment_statistics(inputBinData, attribute, 'mean', t1, t2);
    if(~isnan(values(i,k)))
        
        % first half of stim
        t1 = t_on;
        t2 = t_on + (t_off-t_on)/2 ;
        time_matrix(i,tmx:tmx+1) = [t1 t2]; tmx = tmx+2;
        [values(i,k), stddev(i,k), errors(i,k), n(i,k)] = segment_statistics(inputBinData, attribute, 'mean', t1, t2);
        if(stimulus(i,3)~=0) % only if there is a real stimulus
            
            
            if(~isempty(stattype))
                [values(i,k), stddev(i,k), errors(i,k), n(i,k)] = segment_statistics(inputBinData, attribute, stattype, t1, t2);
            else
                if(values(i,k) >= values(i,k-1))
                    [values(i,k), stddev(i,k), errors(i,k), n(i,k)] = segment_statistics(inputBinData, attribute, 'max', t1, t2);
                else
                    [values(i,k), stddev(i,k), errors(i,k), n(i,k)] = segment_statistics(inputBinData, attribute, 'min', t1, t2);
                end
            end
        end
        
        % last half of stim
        t1 = t_on + (t_off-t_on)/2 ;
        t2 = t_off;
        time_matrix(i,tmx:tmx+1) = [t1 t2]; tmx = tmx+2;
        k=k+1;
        [values(i,k), stddev(i,k), errors(i,k), n(i,k)] = segment_statistics(inputBinData, attribute, 'mean', t1, t2);
        
    else
        stim_nan_flag=1;
        k=k+1;
        [values(i,k), stddev(i,k), errors(i,k), n(i,k)] = segment_statistics(inputBinData, attribute, 'mean', t1, t2);
        time_matrix(i,tmx:tmx+1) = [t1 t2]; tmx = tmx+2;
    end
    
    % first half of off-time
    t1 = t_off;
    t2 = t_off + (t_end-t_off)/2 ;
    time_matrix(i,tmx:tmx+1) = [t1 t2]; tmx = tmx+2;
    k=k+1;
    [values(i,k), stddev(i,k), errors(i,k), n(i,k)] = segment_statistics(inputBinData, attribute, 'mean', t1, t2);
    if(stim_nan_flag==0)
        if(stimulus(i,3)~=0) % only if there is a real stimulus
            
            if(~isempty(stattype))
                [values(i,k), stddev(i,k), errors(i,k), n(i,k)] = segment_statistics(inputBinData, attribute, stattype, t1, t2);
            else
                if(values(i,k) >= values(i,k-1))
                    [values(i,k), stddev(i,k), errors(i,k), n(i,k)] = segment_statistics(inputBinData, attribute, 'max', t1, t2);
                else
                    [values(i,k), stddev(i,k), errors(i,k), n(i,k)] = segment_statistics(inputBinData, attribute, 'min', t1, t2);
                end
            end
        end
    else
        
        
        if(~isempty(stattype))
            [values(i,k), stddev(i,k), errors(i,k), n(i,k)] = segment_statistics(inputBinData, attribute, stattype, t1, t2);
        else
            if(values(i,k) >= values(i,k-3))
                [values(i,k), stddev(i,k), errors(i,k), n(i,k)] = segment_statistics(inputBinData, attribute, 'max', t1, t2);
            else
                [values(i,k), stddev(i,k), errors(i,k), n(i,k)] = segment_statistics(inputBinData, attribute, 'min', t1, t2);
            end
        end
    end
    
    t1 = t_off + (t_end-t_off)/2 ;
    t2 = t_end;
    time_matrix(i,tmx:tmx+1) = [t1 t2]; tmx = tmx+2;
    k=k+1;
    [values(i,k), stddev(i,k), errors(i,k), n(i,k)] = segment_statistics(inputBinData, attribute, 'mean', t1, t2);
    
end

return;
end

