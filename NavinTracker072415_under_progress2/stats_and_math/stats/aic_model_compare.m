function [p, evidence_ratio, delta_aic] = aic_model_compare(n, ss_A, num_params_A, ss_B, num_params_B)
% [p, evidence_ratio, delta_aic] = aic_model_compare(n, ss_A, num_params_A, ss_B, num_params_B)
% p is the probab model B is better than model A
% evidence_ratio is how much better B is better than A

aic_A = akaike_score(n, ss_A, num_params_A);
aic_B = akaike_score(n, ss_B, num_params_B);

delta_aic = aic_B - aic_A;

p = exp(-delta_aic/2)/(1+ exp(-delta_aic/2));

evidence_ratio = exp(-delta_aic/2);

return;
end
