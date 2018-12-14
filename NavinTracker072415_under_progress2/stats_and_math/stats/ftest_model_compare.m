function [p,F] = ftest_model_compare(ss_null, df_null, ss_model, df_model)
% [p,F] = ftest_custom(ss_null, df_null, ss_model, df_model)
% p is the probab the null model is different from the model

F = abs(((ss_null - ss_model)/ss_model)/((df_null-df_model)/df_model));
p = 1 - fcdf(F,(df_null-df_model), df_model);

return;
end
