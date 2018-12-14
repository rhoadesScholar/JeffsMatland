function [value, stddev, error, n] = segment_statistics(BinData, attribute, stat_type, t1, t2)
% [value, stddev, error, n] = segment_statistics(BinData, attribute, stat_type, t1, t2)
% attribute = speed, ecc, frac_state, Rev_freq, frac_Omega, etc from BinData
% stat_type = 'max', 'mean', 'min','magnitude_weighted_mean', 'median'
% t1, t2 = starting and end time for the segment

if(nargin<1)
    disp('[value, stddev, error, n] = segment_statistics(BinData, attribute, stat_type, t1, t2)')
    return;
end

if(nargin<3)
    stat_type = 'mean';
end

if(nargin<5)
    t1 = min_struct_array(BinData,'time');
    t2 = max_struct_array(BinData,'time');
end

attribute = parse_BinData_fields(attribute);

% input is BinData_array, so calc segment mean for each, then average, etc
if(length(BinData)>1)
    value_vec = []; n = [];
    for(i=1:length(BinData))
        [value_vec(i), ~, ~, n(i)] = segment_statistics(BinData(i), attribute, stat_type, t1, t2);
    end
    weights = n./nansum(n);
    value = nansum(weights.*value_vec);
    stddev = nanstd(value_vec);
    error = nanstderr(value_vec);
    n = length(BinData);
    return;
end



s_attrib = sprintf('%s_s',attribute);
err_attrib = sprintf('%s_err',attribute);

index = [];

value = NaN;
stddev = NaN;
error = NaN;
n = NaN;


if( length(BinData.(attribute)) == length(BinData.time) ) % instantaneous values speed, ecc, frac_state, etc
    index = find(BinData.time >= t1  &  BinData.time <= t2);
    n_field = 'n';
    if(isempty(strfind(attribute,'frac'))) % not fraction ... probably speed, ecc, etc
        n_field = 'n_fwd';
        if(~isempty(strfind(attribute,'rev')))  % reversal-related variable, like revlength
            n_field = 'n_rev';
        else
            if(~isempty(strfind(attribute,'omegaupsilon')))  % omegaupsilon-related variable, like omegaupsilon_delta_dir
                n_field = 'n_omegaupsilon';
            end
        end
    end
else  % frequencies, etc
    index = find(BinData.freqtime >= t1  &  BinData.freqtime <= t2);
    n_field = 'n_freq';
end


if(isempty(index))
    return;
end

if(strcmpi(stat_type,'mean') || strcmpi(stat_type,'median') || strcmpi(stat_type,'magnitude_weighted_mean') || strcmpi(stat_type,'weighted_mean'))
    
        % n = length(index);
    n = ceil(nanmean(BinData.(n_field)(index)));
    
    if(strcmpi(stat_type,'mean'))
        value = nanmean(BinData.(attribute)(index));
    end
    if(strcmpi(stat_type,'median'))
        value = nanmedian(BinData.(attribute)(index));
    end
    if(strcmpi(stat_type,'magnitude_weighted_mean'))
        value = magnitude_weighted_mean(BinData.(attribute)(index));
    end
    
    % weighted by n
    if(strcmpi(stat_type,'weighted_mean'))
        value = nansum(BinData.(n_field)(index).*BinData.(attribute)(index))/nansum(BinData.(n_field)(index));
    end
    
    
    stddev = 0;
    error = 0;
    
    if(isfield(BinData,s_attrib))
        if(~isempty(index))
            
            %             % error propagated this way since we want a single value to
            %             % represent a stretch of time ... these errors and stats are on the
            %             % conservative (ie: high) estimates
            %             ii=0; % number of NaN values
            %             for(i=1:length(index))
            %                 if(~isnan(BinData.(s_attrib)(index(i))))
            %                     stddev = stddev + BinData.(s_attrib)(index(i));
            %                     error = error + BinData.(err_attrib)(index(i));
            %                 else
            %                     ii=ii+1;
            %                 end
            %             end
            %             stddev = (stddev)/(length(index)-ii);
            %             error = (error)/(length(index)-ii);
            
            % variance within the bin
            % since we are binning, we are assuming
            % equivalence within the bin
            stddev = (nanstd(BinData.(attribute)(index)));
            error = (nanstderr(BinData.(attribute)(index)));
            
            if(strcmpi(stat_type,'weighted_mean'))
                stddev = 0;
                error = 0;
                n_local = 0;
                var = 0;
                n = 0;
                
                stddev = nansum(BinData.(n_field)(index).*BinData.(s_attrib)(index))/nansum(BinData.(n_field)(index));
                error = nansum(BinData.(n_field)(index).*BinData.(err_attrib)(index))/nansum(BinData.(n_field)(index));
                n = nansum(BinData.(n_field)(index).*BinData.(n_field)(index))/nansum(BinData.(n_field)(index));
                
%                 for(k=1:length(index))
%                     if(~isnan(BinData.(attribute)(index(k))) && ~isnan(BinData.(n_field)(index(k))))
%                         var = var + BinData.(n_field)(index(k))*(value - BinData.(attribute)(index(k)))^2;
%                         n_local = n_local + BinData.(n_field)(index(k));
%                         n = n + BinData.(n_field)(index(k))*BinData.(n_field)(index(k));
%                     end
%                 end
%                 if(n_local>0)
%                     n = n/n_local;
%                     var = var/n_local;
%                     stddev = sqrt(var);
%                     error = stddev/sqrt(n_local);
%                 end
                
            end
            
            % %             error propagation by quadrature ... too low an estimate?
            %             ii=0; % number of NaN values
            %             for(i=1:length(index))
            %                 if(~isnan(BinData.(s_attrib)(index(i))))
            %                     stddev = stddev + (BinData.(s_attrib)(index(i)))^2;
            %                     error = error + (BinData.(err_attrib)(index(i)))^2;
            %                 else
            %                     ii=ii+1;
            %                 end
            %             end
            %             stddev = sqrt(stddev)/(length(index)-ii);
            %             error = sqrt(error)/(length(index)-ii);
            
            
            
        end
    end
    
end

if(strcmpi(stat_type,'max'))
    
    [value, ind] = max(BinData.(attribute)(index));
    idx = index(ind);
    
    if(isfield(BinData,s_attrib))
        stddev = BinData.(s_attrib)(idx);
        error = BinData.(err_attrib)(idx);
    else
        stddev = 0;
        error = 0;
    end
    n = BinData.(n_field)(idx);
    
end

if(strcmpi(stat_type,'min'))
    
    [value, ind] = min(BinData.(attribute)(index));
    idx = index(ind);
    
    if(isfield(BinData,s_attrib))
        stddev = BinData.(s_attrib)(idx);
        error = BinData.(err_attrib)(idx);
    else
        stddev = 0;
        error = 0;
    end
    n = BinData.(n_field)(idx);
    
end

return;

end

