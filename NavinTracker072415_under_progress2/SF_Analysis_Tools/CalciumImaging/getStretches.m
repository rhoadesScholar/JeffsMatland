%%%%%%%%%This function finds stretches of data where the fluorescence in
%%%%%%%%%the data are below an ActivityCutoff for a defined period of time


function LowActBeginning = getStretches(DataVector,ActivityCutoff,minDuration);
    HighActIndex = find(DataVector>ActivityCutoff);
    LowActIndex = find(DataVector<=ActivityCutoff);
    
    DataVector(HighActIndex) = 2;
    DataVector(LowActIndex) = 1;
    
    LowActivityTable = [];
    
    outputIndex = 1;
    
    %OKtoCountFlag = 1;
    
    currentState = DataVector(1);
    lastState = DataVector(1);
    TimeInCurrentState=1;
    
    changeStateCounter = 0;
    
    for(i=2:length(DataVector));
        if(isnan(DataVector(i)))
            TimeInCurrentState = TimeInCurrentState+1;
        else
        currentState = DataVector(i);
        if(currentState==lastState)
            changeStateCounter = 0;
            TimeInCurrentState = TimeInCurrentState+1;
            %if(currentState==1)
            %    if(TimeInCurrentState>600)
            %        OKtoCountFlag=1;
            %    end
            %end
        else
            changeStateCounter = changeStateCounter+1;
            if(changeStateCounter>minDuration)
                if(currentState==1)
                    %if(OKtoCountFlag==1)
                    LowActivityTable(outputIndex,1) = i;
                    LowActivityTable(outputIndex,2) = i-1;
                    outputIndex = outputIndex+1;
                    %end
                    %OKtoCountFlag = 0;
                end

                    TimeInCurrentState = 1;
                    lastState = DataVector(i);
            else
                TimeInCurrentState = TimeInCurrentState+1;
                %if(lastState==1)
                    %if(TimeInCurrentState>600)
                    %    OKtoCountFlag=1;
                    %end
               %end
            end
        end
    end
    end

    LowActBeginning = length(DataVector);
    sizeofTable = size(LowActivityTable);
    if(sizeofTable(1)>0)
        LowActBeginning = LowActivityTable(1,1);
    end
    
end
