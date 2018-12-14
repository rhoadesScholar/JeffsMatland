function [eig_vec, eig_val] = eigenvector_data_matrix(m)
% [eig_vec, eig_val] = eigenvector_data_matrix(m)
% matrix m is rows x columns  observation x variable
% eig_vec is sorted by eig_val
% eig_val are normalized

% the covariance matrix
covm = cov(m);

% calculate the eigenvectors and eigenvalues
[eig_vec,eig_val] = eig(covm);

% normalize the eigenvalues
eig_val = diag(eig_val);
eig_val = eig_val./nansum(eig_val);  

% sort the eigenvectors by eigenvalues
[~,idx] = sort(-eig_val);
eig_val = eig_val(idx);
eig_vec = eig_vec(:,idx);

return;
end
