function n = non_nan_length(x)

if isempty(x) % Check for empty input.
    n = NaN;
    return
end

n = length(non_nan_indicies(x));

return;
