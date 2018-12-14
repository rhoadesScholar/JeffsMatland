function [weight tau1 tau2 h p stats] = getSumLeastSqRes_DoubleExp(data,beta0)
    

optFunc = fminsearch(@(beta2) divlike2exp(data,beta2),beta0);
%L(2) = likeexpbound(x,k2,beta);
weight = optFunc(1);
tau1 = optFunc(2);
tau2 = optFunc(3);


maxt = max(data);
mint = min(data);
edges = mint:maxt/size(data,1):maxt;

n_elements = histc(data,edges);
c_elements = cumsum(n_elements);
c = max(c_elements) - c_elements;

c_elements = 1-c_elements/max(c_elements);
x = [];
for m=1:length(c_elements)
    if c_elements(m)==0
        x = [x m];
    end
end
c_elements(x) = [];
c(x) = [];
edges(x) = [];

c_elements = log(c_elements);

[c_elements I] = condense(c_elements);
edgesshort = edges;
edgesshort(I) = [];
c(I) = [];

beta = nlinfit(edgesshort',c_elements,@fexptwo,beta0);


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

y = log(weight*exp(-edges/tau1) + (1-weight)*exp(-edges/tau2));
ratesingle(data,'',1,0);
hold on;
plot(edges,y,'r','LineWidth',2);

expected = max(c)*(weight*exp(-edgetemp(1:end-1)/tau1) + (1-weight)*exp(-edgetemp(1:end-1)/tau2));

[h,p,stats] = chi2gof(c,'edges',edgetemp','expected',expected,'nparams',3);




% allResiduals = [];
% 
% 
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