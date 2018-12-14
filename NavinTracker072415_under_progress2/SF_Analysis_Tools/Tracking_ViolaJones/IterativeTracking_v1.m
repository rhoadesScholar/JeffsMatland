startFrame=1;
for(i=350:1000)
frameNum = i;
bboxes = step(detector, rescaleImage(output_1(:,:,frameNum)))


imshow(output_1(:,:,frameNum),[0,500]); 
for(j=1:length(bboxes(:,1)))
    hold on; rectangle('Position', bboxes(j,:),'edgecolor','r'); hold on; text(bboxes(j,1),bboxes(j,2),num2str(j));

end

%hold on;rectangle('Position', bboxes(2,:),'edgecolor','r'); hold on;rectangle('Position', bboxes(3,:),'edgecolor','r'); hold on;rectangle('Position', bboxes(4,:),'edgecolor','r');


interpSizes = [33 37];
neuron_positions = []
for(k=1:length(bboxes(:,1)))

    exNeuron = imcrop(output_1(:,:,frameNum),[(bboxes(k,1)+1) (bboxes(k,2)+1) 6 6]);
    exNeuron2 = [];
    exNeuron2 = interp2(double(exNeuron),2); %%% 33x33 if neuron was 8, 37x37 if neuron was 9
    %out_pk=pkfnd(exNeuron2,100,7);
    [a b] = max(exNeuron2);
    [c d] = max(a);
    max_pos = [d b(d)];
    %backcalculate position
    neuronBoxSize = bboxes(k,3);
    interpSizeHere = interpSizes(neuronBoxSize-7);
    Pos1 = round(max_pos(1)*neuronBoxSize/interpSizeHere)+1;
    Pos2 = round(max_pos(2)*neuronBoxSize/interpSizeHere)+1;
    Pos1_Orig = Pos1+bboxes(k,1);
    Pos2_Orig = Pos2+bboxes(k,2);
    neuron_positions(k,1) = Pos1_Orig;
    neuron_positions(k,2) = Pos2_Orig;
    % ([Pos1 Pos2])
    %imshow(exNeuron,[0 500]); hold on; plot(Pos1,Pos2,'+');
    %pause;
    %figure(2);imshow(output_1(:,:,frameNum),[0,500]); hold on; plot((Pos1+bboxes(k,1)),(Pos2+bboxes(k,2)),'+')
end

numCells = 4;
correctCells = [];
OrderHere = [];

if(startFrame==1)
    OrderHere = 1:4;
    startFrame=0;
    for(l=1:numCells)
     correctCells(l) = input ('What # is actually a cell?');
    end
    
    CorrectPositions = neuron_positions(correctCells,:);
    
    AllCorrectDistances = sort(pdist(CorrectPositions));
    
    InterCellDistances = squareform(AllCorrectDistances);
else
    
    numObjectsFound = length(bboxes(:,1));
    if((numObjectsFound-numCells)>0)
        %then you have too many objects, so subsample
        PossibleCells = 1:numObjectsFound;
        Iterations = nchoosek(PossibleCells,numCells);
        SumDistanceDiff = [];
        for(l=1:length(Iterations(:,1)))
            CorrectPositions_test = neuron_positions(Iterations(l,:),:);
            AllTestedDiffs = sort(pdist(CorrectPositions_test));
            DiffAcrossCellsHere = abs(AllTestedDiffs-AllCorrectDistances);
            SumDistanceDiff(l) = sum(DiffAcrossCellsHere);
        end
        [a b] = min(SumDistanceDiff);
        correctIter = b;
        display(SumDistanceDiff) % NOTE: THIS SHOULD BE FIXED - COULD BE MULTIPLE SOLUTIONS
        if(a<13)
            %then there is one good solution
            correctCells=Iterations(correctIter,:);
            CorrectPositions = neuron_positions(correctCells,:);
            AllCorrectDistances = sort(pdist(CorrectPositions));
            InterCellDistances_here = squareform(AllCorrectDistances);
            %Sort Old InterCellDistances
            for(s=1:numCells)
                InterCellDistances_Prev(s,:) = sort(InterCellDistances(s,:));
            end
            %Sort New InterCellDistances
            for(s=1:numCells)
                InterCellDistances_Now(s,:) = sort(InterCellDistances_here(s,:));
            end
             

                
                testPerms = perms([1 2 3 4]);
                
                for(t=1:length(testPerms(:,1)))
                    for(s=1:length(InterCellDistances_Now(:,1)))
                        ClosenessMatrix(s,:) = abs(InterCellDistances_Now(testPerms(t,s),:)- InterCellDistances_Prev(s,:));
                    end
                    testCloseness(t) = sum(sum(ClosenessMatrix,2));
                end
                [a b] = min(testCloseness);
                bestPerm = testPerms(b,:);   
                display(bestPerm)
            for(m=1:numCells)
                InterCellDistances_new(m,1:numCells) = InterCellDistances_here(bestPerm(m),1:numCells);
                OrderHere(m) = bestPerm(m);
            end
            display(OrderHere)
            display(InterCellDistances_new)
            %allCellsUnique = length(unique(InterCellDistances_new(:,1)));

            %if(allCellsUnique<4)
                display(InterCellDistances_Prev)
                display(InterCellDistances_Now)

                display(InterCellDistances_new)
            %end
            display('extra');
            
            InterCellDistances = InterCellDistances_new;
        end
    else % you got exactly four cells, just update info
        
        correctCells = 1:numCells;
        
        CorrectPositions = neuron_positions(correctCells,:);
    
        AllCorrectDistances = sort(pdist(CorrectPositions));
        
        InterCellDistances_here = squareform(AllCorrectDistances);
            %Sort Old InterCellDistances
            for(s=1:numCells)
                InterCellDistances_Prev(s,:) = sort(InterCellDistances(s,:));
            end
            %Sort New InterCellDistances
            for(s=1:numCells)
                InterCellDistances_Now(s,:) = sort(InterCellDistances_here(s,:));
            end
             
         

                
                testPerms = perms([1 2 3 4]);
                
                for(t=1:length(testPerms(:,1)))
                    for(s=1:length(InterCellDistances_Now(:,1)))
                        ClosenessMatrix(s,:) = abs(InterCellDistances_Now(testPerms(t,s),:)- InterCellDistances_Prev(s,:));
                    end
                    testCloseness(t) = sum(sum(ClosenessMatrix,2));
                end
                [a b] = min(testCloseness);
                bestPerm = testPerms(b,:);   
            for(m=1:numCells)
                InterCellDistances_new(m,1:numCells) = InterCellDistances_here(bestPerm(m),1:numCells);
                OrderHere(m) = bestPerm(m);
            end
        display(InterCellDistances_new)
        display('all4')
        InterCellDistances = InterCellDistances_new;
        
    end
        
    
        
    
end

        imshow(output_1(:,:,frameNum),[0,500]); 
        test = 3/correctCells(1); % just a catch
        colorsHere = {'r' 'b' 'k' 'm'};
        for(j=1:4)
            hold on; rectangle('Position', bboxes(correctCells(OrderHere(j)),:),'edgecolor','r');

        end
        pause(0.05);



bboxes_previous = bboxes;
OrderHere_prev = OrderHere;
end




