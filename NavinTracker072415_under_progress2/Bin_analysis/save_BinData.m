function save_BinData(BinData, localpath, prefix)
% save_BinData(BinData, localpath, prefix)
% BinData saved to localpath/prefix.BinData.mat
% instantaneous values saved to localpath/prefix.binned.txt
% freqs saved to localpath/prefix.freqs.txt

if(nargin<1)
    disp('save_BinData(BinData, localpath, prefix)')
    return;
end

if(length(localpath)>0)
    if(localpath(end)~='\' && localpath(end)~='/')
        localpath = sprintf('%s%s',localpath,filesep);
    end
end

% save BinData
dummystring = sprintf('%s%s.BinData.mat',localpath,prefix);

if(isempty(BinData))
    save(dummystring, 'BinData');
    return;
end

BinData.Name = prefix;

save(dummystring, 'BinData');

[instantaneous_fieldnames, freq_fieldnames] = get_BinData_fieldnames(BinData);

% save instantaneous data as text file
dummystring = sprintf('%s%s.non_freqs.txt',localpath,prefix);
file_ptr = fopen(dummystring,'wt');

labelstring = sprintf('Time\tn');
for(j=1:length(instantaneous_fieldnames))
    valname = sprintf('%s',instantaneous_fieldnames{j});
    if(~isempty(BinData.(valname)))
        labelstring = sprintf('%s\t%s\t%s_s\t%s_err',labelstring,instantaneous_fieldnames{j},instantaneous_fieldnames{j},instantaneous_fieldnames{j});
    end
end
fprintf(file_ptr,'%s\n',labelstring);

for i = 1:length(BinData.time)
    datastring = sprintf('%f\t%f',BinData.time(i), BinData.n(i));
    
    for(j=1:length(instantaneous_fieldnames))
        
        valname = sprintf('%s',instantaneous_fieldnames{j});
        
        if(~isempty(BinData.(valname)))
            s_name = sprintf('%s_s',valname);
            err_name = sprintf('%s_err',valname);
            datastring = sprintf('%s\t%f\t%f\t%f',datastring, BinData.(valname)(i), BinData.(s_name)(i), BinData.(err_name)(i));
        end
        
    end
    
    fprintf(file_ptr,'%s\n',datastring);
    
end
fclose(file_ptr);


% save freq data as text file
dummystring = sprintf('%s%s.freqs.txt',localpath,prefix);
file_ptr = fopen(dummystring,'wt');

labelstring = sprintf('Time\tn');
for(j=1:length(freq_fieldnames))
    valname = sprintf('%s',freq_fieldnames{j});
    if(~isempty(BinData.(valname)))
        labelstring = sprintf('%s\t%s\t%s_s\t%s_err',labelstring,freq_fieldnames{j},freq_fieldnames{j},freq_fieldnames{j});
    end
end
fprintf(file_ptr,'%s\n',labelstring);

for i = 1:length(BinData.freqtime)
    datastring = sprintf('%f\t%f',BinData.freqtime(i), BinData.n_freq(i));
    
    for(j=1:length(freq_fieldnames))
        
        valname = sprintf('%s',freq_fieldnames{j});
        
        if(~isempty(BinData.(valname)))
            s_name = sprintf('%s_s',valname);
            err_name = sprintf('%s_err',valname);
            datastring = sprintf('%s\t%f\t%f\t%f',datastring, BinData.(valname)(i), BinData.(s_name)(i), BinData.(err_name)(i));
        end
        
    end
    
    fprintf(file_ptr,'%s\n',datastring);
    
end
fclose(file_ptr);

return;
end
