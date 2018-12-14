function [num_models, k_usage_vector, gamma_usage_vector] = create_usage_vectors(staring_flag)

if(staring_flag==1)
    num_models = 3;
    
    % one-state
    k_usage_vector(1,:) = [0 0 0 0];
    gamma_usage_vector(1,:) = [0 0 1 0 0];

    % two-state
    k_usage_vector(2,:) = [0 0 1 0];
    gamma_usage_vector(2,:) = [0 0 1 0 1];
    
    % three-state
    k_usage_vector(3,:) = [0 0 1 1];
    gamma_usage_vector(3,:) = [0 0 1 1 1];
    
    return;
end

num_models = 5;

k_usage_vector=[];
gamma_usage_vector=[];

% constant
k_usage_vector(1,:) = [0 0 0 0];
gamma_usage_vector(1,:) = [0 0 1 0 0];

% two-state on -> two-state off
k_usage_vector(2,:) = [1 0 1 0];
gamma_usage_vector(2,:) = [1 0 1 0 1];

% two-state on -> three-state off
k_usage_vector(3,:) = [1 0 1 1];
gamma_usage_vector(3,:) = [1 0 1 1 1];

% three-state on -> two-state off
k_usage_vector(4,:) = [1 1 1 0];
gamma_usage_vector(4,:) = [1 1 1 0 1];   

% three-state on -> three-state off
k_usage_vector(5,:) = [1 1 1 1];
gamma_usage_vector(5,:) = [1 1 1 1 1];   

return;
end
