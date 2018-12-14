function [finalTracks leftoverTracks] = processLinkedTracks_speedStepSize1(Tracks,rawTracks,movieName)

global Prefs;
Prefs = define_preferences(Prefs);

numRealTracks = length(Tracks);
numMergedTracks = numRealTracks;

maxFrame = max_struct_array(Tracks,'Frames');
minFrame = min_struct_array(Tracks,'Frames');
distance_cutoff_sqrd = Prefs.MaxTrackLinkDistance^2;

distance_matrix(numRealTracks,numRealTracks) = 0;
distance_matrix = distance_matrix + 1e10;

for(i=1:(numRealTracks-1))
    if(Tracks(i).Frames(1) > minFrame || Tracks(i).Frames(end) < maxFrame)
        for( j=i+1: numRealTracks)
            if(Tracks(j).Frames(1) > minFrame || Tracks(j).Frames(end) < maxFrame)
                if(strcmp(Tracks(i).Name,Tracks(j).Name)==1) % same movie
                    
                    if(~isfield(Tracks(j),'LastSize'))
                        Tracks(j).LastSize = Tracks(j).Size(end);
                        Tracks(i).LastSize = Tracks(i).Size(end);
                    end
                    
                    if((abs(Tracks(i).Frames(end)-Tracks(j).Frames(1)))<21)
                        d_frame = abs(Tracks(j).Frames(1) - Tracks(i).Frames(end));
                        if (d_frame == 0)
                            d_frame = 1;
                        end
                   
                        if(d_frame <= 20)  % track j starts within MaxTrackLinkFrames of the end of track i
                            %if(abs(Tracks(j).Size(1) - Tracks(i).LastSize) <=  Prefs.SizeChangeThreshold) % the same animal should have the same size
                                %if(abs(GetAngleDif( mean(Tracks(i).Direction(end-Prefs.FrameRate:end)), mean(Tracks(j).Direction(1:Prefs.FrameRate)) )) <= Prefs.MaxTrackLinkDirectionDiff) % only if going the same way
                                    
                                    dist =  ( Tracks(i).LastCoordinates(1,1) -  Tracks(j).Path(1,1) )^2 + ...
                                        ( Tracks(i).LastCoordinates(1,2) -  Tracks(j).Path(1,2) )^2 ;
                                    
                                    if(dist <= distance_cutoff_sqrd)
                                        if(dist <= (d_frame*Prefs.MaxInterFrameDistance/2)^2 )
                                           % if(keep_or_reject_link(Tracks(i), Tracks(j), dist))
                                                distance_matrix(i,j) = dist;
                                           % end
                                        end
                                    end
                                %end
                            %end
                        end
                    end
                end
            end
        end
    end
end

mindist = 0;

while(mindist<=distance_cutoff_sqrd)

    % find the shortest distance between the end of a track and the start of a later one
    [mindist,i,j] = minn(distance_matrix);
    i=i(1); % in case there are multiple w/ the same minimum
    j=j(1);

    if(mindist<=distance_cutoff_sqrd)
        % append track j to track i
        EndofTrackI = Tracks(j).Frames(1) - 5;
        EndofTrackI = find(Tracks(i).Frames == EndofTrackI);
        BeginningofTrackJ = Tracks(i).Frames(end) + 5;
        BeginningofTrackJ = find(Tracks(j).Frames==BeginningofTrackJ);
        EndofTrackJ = length(Tracks(j).Frames);
        Tracks(i) = extract_track_segment(Tracks(i),1,EndofTrackI);
        Tracks(j) = extract_track_segment(Tracks(j),BeginningofTrackJ,EndofTrackJ);
        Tracks(i) = append_track(Tracks(i), Tracks(j));

        %         ds = sprintf('d(%d)=%f;',p,mindist);
        %         evalin('base', ds);p=p+1;

        % effectively delete track j by giving it a high time, and decrementing numMergedTracks
        Tracks(j).Time(1) = 1e6;
        numMergedTracks = numMergedTracks - 1;

        % update the distance matrix ... set all elements for track i&j to 1e6, while
        % calculating distances between the end of new track i and everyone else k
        distance_matrix(j,:)=1e6; distance_matrix(:,j)=1e6;
        distance_matrix(i,:)=1e6; distance_matrix(:,i)=1e6;


        for( k=1: i-1)
            if(strcmp(Tracks(i).Name,Tracks(k).Name)==1) % same movie
                if(Tracks(k).Time(1) < 1e6)
                    if((abs(Tracks(i).Frames(end)-Tracks(j).Frames(1)))<21)
                        d_frame = Tracks(i).Frames(1) - Tracks(k).Frames(end);
                        if (d_frame == 0)
                            d_frame = 1;
                        end
                        if(d_frame <= Prefs.MaxTrackLinkFrames)
                            %if(abs(Tracks(k).LastSize - Tracks(i).Size(1)) <=  Prefs.SizeChangeThreshold)

                                %if(abs(GetAngleDif( mean(Tracks(k).Direction(end-Prefs.FrameRate:end)), mean(Tracks(i).Direction(1:Prefs.FrameRate)))) <= Prefs.MaxTrackLinkDirectionDiff)

                                    dist = ( Tracks(i).Path(1,1) -  Tracks(k).LastCoordinates(1,1) )^2 + ...
                                        ( Tracks(i).Path(1,2) -  Tracks(k).LastCoordinates(1,2) )^2 ;

                                    if(dist <= distance_cutoff_sqrd)
                                        if(dist <= (d_frame*Prefs.MaxInterFrameDistance/2)^2 )
                                            %if(keep_or_reject_link(Tracks(k), Tracks(i), dist))
                                                distance_matrix(k, i) = dist;
                                            %end
                                        end
                                    end

                                %end

                            %end
                        end
                    end
                end
            end
        end

        for( k=i+1: numRealTracks)
            if(strcmp(Tracks(i).Name,Tracks(k).Name)==1) % same movie
                if(Tracks(k).Time(1) < 1e6)
                    if((abs(Tracks(i).Frames(end)-Tracks(j).Frames(1)))<21)
                        d_frame = Tracks(k).Frames(1) - Tracks(i).Frames(end);
                        if (d_frame == 0)
                            d_frame = 1;
                        end
                        if(d_frame <= Prefs.MaxTrackLinkFrames)
                            %if(abs(Tracks(k).Size(1) - Tracks(i).LastSize) <=  Prefs.SizeChangeThreshold)

                               % if(abs(GetAngleDif( mean(Tracks(i).Direction(end-Prefs.FrameRate:end)), mean(Tracks(k).Direction(1:Prefs.FrameRate)))) <= Prefs.MaxTrackLinkDirectionDiff)

                                    dist = ( Tracks(i).LastCoordinates(1,1) -  Tracks(k).Path(1,1) )^2 + ...
                                        ( Tracks(i).LastCoordinates(1,2) -  Tracks(k).Path(1,2) )^2 ;

                                    if(dist <= distance_cutoff_sqrd)
                                        if(dist <= (d_frame*Prefs.MaxInterFrameDistance/2)^2 )
                                            %if(keep_or_reject_link(Tracks(i), Tracks(k), dist))
                                                distance_matrix(i,k) = dist;
                                            %end
                                        end
                                    end

                                %end
                            %end
                        end
                    end
                end
            end
        end
    end
end

Tracks = sort_tracks_by_starttime(Tracks);
Tracks = Tracks(1:numMergedTracks);

for(i=1:numMergedTracks)
    Tracks(i).numActiveFrames = num_active_frames(Tracks(i));
end

clear('distance_matrix');

%%%%   Find Collisions 

 for (i = 1:(length(rawTracks)))
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
                     display(numToCheck)
                 end
             end
         end
   
         numClose = 0;
         
         for (k=1:numToCheck)
             position = 1;
             startHere = ((k-1)*20)+1;
             stopHere = ((k-1)*20)+20;
             display(startHere)
             display(stopHere)
             for(l=startHere:stopHere)
                 diffHere = (CheckPos(l,1) -  CoordAtPotentialCollision(1,1) )^2 + ...
                                        (CheckPos(l,2) -  CoordAtPotentialCollision(1,2) )^2 ;
                 
                 if (diffHere < ((Prefs.MaxInterFrameDistance*5)^2))
                     position = position+1;
                 end
             end
             if(position>1)
                 numClose = numClose + 1;
                 display(numClose)
             end
         end
         if(numClose>1)
                     mov = aviread_to_gray(movieName,frameInQuestion);
                     imshow(mov.cdata);
                     hold on;
                     plot(placeInQuestion(1),placeInQuestion(2),'+');
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
    display(FrameOfCollision);
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
                display(possibleColliders)
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
            display('adding coll1')
            display(colliderTrack1)
            Tracks((length(Tracks))+1) = colliderTrack1_leftover;
        end
        if(colliderIndex>2)
        if(length(colliderTrack2_leftover)>0)
            display('adding coll2')
            display(colliderTrack2)
            Tracks((length(Tracks))+1) = colliderTrack2_leftover;
        end
        end
    end
        end
    
    
end
   
    
NumFramesAll = [];
for (k=1:(length(Tracks)))
    NumFramesAll(k) = Tracks(k).NumFrames;
end

LongTrackIndex = find(NumFramesAll >= 6300);
ShortTrackIndex = find(NumFramesAll < 6300);

finalTracks = Tracks(LongTrackIndex);
leftoverTracks = Tracks(ShortTrackIndex);

for (i = 1:(length(finalTracks)))
    %%%Calculate the final AngSpeed for this track at stepsize = 1sec
    Xdif = CalcDif(finalTracks(i).SmoothX, 3) * Prefs.FrameRate; % At StepSize=1sec
    Ydif = -CalcDif(finalTracks(i).SmoothY, 3) * Prefs.FrameRate; % At StepSize=1sec
    Direction = atan(Xdif./Ydif) * 360/(2*pi);
    % direction 0 = Up/North
    ZeroYdifIndexes = find(Ydif == 0);
    Ydif(ZeroYdifIndexes) = eps;     % Avoid division by zero in direction calculation

    Direction = atan(Xdif./Ydif) * 360/(2*pi);	    % In degrees, 0 = Up ("North")

    NegYdifIndexes = find(Ydif < 0);
    Index1 = find(Direction(NegYdifIndexes) <= 0);
    Index2 = find(Direction(NegYdifIndexes) > 0);
    Direction(NegYdifIndexes(Index1)) = Direction(NegYdifIndexes(Index1)) + 180;
    Direction(NegYdifIndexes(Index2)) = Direction(NegYdifIndexes(Index2)) - 180;
    finalTracks(i).AngSpeed = CalcAngleDif(Direction, 3)*Prefs.FrameRate;
    finalTracks(i).AngSpeed(1:3) = NaN;
    %%%Calculate the final Speed for this track at StepSize = 5sec
    %Xdif = CalcDif(finalTracks(i).SmoothX, 15) * Prefs.FrameRate; % At StepSize=5sec
    %Ydif = -CalcDif(finalTracks(i).SmoothY, 15) * Prefs.FrameRate; % At StepSize=5sec
    %Direction = atan(Xdif./Ydif) * 360/(2*pi);
    % direction 0 = Up/North
    %ZeroYdifIndexes = find(Ydif == 0);
    %Ydif(ZeroYdifIndexes) = eps;     % Avoid division by zero in direction calculation

    %Direction = atan(Xdif./Ydif) * 360/(2*pi);	    % In degrees, 0 = Up ("North")

    %NegYdifIndexes = find(Ydif < 0);
    %Index1 = find(Direction(NegYdifIndexes) <= 0);
    %Index2 = find(Direction(NegYdifIndexes) > 0);
    %Direction(NegYdifIndexes(Index1)) = Direction(NegYdifIndexes(Index1)) + 180;
    %Direction(NegYdifIndexes(Index2)) = Direction(NegYdifIndexes(Index2)) - 180;
    finalTracks(i).Speed = sqrt(Xdif.^2 + Ydif.^2)*Prefs.DefaultPixelSize;
    finalTracks(i).Speed(1:10) = NaN;
end

movieName = rawTracks(1).Name;
[filepath,filePrefix,extension,version] = fileparts(sprintf('%s',movieName));
dummystring = sprintf('%s.finalTracks.mat',filePrefix);
save(dummystring,'finalTracks');
dummystring2 = sprintf('%s.leftoverTracks.mat',filePrefix)
save(dummystring2,'leftoverTracks');
end
