function BinDataAlt = alternate_binwidth_BinData(BinData, binwidth, freq_binwidth, mintime, maxtime)
% BinDataAlt = alternate_binwidth_BinData(BinData, binwidth, freq_binwidth,  mintime, maxtime), in sec

if(nargin<2)
    disp('usage BinDataAlt = alternate_binwidth_BinData(BinData, binwidth, freq_binwidth,  mintime, maxtime), in sec');
    return
end

if(nargin<3)
    freq_binwidth = binwidth;
end

[instantaneous_fieldnames, freq_fieldnames, inst_n_fields, freq_n_fields, frac_fieldnames, attrib_fieldnames, fwd_fields, rev_fields, omegaupsilon_fields] = get_BinData_fieldnames(BinData(1));


instantaneous_fieldnames = [instantaneous_fieldnames, inst_n_fields];
freq_fieldnames = [freq_fieldnames, freq_n_fields];

if(nargin<5)
    mintime = floor(min([BinData(1).time, BinData(1).time]));
    maxtime = ceil(max([BinData(1).time, BinData(1).time]));
end

if(length(BinData)>1)
    BinData = extract_BinData_array(BinData);
end

% are we already binned at the target binwidths?

for(idx = 1:length(BinData))
    %     BinDataA.Name = BinData(idx).Name; % sprintf('%s.%d.%d.%d.%d',BinData(idx).Name, int8(binwidth), int8(freq_binwidth), int8(mintime), int8(maxtime));
    %     BinDataA.num_movies = BinData(idx).num_movies;
    
    BinDataA = BinData(idx);
    
    for(ii=1:2)
        
        if(ii==1)
            fn = instantaneous_fieldnames;
            working_binwidth = binwidth;
            timetype = 'time';
            numtype = 'n';
        else
            fn = freq_fieldnames;
            working_binwidth = freq_binwidth;
            timetype = 'freqtime';
            numtype = 'n_freq';
        end
        
        current_binwidth = BinDataA.(timetype)(2)-BinDataA.(timetype)(1);
        
        if(are_these_equal(current_binwidth, working_binwidth) || current_binwidth>=working_binwidth)
            % already binned
            p=1;
        else
            bins = mintime:working_binwidth:maxtime;
            
            BinDataA.(timetype) = [];
            BinDataA.(numtype) = [];
            
            for(p=1:length(fn))
                
                attribute =  fn{p};
                s_field = sprintf('%s_s', attribute);
                err_field = sprintf('%s_err', attribute);
                
                BinDataA.(attribute) = [];
                BinDataA.(s_field) = [];
                BinDataA.(err_field) = [];
                
                if(~isempty(BinData(idx).(attribute)))
                    i=1;
                    while(i<=length(bins)-1)
                        t1 = bins(i);
                        t2 = bins(i+1);
                        
                        BinDataA.(timetype)(i) = (t1+t2)/2;
                        
                        [BinDataA.(attribute)(i), BinDataA.(s_field)(i), BinDataA.(err_field)(i)] = ...
                            segment_statistics(BinData(idx), attribute, 'mean', t1, t2);
                        
                        % BinDataA.(numtype)(i) = ceil(BinDataA.(numtype)(i));
                        
                        i=i+1;
                    end
                end
            end
            
            %         del_idx = find(isnan(BinDataA.(numtype)));
            %         BinDataA.(timetype)(del_idx) = [];
            %         for(p = 1:length(fn))
            %             attribute =  fn{p};
            %             s_field = sprintf('%s_s', attribute);
            %             err_field = sprintf('%s_err', attribute);
            %
            %             BinDataA.(attribute)(del_idx) = [];
            %             BinDataA.(s_field)(del_idx) = [];
            %             BinDataA.(err_field)(del_idx) = [];
            %         end
            
        end
    end
    
    BinDataAlt(idx) = rmfield(BinDataA,{'n_s', 'n_err', 'n_fwd_s', 'n_fwd_err', 'n_rev_s', 'n_rev_err', 'n_freq_s', 'n_freq_err','n_omegaupsilon_s','n_omegaupsilon_err'});
    
end

return;
end

