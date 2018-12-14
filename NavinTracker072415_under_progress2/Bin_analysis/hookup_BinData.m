function BinData = hookup_BinData(A, B)

fn = fieldnames(A);

for(i=1:length(fn))
    if(strcmp(fn{i},'Name')==0)
        BinData.(fn{i}) = [A.(fn{i}) B.(fn{i})];
    end
end

BinData.Name = '';
BinData.Name = get_common_name_from_strings({A.Name B.Name});
if(isempty(BinData.Name))
    BinData.Name = sprintf('%s.%s',A.Name, B.Name);
end

BinData.num_movies = round(nanmean([A.num_movies B.num_movies]));

return;
end
