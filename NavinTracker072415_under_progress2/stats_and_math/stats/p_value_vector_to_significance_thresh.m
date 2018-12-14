function [symbols, signif_thresh] = p_value_vector_to_significance_thresh(p_value_vector, alpha_list, alpha_symbol)
% function [symbols, signif_thresh] = p_value_vector_to_significance_thresh(p_value_vector, alpha_list, alpha_symbol)

if(nargin<2)
    alpha_symbol = {'+','*','**','***'};
    alpha_list = [0.05 0.01 0.001 0.0001];
end

[alpha_list, alpha_idx] = sort(alpha_list);
alpha_symbol = alpha_symbol(alpha_idx);

signif_thresh = ones(size(p_value_vector));
symbols = cell(size(p_value_vector));
for(i=1:length(p_value_vector))
    if(~isnan(p_value_vector(i)))
        j=1;
        while(j<=length(alpha_list))
            if(p_value_vector(i) <= alpha_list(j))
                symbols{i} = alpha_symbol{j};
                signif_thresh(i) = alpha_list(j);
                break;
            end
            j = j+1;
        end
    end
end

for(i=1:length(symbols))
    if(isempty(symbols{i}))
        symbols{i} = '';
    end
end

return;
end
