function BinData = merge_BinData(A,B)

BinData = hookup_BinData(A, B);

[instantaneous_fieldnames, freq_fieldnames, inst_n_fields, freq_n_fields] = get_BinData_fieldnames(BinData);
i_fields = [instantaneous_fieldnames inst_n_fields];
f_fields = [freq_fieldnames freq_n_fields];

idx = sort(BinData.time);
BinData.time = BinData.time(idx);
for(i=1:length(i_fields))
    BinData.(i_fields{i}) = BinData.(i_fields{i})(idx);
    
    sigmafield = sprintf('%s_s',i_fields{i});
    errfield = sprintf('%s_err',i_fields{i});
    if(isfield(BinData, sigmafield))
        BinData.(sigmafield) = BinData.(sigmafield)(idx);
        BinData.(errfield) = BinData.(errfield)(idx);
    end
end

idx = sort(BinData.freqtime);
BinData.freqtime = BinData.freqtime(idx);
for(i=1:length(f_fields))
    BinData.(f_fields{i}) = BinData.(f_fields{i})(idx);
    
    sigmafield = sprintf('%s_s',f_fields{i});
    errfield = sprintf('%s_err',f_fields{i});
    if(isfield(BinData, sigmafield))
        BinData.(sigmafield) = BinData.(sigmafield)(idx);
        BinData.(errfield) = BinData.(errfield)(idx);
    end
end

i=1;
while(i<length(BinData.time))
    if(are_these_equal(BinData.time(i),BinData.time(i+1)))
        b=i+1;
        while(are_these_equal(BinData.time(i),BinData.time(b)))
            b=b+1;
            if(b>length(BinData.time))
                break
            end
        end
        if(b>length(BinData.time))
            b=length(BinData.time);
        else
            b=b-1;
        end
        
        for(j=1:length(inst_n_fields))
            BinData.(inst_n_fields{j})(i) = nansum(BinData.(inst_n_fields{j})(i:b));
            BinData.(inst_n_fields{j})(i+1:b) = [];
        end
        
        for(j=1:length(instantaneous_fieldnames))
            BinData.(instantaneous_fieldnames{j})(i) = nanmean(BinData.(instantaneous_fieldnames{j})(i:b));
            
            sigmafield = sprintf('%s_s',instantaneous_fieldnames{j});
            errfield = sprintf('%s_err',instantaneous_fieldnames{j});
            BinData.(sigmafield) = sqrt(nansum(BinData.(sigmafield)(i:b)^2))/(b-i+1);
            BinData.(errfield) = sqrt(nansum(BinData.(errfield)(i:b)))/(b-i+1);
            
            BinData.(instantaneous_fieldnames{j})(i+1:b) = [];
            BinData.(sigmafield)(i+1:b) = [];
            BinData.(errfield{j})(i+1:b) = [];
        end
        
        BinData.time(i+1:b) = [];
    end
    i=i+1; 
end


i=1;
while(i<length(BinData.freqtime))
    if(are_these_equal(BinData.freqtime(i),BinData.freqtime(i+1)))
        b=i+1;
        while(are_these_equal(BinData.freqtime(i),BinData.freqtime(b)))
            b=b+1;
            if(b>length(BinData.freqtime))
                break
            end
        end
        if(b>length(BinData.freqtime))
            b=length(BinData.freqtime);
        else
            b=b-1;
        end
        
        for(j=1:length(freq_n_fields))
            BinData.(freq_n_fields{j})(i) = nansum(BinData.(freq_n_fields{j})(i:b));
            BinData.(freq_n_fields{j})(i+1:b) = [];
        end
        
        for(j=1:length(freq_fieldnames))
            BinData.(freq_fieldnames{j})(i) = nanmean(BinData.(freq_fieldnames{j})(i:b));
            
            sigmafield = sprintf('%s_s',freq_fieldnames{j});
            errfield = sprintf('%s_err',freq_fieldnames{j});
            BinData.(sigmafield) = sqrt(nansum(BinData.(sigmafield)(i:b)^2))/(b-i+1);
            BinData.(errfield) = sqrt(nansum(BinData.(errfield)(i:b)))/(b-i+1);
            
            BinData.(freq_fieldnames{j})(i+1:b) = [];
            BinData.(sigmafield)(i+1:b) = [];
            BinData.(errfield{j})(i+1:b) = [];
        end
        
        BinData.freqtime(i+1:b) = [];
    end
    i=i+1; 
end

return;
end

