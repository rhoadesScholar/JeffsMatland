function ratioBinData = BinData_ratio(A, B)
% ratioBinData = BinData_ratio(A, B) % A/B for all BinData fields, w/
% propagated error - zero issue???
% n fields are the min(A.n, B.n)

[instantaneous_fieldnames, freq_fieldnames, inst_n_fields, freq_n_fields] = get_BinData_fieldnames(B);
timefields = {'time','freqtime'};
n_fields = [inst_n_fields freq_n_fields];
datafields = [instantaneous_fieldnames, freq_fieldnames];

ratioBinData = A;

for(j=1:length(n_fields))
    ratioBinData.(n_fields{j}) = min( A.(n_fields{j}), B.(n_fields{j}) );
end

for(j=1:length(timefields))
    ratioBinData.(timefields{j}) = ( A.(timefields{j}) + B.(timefields{j}) )/2;
end

for(j=1:length(datafields))
    s_field = sprintf('%s_s',datafields{j});
    err_field = sprintf('%s_err',datafields{j});
    
    ratioBinData.(datafields{j}) = A.(datafields{j})/B.(datafields{j});
    ratioBinData.(s_field) = sqrt( (A.(s_field)./A.(datafields{j})).^2 + (B.(s_field)./B.(datafields{j})).^2 );
    ratioBinData.(err_field) = sqrt( (A.(err_field)./A.(datafields{j})).^2 + (B.(err_field)./B.(datafields{j})).^2 );
end

return;
end
