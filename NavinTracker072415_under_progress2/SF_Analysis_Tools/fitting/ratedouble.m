function [beta p h edgesshort c_elements edges exp1] = ratedouble(data,beta0,graphname,plotThis)

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

expected = max(c)*(beta(1)*exp(-edgetemp(1:end-1)/beta(2)) + (1-beta(1))*exp(-edgetemp(1:end-1)/beta(3)));
[h,p] = chi2gof(c,'edges',edgetemp','expected',expected,'nparams',3);
exp1 = log(beta(1)*exp(-edges/beta(2)) + (1-beta(1))*exp(-edges/beta(3)));

%%%Convert back to non-log scale
c_elements = exp(c_elements);
exp1 = exp(exp1);

%%%%%%Make the single exponentials



if(plotThis==1)
figure;
z=plot(edgesshort,c_elements,'b');
set(z,'LineStyle','none','Marker','o','LineWidth',2);
hold on
plot(edges,exp1,'r','LineWidth',2);

% hold on;
% plot(edges,exp(-edges/beta(2)),'b','LineWidth',1);
% plot(edges,exp(-edges/beta(3)),'b','LineWidth',1);


axis([0 max(edges) min(c_elements) max(c_elements)]);
xlabel('\tau (sec).','FontSize',14);
ylabel('P(t>\tau)','FontSize',14);
title(graphname,'FontSize',14);
x = max(edges) - 0.25*max(edges);
text(x,-1,['w = ',num2str(beta(1))],'FontSize',12);
text(x,-2,['\tau_1 = ',num2str(beta(2))],'FontSize',12);
text(x,-3,['\tau_2 = ',num2str(beta(3))],'FontSize',12);
end