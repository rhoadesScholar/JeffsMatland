function [firstOrderCells firstOrderSynapses cells synapses] = Find_Roaming_Output_MultipleIt(cellofint,numIterations)
    [firstOrderCells firstOrderSynapses] = Find_Roaming_Output(cellofint);
    %[cells synapses] = Find_Roaming_Output_Reverberate(firstOrderCells,firstOrderSynapses,numIterations);
    [secondOrderCells secondOrderSynapses] = Find_Roaming_Output_Reverberate(firstOrderCells,firstOrderSynapses,1);
    [thirdOrderCells thirdOrderSynapses] = Find_Roaming_Output_Reverberate(secondOrderCells,secondOrderSynapses,1);
    [fourthOrderCells fourthOrderSynapses] = Find_Roaming_Output_Reverberate(thirdOrderCells,thirdOrderSynapses,1);
    [fifthOrderCells fifthOrderSynapses] = Find_Roaming_Output_Reverberate(fourthOrderCells,fourthOrderSynapses,1);
    [sixthOrderCells sixthOrderSynapses] = Find_Roaming_Output_Reverberate(fifthOrderCells,fifthOrderSynapses,1);
    
    
end

cells = secondOrderCells;
synapses = secondOrderSynapses;

cellIndex = find(ismember(cells,checkCell)==1);

firstCellIndex = find(synapses(cellIndex,:)>0);

firstOrderCells(firstCellIndex)
synapses(cellIndex,firstCellIndex)





cells = firstOrderCells;
synapses = firstOrderSynapses;

cellIndex = find(ismember(cells,checkCell)==1);

firstCellIndex = find(synapses(cellIndex,:)>0);

cellofint(firstCellIndex)
synapses(cellIndex,firstCellIndex)




