function finalTracks = processTracks (folder) % Folder should have all files for one video

%find the 3 tracks files and delete them - also open procFrame

PathofFolder = sprintf('%s',folder);
PathName = sprintf('%s/%s/',PathofFolder);

fileList = ls(PathofFolder);
       
numFiles = length(fileList(:,1));

indexHere = 1;
for(j=3:1:numFiles)
    string2 = deblank(fileList(j,:));
    [pathstr, FilePrefix, ext] = fileparts(string2);
    [pathstr2, FilePrefix2, ext2] = fileparts(FilePrefix);

    if(strcmp(ext2,'.Tracks')==1 || strcmp(ext2,'.rawTracks')==1 || strcmp(ext2,'.linkedTracks')==1||strcmp(ext2,'.collapseTracks')==1)
        fileName = deblank(fileList(j,:));
        filesToDelete{indexHere} = sprintf('%s%s',PathName,fileName);
        indexHere = indexHere+1;
    end
    
    if(strcmp(ext2,'.Tracks')==1)
        fileName = deblank(fileList(j,:));
        fileToOpen = sprintf('%s%s',PathName,fileName);
        load(fileToOpen)
    end
    
    if(strcmp(ext2,'.procFrame')==1)
        fileName = deblank(fileList(j,:));
        fileToOpen = sprintf('%s%s',PathName,fileName);
        load(fileToOpen)
    end
end

%get info on Tracks, then delete

trackHeight = Tracks(1).Height;
trackWidth = Tracks(1).Width;
PixelSizeVideo = Tracks(1).PixelSize;
FrameRateVideo = Tracks(1).FrameRate;
TrackName = Tracks(1).Name;
[pathstr3, FilePrefix_ForTrack, ext3] = fileparts(TrackName);

for(j=1:(indexHere-1))
    delete(filesToDelete{j});
end

clear('indexHere');
clear('Tracks');

%Initialize Prefs

global Prefs;

OPrefs = Prefs;

Prefs = [];
Prefs = define_preferences(Prefs);
Prefs.PixelSize = PixelSizeVideo;
Prefs = CalcPixelSizeDependencies(Prefs, Prefs.PixelSize);


%Make rawTracks and Tracks
 Prefs.aggressive_linking = 0;
 rawTracks = create_tracks_LinkMiss(procFrame, trackHeight, trackWidth, PixelSizeVideo, FrameRateVideo, TrackName);
 
 [Tracks, linkedTracks] = analyse_rawTracks_LinkMiss(rawTracks, [], PathName, FilePrefix_ForTrack);
 
  %Save rawTracks
  
  FileName = sprintf('%s.rawTracks.mat',FilePrefix_ForTrack);
  dummystring = sprintf('%s%s',PathName,FileName);
  save_Tracks(dummystring, rawTracks);
  disp([sprintf('%s saved %s\n', dummystring, timeString())])

% Re-Do linkage (from beginning) with new prefs for ON-FOOD, no-care for direction, agg=0,
% and set to 'missing' - use Tracks file


Prefs.MaxCentroidShift_mm_per_sec =.125;
Prefs.MaxTrackLinkSeconds = 108;
Prefs.PixelSize = PixelSizeVideo;
Prefs = CalcPixelSizeDependencies(Prefs, Prefs.PixelSize);

linkedTracks = link_tracks(Tracks, 1, 0, 1, 'missing'); % no direction variable
Tracks=linkedTracks;

%%%save linkedTracks

  FileName = sprintf('%s.linkedTracks.mat',FilePrefix_ForTrack);
  dummystring = sprintf('%s%s',PathName,FileName);
  save_Tracks(dummystring, linkedTracks);
  disp([sprintf('%s saved %s\n', dummystring, timeString())])

%%%%%%%%%Deal with collisions 

%%%Add "Path" field to Tracks file

for(i=1:length(Tracks))
    numFr = Tracks(i).NumFrames;
    for(j=1:numFr)
        Tracks(i).Path(j,1:2) = [Tracks(i).SmoothX(j) Tracks(i).SmoothY(j)];
    end
end

for(i=1:length(rawTracks))
    numFr = rawTracks(i).NumFrames;
    for(j=1:numFr)
        rawTracks(i).Path(j,1:2) = [rawTracks(i).SmoothX(j) rawTracks(i).SmoothY(j)];
    end
end
 
 %%%%   Find Collisions 

 for (i = 1:(length(rawTracks)))
     totalTracks = length(rawTracks);
     frameInQuestion = rawTracks(i).Frames(end);
     placeInQuestion = rawTracks(i).Path(end,:);
     CoordAtPotentialCollision = rawTracks(i).Path(end,:);
     numToCheck = 0;
     if(frameInQuestion>40)
         rampIndex = 1;
         startIn = frameInQuestion-39;
         stopIn = frameInQuestion-20;
         for(j=1:(length(rawTracks)))
             if(rawTracks(j).Frames(1)<startIn)
                 if(rawTracks(j).Frames(end)>stopIn)
                     startPlace = find(rawTracks(j).Frames==startIn);
                     CheckPos(rampIndex:(rampIndex+19),1:2) = rawTracks(j).Path(startPlace:(startPlace+19),:);
                     rampIndex = rampIndex +20;
                     numToCheck = numToCheck +1;

                 end
             end
         end
   
         numClose = 0;
         
         for (k=1:numToCheck)
             position = 1;
             startHere = ((k-1)*20)+1;
             stopHere = ((k-1)*20)+20;

             for(l=startHere:stopHere)
                 diffHere = (CheckPos(l,1) -  CoordAtPotentialCollision(1,1) )^2 + ...
                                        (CheckPos(l,2) -  CoordAtPotentialCollision(1,2) )^2 ;
                 
                 if (diffHere < ((Prefs.MaxInterFrameDistance*5)^2))
                     position = position+1;
                 end
             end
             if(position>1)
                 numClose = numClose + 1;

             end
         end
         if(numClose>1)
                     mov = aviread_to_gray(sprintf('%s%s.avi', PathName, FilePrefix_ForTrack),frameInQuestion);
                     clf;
                     I = imcrop (mov.cdata,[placeInQuestion(1)-200 placeInQuestion(2)-200 400 400]);
                     %imshow(mov.cdata);
                     imshow(I);
                     hold on;
                     %plot(placeInQuestion(1),placeInQuestion(2),'+');
                     plot(200,200,'+');
                     display(i);
                     display(totalTracks);
                     collision(i) = input ('Is there a collision (0=NO; 1=YES)?');
         else
             collision(i) = 0;
         end
         
             end
             
     
 end

%collision = [1 0 0 0 0 0 0 0 0 1 0 0 1 1 0 0 0 1 1 0 0 0 0 0] ;
collisionIndex = find(collision == 1); %%% Index applies to rawTracks files
numCollisions = length(collisionIndex);
mindist = (Prefs.MaxInterFrameDistance * 10);

for (i = 1:numCollisions)
    CollFrames(i) = rawTracks(collisionIndex(i)).Frames(end);
    CollCoords(i,:) = rawTracks(collisionIndex(i)).Path(end,:);
end


for (i = 1:numCollisions)
    colliderTrack1_replace = [];
    colliderTrack2_replace = [];
    colliderTrack1_leftover = [];
    colliderTrack2_leftover = [];
    possibleColliders = [];
    colliderIndex = 1;
    FrameOfCollision = rawTracks(collisionIndex(i)).Frames(end);

    CoordAtCollision = rawTracks(collisionIndex(i)).Path(end,:);
    
    %%%Now look through Tracks files for the two colliding worms
    numTracks = length(Tracks);
    closeFrames = [];
    closeDists = [];
    if (i>1)
        FrameDiff = (CollFrames(1:(i-1))) - FrameOfCollision;
        FrameDiff = abs(FrameDiff);
        closeFrames = find(FrameDiff<100);
        for(k=1:(i-1))
            %%%get dist diff between past frames and current
            distDiff(k) = (CollCoords(k,1) -  CoordAtCollision(1,1) )^2 + ...
                                        ( CollCoords(k,2) -  CoordAtCollision(1,2) )^2 ;
        end
        distDiff = sqrt(distDiff);
        closeDists = find(distDiff<50);
    end
    stopper = 0;
    if ((length(closeFrames)>0) && (length(closeDists)>0))
        stopper = 1;
    end
    if (stopper ==0)
    
    for (j = 1:numTracks)
        
        FrameVect = Tracks(j).Frames;
        if (find(FrameVect==FrameOfCollision)>0)  %%% If the collision frame is even in the Track
            IndexForCollision = find(FrameVect==FrameOfCollision);
            
            TrackCoordAtCollision = Tracks(j).Path(IndexForCollision,:);
            dist =  (TrackCoordAtCollision(1,1) -  CoordAtCollision(1,1) )^2 + ...
                                        ( TrackCoordAtCollision(1,2) -  CoordAtCollision(1,2) )^2 ;
            dist = sqrt(dist);
            
            if(dist < (Prefs.MaxInterFrameDistance * 5))
                possibleColliders(:,colliderIndex) = [j dist]; %%%% j is index of which Track was flagged as having the collision
                colliderIndex = colliderIndex +1;

            end
        end
    end
    if((length(possibleColliders))>1)
        Row = possibleColliders(2,:);

        FirstIn1 = min(Row);
        FirstIn2 = find(Row==FirstIn1);

        Row(FirstIn2) = 1000000;
        SecondIn1 = min(Row);
        SecondIn2 = find(Row==SecondIn1);
       
        colliderTrack1 = possibleColliders(1,FirstIn2); %%% corresponds to the Tracks of interest
        colliderTrack2 = possibleColliders(1,SecondIn2); %%% corresponds to the Tracks of interest
        
        CollisionIndex_colliderTrack1 = find(Tracks(colliderTrack1).Frames==FrameOfCollision);
        CollisionIndex_colliderTrack2 = find(Tracks(colliderTrack2).Frames==FrameOfCollision);
        
        FrameVect1 = Tracks(colliderTrack1).Frames;
        if (0 < ((CollisionIndex_colliderTrack1)-50))
            stopPlace = (CollisionIndex_colliderTrack1 - 50);
            
            colliderTrack1_replace = extract_track_segment(Tracks(colliderTrack1),1,stopPlace);
        else
           if (CollisionIndex_colliderTrack1>1)
            stopPlace = (CollisionIndex_colliderTrack1 - 1);
            colliderTrack1_replace = extract_track_segment(Tracks(colliderTrack1),1,stopPlace);
           else
            colliderTrack1_replace = extract_track_segment(Tracks(colliderTrack1),1,1);
           end
        end
        FrameVect2 = Tracks(colliderTrack2).Frames;
        if (0 < ((CollisionIndex_colliderTrack2)-50))
            
            colliderTrack2_replace = extract_track_segment(Tracks(colliderTrack2),1,(CollisionIndex_colliderTrack2 - 50));
        else 
            if (CollisionIndex_colliderTrack2>1)
             stopPlace = (CollisionIndex_colliderTrack2 - 1);
             colliderTrack2_replace = extract_track_segment(Tracks(colliderTrack2),1,stopPlace);
            else
                colliderTrack2_replace = extract_track_segment(Tracks(colliderTrack2),1,1);
            end
        end
        %%%Collect second halves of Tracks
        FrameVect1 = Tracks(colliderTrack1).Frames;
        if ((length(FrameVect1)) > (CollisionIndex_colliderTrack1 + 901))
            colliderTrack1_leftover = extract_track_segment(Tracks(colliderTrack1),(CollisionIndex_colliderTrack1 + 900),(length(FrameVect1)));
        end
        FrameVect2 = Tracks(colliderTrack2).Frames;
        if ((length(FrameVect2)) > (CollisionIndex_colliderTrack2 + 901))
            colliderTrack2_leftover = extract_track_segment(Tracks(colliderTrack2),(CollisionIndex_colliderTrack2 + 900),(length(FrameVect2)));
        end
         if(length(colliderTrack1_replace)>0)
        Tracks(colliderTrack1) = colliderTrack1_replace;
         end
         if(length(colliderTrack2_replace)>0)
        Tracks(colliderTrack2) = colliderTrack2_replace;
         end
        if(length(colliderTrack1_leftover)>0)

            Tracks((length(Tracks))+1) = colliderTrack1_leftover;
        end
        if(colliderIndex>2)
        if(length(colliderTrack2_leftover)>0)

            Tracks((length(Tracks))+1) = colliderTrack2_leftover;
        end
        end
    end
        end
    
    
end

% Throw out short Tracks [be a little more generous?]

numTracksAfterColl = length(Tracks);
for(i=1:numTracksAfterColl)
    tracks_length(i) = Tracks(i).NumFrames;
end
index_less_than_5min = find(tracks_length<900);
Tracks(index_less_than_5min) = [];

% Decide on Speed StepSize (1?)

% Rename resulting linkedTracks file finalTracks and save

finalTracks = Tracks;

for t = 1:length(finalTracks)
    if t >= 10
        b = '00';
    elseif t >= 100
        b = '0';
    elseif t >= 1000
        b = '';
    else
        b = '000';
    end
    finalTracks(t).ID = sprintf('%s_worm%s%i', FilePrefix_ForTrack, b, t);
end
  
  
  
  FileName = sprintf('%s.finalTracks.mat',FilePrefix_ForTrack);
  dummystring = sprintf('%s%s',PathName,FileName);
  save_Tracks(dummystring, finalTracks);
  disp([sprintf('%s saved %s\n', dummystring, timeString())])

% Check Compatibility with HMM analyses

% Write an extra wrapper that does TrackerAutomated and then my finalizing

end
