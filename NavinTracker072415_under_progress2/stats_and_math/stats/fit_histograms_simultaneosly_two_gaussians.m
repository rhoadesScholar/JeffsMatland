function  [mu1, s1, mu2, s2, A1_vector, A1_vector_error, fitted_hist_matrix, score] = fit_histograms_simultaneosly_two_gaussians(input_histogram_matrix)
% [mu1, s1, mu2, s2, A1_vector, A2_vector, fitted_hist_matrix, score] = fit_histograms_simultaneosly_two_gaussians(input_histogram_matrix)
% simultaneously fit the histograms in input_histogram_matrix (each row is
% a histogram) to the sum of gaussians with the same mean and std-dev for
% all; each histogram has its own amplitude in A1_vector

hist_sum_vector = [];
histogram_matrix = [];
for(i=1:size(input_histogram_matrix,1))
    hist_sum_vector(i) = nansum(input_histogram_matrix(i,:));
    histogram_matrix = [histogram_matrix; input_histogram_matrix(i,:)/hist_sum_vector(i)];
end

[~,max_idx] = max(histogram_matrix(1,:));
m0(1) = max_idx;
m0(2) = 1.5;

[~,max_idx] = max(histogram_matrix(end,:));
m0(3) = max_idx;
m0(4) = 1.5;

m0(1) = round(0.25*length(histogram_matrix(1,:)));
m0(3) = round(0.75*length(histogram_matrix(1,:)));


m0(5:size(input_histogram_matrix,1)+4) = 0.5;


mfe = 10000*length(m0);
fminsearchoptions = optimset('MaxFunEvals',mfe,'MaxIter',mfe,'TolFun',1e-4,'Display','off');

m_length = length(m0);
[m_best, bestscore] = fminsearch(@(m) double_gaussian_fit_function(m,histogram_matrix), m0, fminsearchoptions);

m_limits = [];
for(i=1:length(m0))
    if(m0(i)~=0)
        m_limits(i,:) = [m0(i)/100 m0(i)*100];
    else
        m_limits(i,:) = [-10 10];
    end
end

for(i=1:20)
    m01=[];
    for(j=1:m_length)
        m01(j) = bracketed_rand(m_limits(j,:));
    end
    [m, score] = fminsearch(@(m) double_gaussian_fit_function(m,histogram_matrix), m01, fminsearchoptions);
    if(score<bestscore)
        m_best = m;
        bestscore = score;
    end
end

m = m_best;


% y = histogram_matrix(1,:)/nansum(histogram_matrix(1,:));
% [~,max_idx] = max(y);
% x = 1:size(histogram_matrix,2);
% st = sprintf('y(x) = (exp(-((x-(mu))^2)/(2*abs(s)^2)))/(abs(s)*sqrt(2*pi)); mu = %f; s = %f',max_idx,1);
% f1 = ezfit(x,y,st);
% mu(1) = (f1.m(1)); s(1) = abs(f1.m(2));
%
% y = histogram_matrix(end,:)/nansum(histogram_matrix(end,:));
% [~,max_idx] = max(y);
% x = 1:size(histogram_matrix,2);
% st = sprintf('y(x) = (exp(-((x-(mu))^2)/(2*abs(s)^2)))/(abs(s)*sqrt(2*pi)); mu = %f; s = %f',max_idx,1);
% f1 = ezfit(x,y,st);
% mu(2) = (f1.m(1)); s(2) = abs(f1.m(2));
%
% m0 = zeros(1,size(histogram_matrix,1)) + 0.5;
% m = fminsearch(@(m) double_gaussian_fit_function_fixed_mu_s(m,histogram_matrix, mu,s), m0, fminsearchoptions);
% m = abs(m);
% m = [mu(1) s(1) mu(2) s(2) m];

mu1 = m(1);
s1 = m(2);
mu2 = m(3);
s2 = m(4);
A1_vector = hist_sum_vector.*abs(m(5:end));

e1 = (2*s1^2);
d1 = (s1*sqrt(2*pi));
e2 = (2*s2^2);
d2 = (s2*sqrt(2*pi));
xx = 1:size(histogram_matrix,2);

score = 0;
fitted_hist_matrix = [];
for(i=1:size(histogram_matrix,1))
    A1 = A1_vector(i);
    A2 = 1- A1;
    
    y = A1*(exp(-((xx-mu1).^2)/e1))/d1 + A2*(exp(-((xx-mu2).^2)/e2))/d2;
    
    fitted_hist_matrix = [fitted_hist_matrix; y];
    
    score = score + nansum((abs(y-histogram_matrix(i,:))).^2);
end

A1_vector_error = (sqrt(A1_vector.*(1-A1_vector)./length(A1_vector)))./sqrt(length(A1_vector));

return;
end

function score = double_gaussian_fit_function(m, histogram_matrix)

xx = 1:size(histogram_matrix,2);

mu1 = m(1);
s1 = m(2);
mu2 = m(3);
s2 = m(4);

e1 = (2*s1^2);
d1 = (s1*sqrt(2*pi));
e2 = (2*s2^2);
d2 = (s2*sqrt(2*pi));

score = 0;
for(i=1:size(histogram_matrix,1))
    A1 = abs(m(i+4));
    A2 = 1- A1;
    
    y = A1*(exp(-((xx-mu1).^2)/e1))/d1 + A2*(exp(-((xx-mu2).^2)/e2))/d2;
    
    score = score + nansum((abs(y-histogram_matrix(i,:))).^2);
    
end



return;
end


function score = double_gaussian_fit_function_fixed_mu_s(m, histogram_matrix, mu,s)

xx = 1:size(histogram_matrix,2);

mu1 = mu(1);
s1 = s(1);
mu2 = m(2);
s2 = s(2);

e1 = (2*s1^2);
d1 = (s1*sqrt(2*pi));
e2 = (2*s2^2);
d2 = (s2*sqrt(2*pi));

score = 0;
for(i=1:size(histogram_matrix,1))
    A1 = abs(m(i));
    A2 = 1- A1;
    
    y = A1*(exp(-((xx-mu1).^2)/e1))/d1 + A2*(exp(-((xx-mu2).^2)/e2))/d2;
    
    score = score + nansum((abs(y-histogram_matrix(i,:))).^2);
    
end

return;
end

