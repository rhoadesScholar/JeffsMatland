function [output_cells FinalOutput_Fraction] = Find_Roaming_Output_NoPairs(NumHops)

cellofint = {'AIY' 'RIF' 'ASI' 'RIM' 'RIB' 'RIA' 'AVB' 'PVP'};
FinalOutput = zeros(40,8);
output_cells = cell(0);
outputIndex = 1;

for(i=1:8)
    outputHere = findneighbors(cellofint{i},1);
    output_syn_names = [outputHere(1).downstream outputHere(2).downstream]; 
    if(isfield(outputHere(1),'gapneighbor'))
        output_syn_names = [output_syn_names outputHere(1).gapneighbor];
    end
    if(isfield(outputHere(2),'gapneighbor'))
        output_syn_names = [output_syn_names outputHere(2).gapneighbor];
    end
        
    output_syn_number = [outputHere(1).downstrength outputHere(2).downstrength]; 
    if(isfield(outputHere(1),'gapneighbor'))
        output_syn_number = [output_syn_number outputHere(1).gapstrength];
    end
    
    if(isfield(outputHere(2),'gapneighbor'))
        output_syn_number = [output_syn_number outputHere(2).gapstrength];
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
                    cellName = newcellName;
                    end
                end
            end
        end
        AlreadyPresent = find(ismember(output_cells,cellName)==1);
        if(AlreadyPresent>0)
            FinalOutput(AlreadyPresent,i) = FinalOutput(AlreadyPresent,i) + output_syn_number(j);
        else
            output_cells = [output_cells cellName];
            FinalOutput(outputIndex,i) = output_syn_number(j);
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
    else 
        totalinputs = 0;
    end
    if(isfield(cellInfo(2),'gapneighbor'))
        totalinputs = totalinputs + sum(cellInfo(2).gapstrength);
    end
    end
    FinalOutput_Fraction(i,:) = FinalOutput_Fraction(i,:)/totalinputs;
end

    