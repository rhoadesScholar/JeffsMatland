function [min_difference, array_position] = find_vector_element_nearest_k(vector_a, k)
%  [min_difference, array_position] = find_vector_element_nearest_k(vector_a, k)

[min_difference, array_position] = min(abs(vector_a - k));

return;
end
