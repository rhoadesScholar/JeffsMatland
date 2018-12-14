function [mean_tau1 mean_tau2 mean_w std_tau1 std_tau2 std_w n] = bootstrap_doubleExp_Durations(durFile)
    numAnim = max(durFile(2,:))
    allData = struct('datapoints',[]);
    index = 1;
    for(i=1:numAnim)
        ColIndicesforAnim = [];
        ColIndicesforAnim = find(durFile(2,:)==i);
        if(ColIndicesforAnim>0)
            dataPointsforAnim = durFile(1,ColIndicesforAnim);
            display(i)
            display(dataPointsforAnim)
            allData(index).datapoints = dataPointsforAnim;
            index = index+1;
        end
    end
    
    
bootstrapnum = 100;

experiments = length(allData);

wvalues = zeros(bootstrapnum,1);
tau1values = zeros(bootstrapnum,1);
tau2values = zeros(bootstrapnum,1);

for m=1:bootstrapnum
    dataThisIter = [];
    randnum = ceil(experiments*rand(1,experiments));
    for(j=1:experiments)
        dataThisIter = [dataThisIter allData(randnum).datapoints];
    end
    [beta p h edgesshort c_elements edges exp1] = ratedouble(dataThisIter',[0.5 50 500],'roamstates',0);
    wvalues(m) = beta(1);
    tau1values(m) = beta(2);
    tau2values(m) = beta(3);
end

mean_w = mean(wvalues);
mean_tau1 = mean(tau1values);
mean_tau2 = mean(tau2values);
std_w = std(wvalues);
std_tau1 = std(tau1values);
std_tau2 = std(tau2values);
n = experiments;
end
