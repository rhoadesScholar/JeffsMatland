function [output_cells FinalOutput_Fraction]  = Find_Roaming_Output(cellofint)

%cellofint = {'AIY' 'RIF' 'ASI' 'RIM' 'RIB' 'RIA' 'AVB' 'PVP'};
FinalOutput = zeros(40,length(cellofint));
output_cells = cell(0);
outputIndex = 1;

for(i=1:length(cellofint))
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
        AlreadyPresent = find(ismember(output_cells,output_syn_names(j))==1);
        if(AlreadyPresent>0)
            FinalOutput(AlreadyPresent,i) = FinalOutput(AlreadyPresent,i) + output_syn_number(j);
        else
            output_cells = [output_cells output_syn_names(j)];
            FinalOutput(outputIndex,i) = output_syn_number(j);
            outputIndex = outputIndex + 1;
        end
    end
end

FinalOutput_Fraction = FinalOutput;

for(i=1:length(output_cells))
    cellHere = output_cells{i};
    cellInfo = findneighbors(cellHere,1);
    
    if(isfield(cellInfo,'upstrength'))
        totalinputs  = sum(cellInfo.upstrength);
    else 
        totalinputs = 0;
    end
    if(isfield(cellInfo,'gapneighbor'))
        totalinputs = totalinputs + sum(cellInfo.gapstrength);
    end
    FinalOutput_Fraction(i,:) = FinalOutput_Fraction(i,:)/totalinputs;
end

    