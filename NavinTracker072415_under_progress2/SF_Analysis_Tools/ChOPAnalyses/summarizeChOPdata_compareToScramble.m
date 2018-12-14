% Takes a folder, finds linkedTracks files within the embedded folders, 
% calculates the HMM for these data, finds the animals that were within the ROI 
% at appropriate times and gives back data in matrix form, where each line
% is a single time that an animal was hit with the LED:

% column 1: track number (i.e. anim #);
% column 2: stimulus numb (e.g. 5th of out of 6 stim)
% column 3: average state for the minute before the light was illuminated
% column 4: average state for the minute after the light is shut off
% columns 5-814: speed over t = -2min, 30sec pulse, +2min (4.5 min total)
% columns 815-1624: angspeed over this time
% columns 1625-2434: state calls over this time



function [AllChOPHits ControlChOPHits FullControlChOPHits NumberofFOI] = summarizeChOPdata(folder,stimulusfile,ROImovie,C128SFlag,stimtoIncl)
    PathofFolder = sprintf('%s',folder);
    
    dirList = ls(PathofFolder);
    
    NumFolders = length(dirList(:,1));
    display(dirList)
    display(NumFolders)
    allTracks = [];
    for(i = 3:NumFolders)
        string1 = deblank(dirList(i,:)); 
        
        PathName = sprintf('%s/%s/',PathofFolder,string1);
        fileList = ls(PathName);
        display(fileList)
        numFiles = length(fileList(:,1));
        
        for(j=3:1:numFiles)
            string2 = deblank(fileList(j,:));
            [pathstr, FilePrefix, ext, versn] = fileparts(string2);
            [pathstr2, FilePrefix2, ext2, versn2] = fileparts(FilePrefix);
           
            if(strcmp(ext2,'.linkedTracks')==1)
                fileIndex = j;
            end
        end
        fileName = deblank(fileList(fileIndex,:));
        fileToOpen = sprintf('%s%s',PathName,fileName);
        display(fileToOpen)
        load(fileToOpen);
        allTracks = [allTracks linkedTracks];
    end
    
    
    
    index1 = 1;
    %%%%%%find relevant tracks
    ChOPfinalTracks = identifyChOPTracks(allTracks,stimulusfile,ROImovie,0,C128SFlag,stimtoIncl);
   %%%%%%%%%%calculate HMM based on all data from all animals
    [expNewSeq1 expStates1 estTR estE] = getHMMStates(allTracks,30);
    %%%%%%%%%Apply HMM to relevant tracks only
    [expNewSeq expStates estTR estE] = getHMMStatesSpecifyTRandE_2(ChOPfinalTracks,30,estTR,estE);
    
    stimulus = load(stimulusfile);
    
    lengthofStimFrames = ((stimulus(stimtoIncl(1),2)-stimulus(stimtoIncl(1),1)) * 3) + 1;
    lengthofGreenFrames = ((stimulus(stimtoIncl(1)+1,2)-stimulus(stimtoIncl(1)+1,1)) * 3) + 1;
    for(i=1:length(ChOPfinalTracks))
        if(C128SFlag==1)
            BlueFrames = find(ChOPfinalTracks(i).stimulus_vector==1);
            GreenFrames = find(ChOPfinalTracks(i).stimulus_vector==2);
        end
        ChOPFrames = find(ChOPfinalTracks(i).stimulus_vector==1);
        

        
        
        
        %display(ChOPFrames)
        numChOPFrames = length(ChOPFrames);
        numStimuli = numChOPFrames/lengthofStimFrames;
        display(numStimuli)
        for(j=1:numStimuli)
            if(C128SFlag==1)
                StartIndex = (BlueFrames((lengthofStimFrames*j)-(lengthofStimFrames-1)))-360;
                StopIndex = StartIndex+359+lengthofStimFrames+lengthofGreenFrames-2+360;
            else
            StartIndex = (ChOPFrames((lengthofStimFrames*j)-(lengthofStimFrames-1)))-360;
            display(StartIndex)
            StopIndex = StartIndex+809;
            display(StopIndex)
            end
            
            if(StartIndex>0)
                if(StopIndex<length(expStates(i).states))
            Tracknumb = i;
            AllChOPHits(index1,1) = Tracknumb;
            ControlChOPHits(index1,1) = Tracknumb;
            FullControlChOPHits(((index1*10)-9):(index1*10),1) = Tracknumb;
            StartFrame = ChOPfinalTracks(i).Frames(StartIndex+360);
            Stimuli = (stimulus(:,1))*3;
            
          
            StimulusNumb = unique(find(Stimuli==StartFrame));
            display(StimulusNumb)
            AllChOPHits(index1,2) = StimulusNumb;
            ControlChOPHits(index1,2) = StimulusNumb;
            FullControlChOPHits(((index1*10)-9):(index1*10),2) = StimulusNumb;
            display(expStates(i).states)
            StateCalls = expStates(i).states(StartIndex:StopIndex);
            PriorState = round(nanmean(StateCalls(181:360)));
            NumberofFOI = StopIndex-StartIndex+1;
            %%%%%%%%Seed a Start Frame at random, find prior state, if it
            %%%%%%%%doesn't match the one in question, then retry until it
            %%%%%%%%does...
            %%%%%%%%Earlier, create a ControlChopHits file with same
            %%%%%%%%formatting........Then feed in data, as I do below.
            cntrlflag=0;
            while(cntrlflag==0)
                randplace = rand(1);
                ControlStopIndex = round(randplace*(length(expStates(i).states)));
                ControlStartIndex = ControlStopIndex-359-lengthofStimFrames-lengthofGreenFrames+2-360;
                
                while(ControlStartIndex<1)
                    randplace = rand(1);
                    ControlStopIndex = round(randplace*(length(expStates(i).states)));
                    ControlStartIndex = ControlStopIndex-359-lengthofStimFrames-lengthofGreenFrames+2-360;
                end
         
             ControlStateCalls = expStates(i).states(ControlStartIndex:ControlStopIndex);
             ControlPriorState = round(nanmean(ControlStateCalls(181:360)));
             if(ControlPriorState==PriorState)
                 cntrlflag=1;
             end
            end
            
            DurationofWindow = ControlStopIndex-ControlStartIndex;
            fullcnt = 1;
            while(fullcnt<11)
                randplace = rand(1);
                FullControlStopIndex = round(randplace*(length(expStates(i).states)));
                FullControlStartIndex = FullControlStopIndex-359-lengthofStimFrames-lengthofGreenFrames+2-360;
                
                while(FullControlStartIndex<1)
                    randplace = rand(1);
                    FullControlStopIndex = round(randplace*(length(expStates(i).states)));
                    FullControlStartIndex = FullControlStopIndex-359-lengthofStimFrames-lengthofGreenFrames+2-360;
                end
         
             FullControlStateCalls = expStates(i).states(FullControlStartIndex:FullControlStopIndex);
             FullControlPriorState = round(nanmean(FullControlStateCalls(181:360)));
             
             if(FullControlPriorState==PriorState)
                 FullControlPriorData(fullcnt) = FullControlPriorState;
                 if(C128SFlag==1)
                    FullControlResultingState(fullcnt) = round(nanmean(FullControlStateCalls((360+lengthofStimFrames+lengthofGreenFrames):((360+lengthofStimFrames+lengthofGreenFrames)+179))));
                    else
                    FullControlResultingState(fullcnt) = round(nanmean(FullControlStateCalls(451:630)));
                 end
                 
                 FullControlSpeedHere = ChOPfinalTracks(i).Speed(FullControlStartIndex:FullControlStopIndex);
                 length(FullControlSpeedHere)
                 display(NumberofFOI)
                 display(FullControlStartIndex)
                 display(FullControlStopIndex)
                 FullControlSpeedData(fullcnt,1:NumberofFOI) = FullControlSpeedHere(1:NumberofFOI);
                 
                 FullControlAngSpeedHere = ChOPfinalTracks(i).AngSpeed(FullControlStartIndex:FullControlStopIndex);
                 FullControlAngSpeedData(fullcnt,1:NumberofFOI) = FullControlAngSpeedHere(1:NumberofFOI);
                 
                 
                 FullControlStateData(fullcnt,1:NumberofFOI) = FullControlStateCalls(1:NumberofFOI)
                
                 fullcnt = fullcnt+1;
               
             end
            end
            
            
            
            
            AllChOPHits(index1,3) = PriorState;
            ControlChOPHits(index1,3) = ControlPriorState;
            FullControlChOPHits(((index1*10)-9):(index1*10),3) = FullControlPriorState;
            
            FullControlChOPHits(((index1*10)-9):(index1*10),4) = FullControlResultingState(1:10)';
            
            FullControlChOPHits(((index1*10)-9):(index1*10),5:(NumberofFOI+4)) = FullControlSpeedData(1:10,1:NumberofFOI);
            
            FullControlChOPHits(((index1*10)-9):(index1*10),(NumberofFOI+5):((2*NumberofFOI)+4)) = FullControlAngSpeedData(1:10,1:NumberofFOI);
            
            FullControlChOPHits(((index1*10)-9):(index1*10),((2*NumberofFOI)+5):((3*NumberofFOI)+4)) = FullControlStateData(1:10,1:NumberofFOI);
            
            if(C128SFlag==1)
                ResultingState = round(nanmean(StateCalls((360+lengthofStimFrames+lengthofGreenFrames):((360+lengthofStimFrames+lengthofGreenFrames)+179))));
                ControlResultingState = round(nanmean(ControlStateCalls((360+lengthofStimFrames+lengthofGreenFrames):((360+lengthofStimFrames+lengthofGreenFrames)+179))));
            else
                ResultingState = round(nanmean(StateCalls(451:630)));
                ControlResultingState = round(nanmean(ControlStateCalls(451:630)));
            end
            AllChOPHits(index1,4) = ResultingState;
            ControlChOPHits(index1,4) = ControlResultingState;
            
            
            Speed = ChOPfinalTracks(i).Speed(StartIndex:StopIndex);
            ControlSpeed = ChOPfinalTracks(i).Speed(ControlStartIndex:ControlStopIndex);
            
            AllChOPHits(index1,5:(NumberofFOI+4)) = Speed(1:NumberofFOI)
            ControlChOPHits(index1,5:(NumberofFOI+4)) = ControlSpeed(1:NumberofFOI);
            
            AngSpeed = ChOPfinalTracks(i).AngSpeed(StartIndex:StopIndex);
            ControlAngSpeed = ChOPfinalTracks(i).AngSpeed(ControlStartIndex:ControlStopIndex);
            
            AllChOPHits(index1,(NumberofFOI+5):((2*NumberofFOI)+4)) = AngSpeed(1:NumberofFOI);
            ControlChOPHits(index1,(NumberofFOI+5):((2*NumberofFOI)+4)) = ControlAngSpeed(1:NumberofFOI);
            
            AllChOPHits(index1,((2*NumberofFOI)+5):((3*NumberofFOI)+4)) = StateCalls(1:NumberofFOI);
            ControlChOPHits(index1,((2*NumberofFOI)+5):((3*NumberofFOI)+4)) = ControlStateCalls(1:NumberofFOI);
            index1 = index1+1;
                end
            end
        end
        
    end
            
    
    