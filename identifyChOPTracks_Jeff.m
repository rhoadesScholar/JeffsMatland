  %%%%%%%%%%%% Function to identify animals that were in the stimulus range @
%%%%%%%%%%%% the time that ChOP light was illuminated.  Input is a
%%%%%%%%%%%% finalTracks file and output is: (1) a ChOPfinalTracks file (2)
%%%%%%%%%%%% visual display of all appropriate tracks, including state
%%%%%%%%%%%% calls and shading where ChOP was active
% Editted by J Rhoades Nov 2017

function ChOPfinalTracks = identifyChOPTracks_Jeff(allLinkedTracks,stimulusfile,stimtoIncl, buffer)
    %load stimulus and initialize variables
    stimulus = load(stimulusfile);
    strains = fields(allLinkedTracks);
    for s = 1:length(strains)
        linkedTracks = allLinkedTracks.(strains{s});
        TracksInStim = [];
        TrackInclusionIndex = 1;

        %go through each stimulus and determine which tracks have useful data
        %that overlaps at least one stimulus
        for i=stimtoIncl       
            display(i)
            startpoint = stimulus(i,1) - buffer;
            stoppoint = stimulus(i,2);
            startpointFrame = startpoint*linkedTracks(1).FrameRate;
            stoppointFrame = stoppoint*linkedTracks(1).FrameRate;
            for j=1:length(linkedTracks)
                startIndex = find(linkedTracks(j).Frames ==startpointFrame);
                stopIndex = find(linkedTracks(j).Frames==stoppointFrame);
                check = length(startIndex) + length(stopIndex);
                if(check==2)       
                      TracksInStim(TrackInclusionIndex,1:2) = [i, j];
                      TrackInclusionIndex = TrackInclusionIndex +1;
                end
            end
        end

        %%%%%%%%%%  Add field to ChOPfinalTracks that says which timeframe it
        %%%%%%%%%%  was in right place (this field is "stimulusvector")

        for i=1:length(TracksInStim(:,1))
            currentStim = TracksInStim(i,1);
            FirstFrame = linkedTracks(TracksInStim(i,2)).Frames(1);
            linkedTracks(TracksInStim(i,2)).stimulus_vector(((stimulus(currentStim,1)*3)-FirstFrame+1):((stimulus(currentStim,2)*3)-FirstFrame)) = currentStim;        
        end

        %Make output
        ChOPTrackIndices = unique(TracksInStim(:,2));
        ChOPfinalTracks.(strains{s}) = linkedTracks(ChOPTrackIndices);
    end
end







         