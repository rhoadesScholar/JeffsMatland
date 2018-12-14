function [beta R2 edgesshort c_elements edges exp1] = ratesingle_old(ndo,name)

% ndo = input column vector of dwell times
% name = string input for graph name
% beta = linear coefficients.
%     beta(1) = y-axis cross
%     beta(2) = tau (time constant)
% R2 = R2 fit of linear model to data
% edgeshort = x-axis vector for plotted data
% c_elements = y-axis vector for plotted data
% edges = x-axis vector for fit line
% exp1 = y-axis vector for fit line
% 

ndo = sortrows(ndo);
maxt = max(ndo);
mint = min(ndo);
% edges = 0:maxt/100:maxt;
edges = mint:maxt/length(ndo):maxt;

n_elements = histc(ndo,edges);
c_elements = cumsum(n_elements);
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

c_elements = log(c_elements);

[c_elements I] = condense(c_elements);
edgesshort = edges;
edgesshort(I) = [];


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



figure;
h=plot(edgesshort,c_elements,'b');
set(h,'LineStyle','none','Marker','o','LineWidth',2);
hold on
plot(edges,exp1,'r','LineWidth',2);
axis([0 max(edges) min(c_elements) max(c_elements)]);
xlabel('\tau (sec).','FontSize',14);
ylabel('P(t>\tau)','FontSize',14);
title(name,'FontSize',14);
x = max(edges) - 0.25*max(edges);
text(x,-1,['\tau = ',num2str(beta(2))],'FontSize',12);

