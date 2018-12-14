function [tau,h,p,stats] = getSumLeastSqRes_SingleExp(ndo)
    
n = length(ndo);
a = min(ndo);
c = max(ndo);



%f1(x) = bounded power law


beta = [a c n];
k2 = fminsearch(@(k) delexpdelk(ndo,k,beta),2);
%L(2) = likeexpbound(x,k2,beta);
tau = k2^-1;


ndo = sortrows(ndo);
maxt = max(ndo);
mint = min(ndo);
% edges = 0:maxt/100:maxt;
edges = mint:maxt/length(ndo):maxt;

n_elements = histc(ndo,edges);
c_elements = cumsum(n_elements);
c = max(c_elements) - c_elements;
% c_elements = 1 - c_elements/max(c_elements);
% c_elements = [1;c_elements];
% c_elements(size(c_elements,1),:) = [];
c_elements = 1-c_elements/max(c_elements);
x = [];
for m=1:length(c_elements)
    if c_elements(m)==0
        x = [x m];
    end
end
c_elements(x) = [];
edges(x) = [];
c(x) = [];

c_elements = log(c_elements);
[c_elements I] = condense(c_elements);
edgesshort = edges;
edgesshort(I) = [];
c(I) = [];

% chi2 test
x = [];
for m=length(c):-1:1
    if c(m) < 5
        x = m;
    end
end

c(x:end) = [];
edgetemp = edgesshort;
edgetemp(x+1:end) = [];



X = [ones(length(edgesshort),1) edgesshort'];
beta = X\c_elements;
exp1 = X*beta;
residnum = sum((c_elements-exp1).^2);
residden = sum((c_elements-mean(c_elements)).^2);
R2 = 1-(residnum/residden);

X = [ones(length(edges),1) edges'];

exp1 = X*beta;

beta(1) = exp(beta(1));
beta(2) = -1/beta(2);

y = exp(-edges./tau);
ratesingle(ndo,'',1,0);
hold on;
plot(edges,log(y),'r','LineWidth',2);

expected = max(c)*exp(-edgetemp(1:end-1)./tau);



[h,p,stats] = chi2gof(c,'edges',edgetemp','expected',expected,'nparams',1);



% allResiduals = [];
% 
% for(i=1:length(c_elements))
%     Xdatapoint = edgesshort(i);
%     Ydatapoint = c_elements(i);
%     PredictedYdatapoint = log(exp(-Xdatapoint/tau));
%     display(Xdatapoint);
%     display(Ydatapoint);
%     display(PredictedYdatapoint)
%     diffSquared = (Ydatapoint - PredictedYdatapoint)^2;
%     display(diffSquared)
%     allResiduals = [allResiduals diffSquared];
% end
% 
% sumLeastSquaresRes = sum(allResiduals);


end