function final_cells = Analyze_Output_Neurons(cells,synapses,minInputs,minFraction)


    for(j=1:length(synapses(:,1)))
        numMatches(j) = length(find(synapses(j,:)>0));
    end
    
    
    sufficientInputs = find(numMatches>=minInputs);
    
    subset_synapses = synapses(sufficientInputs,:);
    subset_cells = cells(sufficientInputs);
    
    for(j=1:length(subset_synapses(:,1)))
        sumInput(j) = sum(subset_synapses(j,:));
    end
    
    sufficientFraction = find(sumInput>=minFraction);
    
    final_cells = subset_cells(sufficientFraction);
end