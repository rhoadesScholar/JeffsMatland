% returns the indicies of the non-NaN values

function idx = non_nan_indicies(x)

idx=[];

if(isempty(x))
    return;
end

idx = find(~isnan(x));

return;
