function mean_BinData = mean_BinData_from_BinData_array(inputBinData_array,name)
% mean_BinData = mean_BinData_from_BinData_array(BinData_array, [name])

if(nargin<1)
    disp('mean_BinData = mean_BinData_from_BinData_array(BinData_array, [name])')
    return
end

len_bindata_array = length(inputBinData_array);

if(len_bindata_array<2)
    mean_BinData = inputBinData_array;
    return; 
end

if(nargin<2)
    name = '';
end

if(isempty(name))
    for(i=1:length(inputBinData_array))
        string_cell_array{i} = inputBinData_array(i).Name;
    end
    name = get_common_name_from_strings(string_cell_array);
    clear('string_cell_array');
end

% if the elements inputBinData_array have different lengths, truncate so
% all start and end at the same times
BinData_array = extract_BinData_array(inputBinData_array);

mean_BinData.Name = name;
if(isfield(BinData_array(1),'xlabel'))
    mean_BinData.xlabel = BinData_array(1).xlabel;
end

mean_BinData.num_movies = len_bindata_array;

[instantaneous_fieldnames, freq_fieldnames, inst_n_fields, freq_n_fields, frac_fieldnames, attrib_fieldnames, fwd_fields, rev_fields, omegaupsilon_fields] = get_BinData_fieldnames(BinData_array(1));
timefields = {'time','freqtime'};
n_fields = [inst_n_fields freq_n_fields];
datafields = [instantaneous_fieldnames, freq_fieldnames];

% for(i=1:length(BinData_array))
%     disp([sprintf('%s',BinData_array(i).Name), ' ', num2str(length(BinData_array(i).time)), ' ',  num2str(length(BinData_array(i).freqtime))])
% end

for(j=1:length(timefields))
    mean_BinData.(timefields{j}) = zeros(1,length(BinData_array(1).(timefields{j})));
    for(i=1:len_bindata_array)
        mean_BinData.(timefields{j}) = mean_BinData.(timefields{j}) + BinData_array(i).(timefields{j});
    end
    mean_BinData.(timefields{j}) = mean_BinData.(timefields{j})./len_bindata_array;
end

for(j=1:length(n_fields))
    mean_BinData.(n_fields{j}) = zeros(1,length(BinData_array(1).(n_fields{j})));
    for(i=1:len_bindata_array)
        mean_BinData.(n_fields{j}) = mean_BinData.(n_fields{j}) + BinData_array(i).(n_fields{j});
    end
end

% weight by number of animals in each BinData_array element at each timepoint
weight_n_fields = {'n','n_freq','n_fwd','n_rev','n_omegaupsilon'};
weight_names = {'inst_weight','freq_weight','fwd_weight','rev_weight','omegaupsilon_weight'};
for(p=1:length(weight_n_fields))
    field_length = length(mean_BinData.(weight_n_fields{p}));
    command_string = sprintf('%s = zeros(len_bindata_array, field_length);',weight_names{p});
    eval(command_string);
    for(i=1:len_bindata_array)
        command_string = sprintf('%s(%d,:) = BinData_array(%d).%s;',weight_names{p},i,i, weight_n_fields{p});
        eval(command_string);
    end
    for(k=1:field_length)
        command_string = sprintf('%s(:,%d) = %s(:,%d)/sum(%s(:,%d));',weight_names{p},k, weight_names{p}, k, weight_names{p},k);
        eval(command_string);
    end
end

for(j=1:length(datafields))
    the_field = datafields{j};
    s_field = sprintf('%s_s',datafields{j});
    err_field = sprintf('%s_err',datafields{j});
    
    field_length = length(BinData_array(1).(the_field));
    
    if(~isempty(find(strcmp(rev_fields,the_field)==1)))
        weight = rev_weight;
    else
        if(~isempty(find(strcmp(omegaupsilon_fields,the_field)==1)))
            weight = omegaupsilon_weight;
        else
            if(~isempty(find(strcmp(fwd_fields,the_field)==1)))
                weight = fwd_weight;
            else
                if(field_length == length(BinData_array(1).n_freq))
                    weight = freq_weight;
                else
                    weight = inst_weight;
                end
            end
        end
    end
    
    mean_BinData.(the_field) = [];
    mean_BinData.(s_field) = [];
    mean_BinData.(err_field) = [];
    
%     % weighted mean .. usually very similar to unweighted
%     for(k=1:field_length)
%         mean_BinData.(the_field)(k) = 0;
%         mean_BinData.(s_field)(k) = 0;
%         mean_BinData.(err_field)(k) = 0;
%         for(i=1:len_bindata_array)
%             if(~isnan(BinData_array(i).(the_field)(k)) )
%                 mean_BinData.(the_field)(k) = mean_BinData.(the_field)(k) + weight(i,k)*BinData_array(i).(the_field)(k);
%                 mean_BinData.(s_field)(k) = mean_BinData.(s_field)(k) + weight(i,k)*BinData_array(i).(s_field)(k);
%                 mean_BinData.(err_field)(k) = mean_BinData.(err_field)(k) + weight(i,k)*BinData_array(i).(err_field)(k);
%             end
%         end
%     end

    % unweighted std dev over-estimates the std dev and error somewhat
    for(k=1:field_length)
        values=[];
        for(i=1:len_bindata_array)
            values = [values BinData_array(i).(the_field)(k)];
        end
        mean_BinData.(the_field)(k) = nanmean(values);
        mean_BinData.(s_field)(k) = nanstd(values);
        mean_BinData.(err_field)(k) = nanstderr(values);
    end    
    
    
    
    clear('weight');
end

clear('inst_weight');
clear('freq_weight');
clear('fwd_weight');
clear('rev_weight');
clear('omegaupsilon_weight');

return;
end
