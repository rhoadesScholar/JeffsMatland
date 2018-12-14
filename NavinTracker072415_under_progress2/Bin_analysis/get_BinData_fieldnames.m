function [instantaneous_fieldnames, freq_fieldnames, inst_n_fields, freq_n_fields, frac_fieldnames, attrib_fieldnames, fwd_fields, rev_fields, omegaupsilon_fields] = get_BinData_fieldnames(BinData)
% [instantaneous_fieldnames, freq_fieldnames, inst_n_fields, freq_n_fields, frac_fieldnames, attrib_fieldnames] = get_BinData_fieldnames(BinData)

if(nargin<1)
    BinData = initialize_BinData;
    [instantaneous_fieldnames, freq_fieldnames, inst_n_fields, freq_n_fields, frac_fieldnames, attrib_fieldnames, fwd_fields, rev_fields, omegaupsilon_fields] = get_BinData_fieldnames(BinData);
    return;
end

inst_n_fields = {'n', 'n_fwd', 'n_rev', 'n_omegaupsilon'};
freq_n_fields = {'n_freq'};

fwd_fields = {'speed', 'angspeed',  'ecc', 'curv', 'body_angle' 'head_angle' 'tail_angle'};
rev_fields = {'revlength','revSpeed','revlength_bodybends','delta_dir_rev'};
omegaupsilon_fields = {'ecc_omegaupsilon','delta_dir_omegaupsilon'};

BinData = update_old_BinData(BinData);

bin_fieldnames = fieldnames(BinData);

i=1;
while(i<=length(inst_n_fields))
    dont_del_flag=0;
    j=1;
    while(j<=length(bin_fieldnames))
        if(strcmp(inst_n_fields{i},bin_fieldnames{j}))
            dont_del_flag=1;
        end
        j=j+1;
    end
    if(dont_del_flag==0)
        inst_n_fields(i)=[];
    else
        i=i+1;
    end
end

i=1;
while(i<=length(bin_fieldnames))
    if(strcmp(bin_fieldnames{i},'n')==1 || strcmp(bin_fieldnames{i},'n_fwd')==1 || strcmp(bin_fieldnames{i},'n_rev')==1 || strcmp(bin_fieldnames{i},'n_omegaupsilon')==1 || strcmp(bin_fieldnames{i},'n_freq')==1  || strcmp(bin_fieldnames{i},'num_movies')==1 ||...
            ~isempty(strfind(bin_fieldnames{i}, 'time'))==1 )
        bin_fieldnames(i)=[];
    else
        if(strfind(bin_fieldnames{i}, '_err'))
            bin_fieldnames(i)=[];
        else
            x = strfind(bin_fieldnames{i}, '_s');
            if(length(x) > 1)
                bin_fieldnames(i)=[];
            else
                if(x == length(bin_fieldnames{i})-1)
                    bin_fieldnames(i)=[];
                else
                    i=i+1;
                end
            end
        end
    end
end

k=0;
i=1;
while(i<=length(bin_fieldnames))
    if(~isempty(strfind(bin_fieldnames{i},'freq')))
        k=k+1;
        freq_fieldnames{k} = bin_fieldnames{i};
        bin_fieldnames(i) = [];
    else
        i=i+1;
    end
end

k=0; p=0;
i=1;
while(i<=length(bin_fieldnames))
    if(isempty(strfind(bin_fieldnames{i},'frac')) && strcmp(bin_fieldnames{i},'Name')==0  && strcmp(bin_fieldnames{i},'xlabel')==0)
        k=k+1;
        attrib_fieldnames{k} = bin_fieldnames{i};
    else
        if(strcmp(bin_fieldnames{i},'Name')==0 && strcmp(bin_fieldnames{i},'xlabel')==0 )
            p=p+1;
            frac_fieldnames{p} = bin_fieldnames{i};
        end
    end
    i=i+1;
end
instantaneous_fieldnames = [attrib_fieldnames frac_fieldnames];

clear('bin_fieldnames');

return;
end
