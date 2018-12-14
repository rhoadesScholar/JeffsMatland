function [output_cells FinalOutput_Fraction] = Find_Roaming_Output_Reverberate(cells,synapses,NumHops)

%[cells synapses] =  Find_Roaming_Output(1);

cellofint = cells;

for(i=1:length(cells)) weights(i) = sum(synapses(i,:)); end


FinalOutput = zeros(40,length(cellofint));
output_cells = cell(0);
outputIndex = 1;

for(i=1:length(cells))
    outputHere = findneighbors(cellofint{i},1);
    display(cellofint{i});
   if(length(outputHere)>1)
    
    if(isfield(outputHere(1),'downstream'))
    output_syn_names = [outputHere(1).downstream]; 
    else
        output_syn_names = [];
    end
    
    if(isfield(outputHere(2),'downstream'))
    output_syn_names = [output_syn_names outputHere(2).downstream]; 
    end
    
    if(isfield(outputHere(1),'gapneighbor'))
        output_syn_names = [output_syn_names outputHere(1).gapneighbor];
    end
    if(isfield(outputHere(2),'gapneighbor'))
        output_syn_names = [output_syn_names outputHere(2).gapneighbor];
    end
    if(isfield(outputHere(1),'downstream'))
    output_syn_number = [outputHere(1).downstrength]; 
    else
        output_syn_number = [];
    end
    
    if(isfield(outputHere(2),'downstream'))
    output_syn_number = [output_syn_number outputHere(2).downstrength]; 
    end
    
    
    
    if(isfield(outputHere(1),'gapneighbor'))
        output_syn_number = [output_syn_number outputHere(1).gapstrength];
    end
    
    if(isfield(outputHere(2),'gapneighbor'))
        output_syn_number = [output_syn_number outputHere(2).gapstrength];
    end
   else
    if(isfield(outputHere,'downstream'))    
    output_syn_names = [outputHere.downstream]; 
    else
        output_syn_names = [];
    end
    
    if(isfield(outputHere,'gapneighbor'))
        output_syn_names = [output_syn_names outputHere.gapneighbor];
    end
    
    
    if(isfield(outputHere,'downstream'))  
    output_syn_number = [outputHere.downstrength]; 
    else
        output_syn_number = [];
    end
    if(isfield(outputHere,'gapneighbor'))
        output_syn_number = [output_syn_number outputHere.gapstrength];
    end
    end
        
        
    for(j=1:length(output_syn_names))
        cellName = output_syn_names(j);
        lengthCellName = length(cellName{1});
        if(lengthCellName>3)
            lastchar = cellName{1}(end);
            if(strcmp(lastchar,'R') || strcmp(lastchar,'L'))
                lengthNewCellName = lengthCellName - 1;
                newcellName = cellName{1}(1:lengthNewCellName);
                if(strcmp(newcellName,'RMF'))
                else
                    if(strcmp(newcellName,'SDQ'))
                    else
                       if(strcmp(newcellName,'PLM'))
                       else
                         if(strcmp(newcellName,'PVD'))
                         else
                            if(strcmp(newcellName,'PHC'))
                            else
                               if(strcmp(newcellName,'AIM'))
                               else
                                 if(strcmp(newcellName,'ALN'))
                                 else
                                       if(strcmp(newcellName,'AIN'))
                                       else
                                            if(strcmp(newcellName,'PLN'))
                                            else
                                            cellName = newcellName;
                                            end
                                       end
                                 end
                               end
                            end
                         end
                       end
                    end
                end
            end
        end
        AlreadyPresent = find(ismember(output_cells,cellName)==1);
        if(AlreadyPresent>0)
            FinalOutput(AlreadyPresent,i) = FinalOutput(AlreadyPresent,i) + (output_syn_number(j)*weights(i));
        else
            output_cells = [output_cells cellName];
            FinalOutput(outputIndex,i) = (output_syn_number(j)*weights(i));
            outputIndex = outputIndex + 1;
        end
    end
end

FinalOutput_Fraction = FinalOutput;

for(i=1:length(output_cells))
    cellHere = output_cells{i};
    display(cellHere)
    cellInfo = findneighbors(cellHere,1);
    if(length(cellInfo)==1)
    if(isfield(cellInfo,'upstrength'))
        display(cellHere)
        totalinputs  = sum(cellInfo.upstrength);
    else 
        totalinputs = 0;
    end
    if(isfield(cellInfo,'gapneighbor'))
        totalinputs = totalinputs + sum(cellInfo.gapstrength);
    end
    FinalOutput_Fraction(i,:) = FinalOutput_Fraction(i,:)/totalinputs;
    else
        
    if(isfield(cellInfo(1),'upstrength'))
        totalinputs  = sum(cellInfo(1).upstrength);
    else 
        totalinputs = 0;
    end
    if(isfield(cellInfo(1),'gapneighbor'))
        totalinputs = totalinputs + sum(cellInfo(1).gapstrength);
    end
    if(isfield(cellInfo(2),'upstrength'))
        totalinputs  = totalinputs + sum(cellInfo(2).upstrength);
    end
    if(isfield(cellInfo(2),'gapneighbor'))
        totalinputs = totalinputs + sum(cellInfo(2).gapstrength);
    end
    end
    FinalOutput_Fraction(i,:) = FinalOutput_Fraction(i,:)/totalinputs;
    
end

    