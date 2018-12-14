function [bBox_data framesToFixLater detector BBoxRules AllMediansHere] = IterativeTracking(output_1,numCells,closenessCutoff)


%detector = vision.CascadeObjectDetector('cellFinder_1.xml','MinSize',[8 8],'MaxSize',[9 9],'MergeThreshold',2,'ScaleFactor',1.01);
detector = vision.CascadeObjectDetector('cellFinder_2.xml','MinSize',[8 8],'MaxSize',[9 9],'MergeThreshold',2,'ScaleFactor',1.01); %updated with pos/neg images from ser4

startFrame=1;

%closenessCutoff = 16; %20-30 for AVB/AIY/etc %16 for ser4

TooFewCells = [];
framesToFixLater = [];

IterationLog = NaN(1000,40);
ItLogIndex=1;

TestClosenessLog = NaN(5000,100);
TestClInd = 1;

IterationHigh=0;

TestClosenessFlag=0;

AllMediansHere = NaN(10000,numCells);

bBox_data = NaN(10000,(4*numCells));


for(i=1:length(output_1(1,1,:)))
display(i)
frameNum = i;

if(output_1(20,20,frameNum)==0)
    ItLogIndex =ItLogIndex+1;
    TestClInd = TestClInd+1;
else

numTracked_soFar = length(find(~isnan(bBox_data(:,1))));
if(numTracked_soFar==5)
    BBoxRules = setBBoxRules(bBox_data, numCells);
end
skipFrame=0;


bboxes = step(detector, rescaleImage(output_1(:,:,frameNum)));
subplot(1,3,1)
clf;
imshow(output_1(:,:,frameNum),[0,500],'InitialMagnification', 400); 
for(j=1:length(bboxes(:,1)))
    hold on; rectangle('Position', bboxes(j,:),'edgecolor','r'); hold on; text(bboxes(j,1),bboxes(j,2),num2str(j));

end
if(length(bboxes(:,1))>=numCells) % then there are enough object to account for all cells
%hold on;rectangle('Position', bboxes(2,:),'edgecolor','r'); hold on;rectangle('Position', bboxes(3,:),'edgecolor','r'); hold on;rectangle('Position', bboxes(4,:),'edgecolor','r');

%interpSizes = [33 37];
neuron_positions = [];
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
    interpSizeHere = 25;
    Pos1 = round(max_pos(1)*neuronBoxSize/interpSizeHere)+1;
    Pos2 = round(max_pos(2)*neuronBoxSize/interpSizeHere)+1;
    Pos1_Orig = Pos1+bboxes(k,1)-1;
    Pos2_Orig = Pos2+bboxes(k,2)-1;
    neuron_positions(k,1) = Pos1_Orig;
    neuron_positions(k,2) = Pos2_Orig;
    % ([Pos1 Pos2])

    %imshow(exNeuron,[0 500]); hold on; plot(Pos1,Pos2,'+');
    
    %figure(2);imshow(output_1(:,:,frameNum),[0,500]); hold on; plot(Pos1_Orig,Pos2_Orig,'+')
    %pause;
end

correctCells = [];
OrderHere = [];


if(startFrame==1)
    OrderHere = 1:numCells;
    startFrame=0;
    for(l=1:numCells)
     correctCells(l) = input ('What # is actually a cell?');
    end
    
    CorrectPositions = neuron_positions(correctCells,:);
    
    AllCorrectDistances = (pdist(CorrectPositions));
    
    InterCellDistances = squareform(AllCorrectDistances);
    AllCorrectDistances = sort(AllCorrectDistances);
else
    
    numObjectsFound = length(bboxes(:,1));
    if((numObjectsFound-numCells)>0)
        %display('extra')
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
        [ord_Sum ind_Sum] = sort(SumDistanceDiff);
    
        IterationLog(ItLogIndex,1:length(SumDistanceDiff)) = sort(SumDistanceDiff);
        ItLogIndex = ItLogIndex+1;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        IterAttemptIndex=1;
        TestClosenessFlag=0;
        bestTestClose = 1000;
        
        while(TestClosenessFlag==0)
            %%%%Try the best iteration
            correctIter = ind_Sum(IterAttemptIndex);
            IterAttemptIndex=IterAttemptIndex+1;
            
            correctCells_temp=Iterations(correctIter,:);
            CorrectPositions_temp = neuron_positions(correctCells_temp,:);
            AllCorrectDistances_temp = (pdist(CorrectPositions_temp));
            InterCellDistances_here_temp = squareform(AllCorrectDistances_temp);
            AllCorrectDistances_temp = sort(AllCorrectDistances_temp);
            %Sort Old InterCellDistances
            for(s=1:numCells)
                InterCellDistances_Prev_temp(s,:) = sort(InterCellDistances(s,:));
            end
            %Sort New InterCellDistances
            for(s=1:numCells)
                InterCellDistances_Now_temp(s,:) = sort(InterCellDistances_here_temp(s,:));
            end
            
            
            %%%%%%%%With this current best iteration, try each permutation
            testPerms = perms([1:numCells]);
                
            for(t=1:length(testPerms(:,1)))
                for(s=1:numCells)
                    ClosenessMatrix_temp(s,:) = abs(InterCellDistances_Now_temp(testPerms(t,s),:)- InterCellDistances_Prev_temp(s,:));
                end
                testCloseness_temp(t) = sum(sum(ClosenessMatrix_temp,2)); % testCloseness has length = to testPerms
            end
            [closeness_sorted closeness_ind] = sort(testCloseness_temp);

            bestPerm = testPerms(closeness_ind(1),:);   
            
            TestClosenessLog(TestClInd,1:length(testCloseness_temp)) = sort(testCloseness_temp);
            TestClInd=TestClInd+1;
            
            %display(bestPerm)
            for(m=1:numCells)
                InterCellDistances_new_temp(m,1:numCells) = InterCellDistances_here_temp(bestPerm(m),1:numCells);
                OrderHere_temp(m) = bestPerm(m);
            end
            %display('extra');

            bestClose = closeness_sorted(1);
            if(bestClose<closenessCutoff)
               %%test rules quickly
               if(numTracked_soFar>5)
               for(l=1:numCells)
                   bBoxDataRow((l*4-(4-1)):(l*4)) = bboxes(correctCells_temp(OrderHere_temp(l)),:);
               end
               display(BBoxRules)
               RulesOutcome = testBBoxRules(bBoxDataRow, BBoxRules);
               
               display(RulesOutcome)
               if(RulesOutcome==1)
                   %then check if cellular fluorescence changed
                   %dramatically, i.e. if there's still a mistake
                   mediansHere = getQuants_multiCell(rescaleImage(output_1(:,:,frameNum)),bboxes,correctCells_temp(OrderHere_temp));
                   recentMedians = AllMediansHere(frameNum-1,:);
                   if(isnan(recentMedians))
                       recentMedians = AllMediansHere(frameNum-2,:);
                   end
                   medianDiffHere = sum(abs(mediansHere-recentMedians));
                   display(medianDiffHere)
                   if(medianDiffHere>0.4)
                       display('fluor changed dramatically')
                       RulesOutcome=0;
                   end
               end
               %pause;
               if(RulesOutcome==0)
                   %then check if there is another good option
                   rulesIndex = 1;
                   checkClose = closeness_sorted(rulesIndex);
                   while(checkClose<closenessCutoff && RulesOutcome==0 && rulesIndex<=(length(closeness_ind)))
                       bestPerm = testPerms(closeness_ind(rulesIndex),:); 
                       for(m=1:numCells)
                            InterCellDistances_new_temp(m,1:numCells) = InterCellDistances_here_temp(bestPerm(m),1:numCells);
                            OrderHere_temp(m) = bestPerm(m);
                       end
                       for(l=1:numCells)
                            bBoxDataRow((l*4-(4-1)):(l*4)) = bboxes(correctCells_temp(OrderHere_temp(l)),:);
                       end
                       RulesOutcome = testBBoxRules(bBoxDataRow, BBoxRules);
                       if(RulesOutcome==1)
                           %then check if cellular fluorescence changed
                           %dramatically, i.e. if there's still a mistake
                           mediansHere = getQuants_multiCell(rescaleImage(output_1(:,:,frameNum)),bboxes,correctCells_temp(OrderHere_temp));
                           recentMedians = AllMediansHere(frameNum-1,:);
                           if(isnan(recentMedians))
                               recentMedians = AllMediansHere(frameNum-2,:);
                           end
                           medianDiffHere = sum(abs(mediansHere-recentMedians));
                           display(medianDiffHere)
                           if(medianDiffHere>0.4)
                               display('fluor changed dramatically')
                               RulesOutcome=0;
                           end
                       end
                       display('tried a second time when rules were incorrect')
                       display(RulesOutcome)
                       rulesIndex=rulesIndex+1;
                       if(rulesIndex<=(length(closeness_ind)))
                       checkClose = closeness_sorted(rulesIndex);
                       end
                   end
               end
               if(RulesOutcome==0)
                   if((IterAttemptIndex-1)==(length(ind_Sum)))
                   %then there is a goof - show the cells and have user
                   %input correct bboxes
                   OrderHere=1:numCells;
                   for(l=1:numCells)
                        correctCells(l) = input ('What # is actually a cell? Enter in same order as beginning');
                   end
                   if(sum(correctCells)==0)
                       skipFrame=1;
                       TooFewCells = [TooFewCells i];
                       TestClosenessFlag=1;
                   else
                   CorrectPositions = neuron_positions(correctCells,:);
    
                   AllCorrectDistances = (pdist(CorrectPositions));
    
                   InterCellDistances = squareform(AllCorrectDistances);
                   AllCorrectDistances = sort(AllCorrectDistances);
                   TestClosenessFlag=1;
                   %re-test rules and update
                   for(l=1:numCells)
                        bBoxDataRow((l*4-(4-1)):(l*4)) = bboxes(correctCells(OrderHere(l)),:);
                   end

                   BBoxRules = ReTestBBoxRules(bBoxDataRow, BBoxRules);
                   end
                   end
               else
               display(bestClose)
               %pause;
               bestTestClose=a;
               BestTestCloseIndex=b;
               correctCells=correctCells_temp;
                CorrectPositions = CorrectPositions_temp;
                AllCorrectDistances = AllCorrectDistances_temp;
                InterCellDistances_here = InterCellDistances_here_temp;
                AllCorrectDistances = AllCorrectDistances_temp;
                InterCellDistances_new = InterCellDistances_new_temp;
                OrderHere = OrderHere_temp;
                InterCellDistances = InterCellDistances_new;
                TestClosenessFlag=1;
               end
               else % you are within first 5 frames, but ok to go ahead
                correctCells=correctCells_temp;
                CorrectPositions = CorrectPositions_temp;
                AllCorrectDistances = AllCorrectDistances_temp;
                InterCellDistances_here = InterCellDistances_here_temp;
                AllCorrectDistances = AllCorrectDistances_temp;
                InterCellDistances_new = InterCellDistances_new_temp;
                OrderHere = OrderHere_temp;
                InterCellDistances = InterCellDistances_new;
                TestClosenessFlag=1;
               end
            else
                display(bestClose)
            if ((IterAttemptIndex-1)==(length(ind_Sum)))
               OrderHere=1:numCells;
               for(l=1:numCells)
                    correctCells(l) = input ('What # is actually a cell? Enter in same order as beginning');
               end
               if(sum(correctCells)==0)
                   skipFrame=1;
                   TooFewCells = [TooFewCells i];
                   TestClosenessFlag=1;
               else
               CorrectPositions = neuron_positions(correctCells,:);

               AllCorrectDistances = (pdist(CorrectPositions));

               InterCellDistances = squareform(AllCorrectDistances);
               AllCorrectDistances = sort(AllCorrectDistances);
               TestClosenessFlag=1;
               %re-test rules and update
               for(l=1:numCells)
                    bBoxDataRow((l*4-(4-1)):(l*4)) = bboxes(correctCells(OrderHere(l)),:);
               end
               if(numTracked_soFar>10)
               BBoxRules = ReTestBBoxRules(bBoxDataRow, BBoxRules);
               end
%             display('skipping')
%             pause
%             skipFrame=1;
%             framesToFixLater = [framesToFixLater i];
%             TestClosenessFlag=1;
               end
            end

            end
%             else
%                 if(a<30)
%                bestTestClose=a;
%                BestTestCloseIndex=b;
%                correctCells=correctCells_temp;
%                 CorrectPositions = CorrectPositions_temp;
%                 AllCorrectDistances = AllCorrectDistances_temp;
%                 InterCellDistances_here = InterCellDistances_here_temp;
%                 AllCorrectDistances = AllCorrectDistances_temp;
%                 InterCellDistances_new = InterCellDistances_new_temp;
%                 OrderHere = OrderHere_temp;
%                 InterCellDistances = InterCellDistances_new;
%                 TestClosenessFlag=1;
%                
%             else
%             
%             skipFrame=1;
%             framesToFixLater = [framesToFixLater i];
%             TestClosenessFlag=1;
%                 end
%             
%             end
        end
        
    else % you got exactly four cells, just update info
        
        correctCells_temp = 1:numCells;
        
        CorrectPositions_temp = neuron_positions(correctCells_temp,:);
    
        AllCorrectDistances_temp = (pdist(CorrectPositions_temp));
        
        InterCellDistances_here_temp = squareform(AllCorrectDistances_temp);
        AllCorrectDistances_temp = sort(AllCorrectDistances_temp);
            display(InterCellDistances)
            %Sort Old InterCellDistances
            for(s=1:numCells)
                InterCellDistances_Prev(s,:) = sort(InterCellDistances(s,:));
            end
            %Sort New InterCellDistances
            for(s=1:numCells)
                InterCellDistances_Now(s,:) = sort(InterCellDistances_here_temp(s,:));
            end
             
            testPerms = perms([1:numCells]);
                
            for(t=1:length(testPerms(:,1)))
                for(s=1:length(InterCellDistances_Now(:,1)))
                   ClosenessMatrix(s,:) = abs(InterCellDistances_Now(testPerms(t,s),:)- InterCellDistances_Prev(s,:));
                end
                testCloseness(t) = sum(sum(ClosenessMatrix,2));
            end
            [a b] = min(testCloseness);
            bestPerm = testPerms(b,:); 
            
            TestClosenessLog(TestClInd,1:length(testCloseness)) = sort(testCloseness);
            TestClInd=TestClInd+1;
            
            for(m=1:numCells)
                InterCellDistances_new_temp(m,1:numCells) = InterCellDistances_here_temp(bestPerm(m),1:numCells);
                OrderHere_temp(m) = bestPerm(m);
            end
            
            if(a<closenessCutoff)
               bestTestClose=a;
               BestTestCloseIndex=b;
               correctCells=correctCells_temp;
                CorrectPositions = CorrectPositions_temp;
                AllCorrectDistances = AllCorrectDistances_temp;
                InterCellDistances_here = InterCellDistances_here_temp;
                InterCellDistances_new = InterCellDistances_new_temp;
                OrderHere = OrderHere_temp;
                InterCellDistances = InterCellDistances_new;
            else
            
            skipFrame=1;
            framesToFixLater = [framesToFixLater i];
            end
        %display('all4')
        %InterCellDistances = InterCellDistances_new;
    end
        
    
        
    
end


%%%%%%%%%   Displaying Output
if(skipFrame==0)
displayNow=0;
if(displayNow==1)

        
        display(InterCellDistances);
        if(ItLogIndex~=1)
        display(IterationLog(ItLogIndex-1,1:5));
        end
        if(TestClInd~=1)
        display(TestClosenessLog(TestClInd-1,1:5));
        end
        display(correctCells)
        display(OrderHere)
        
end
        colorsHere = {'r' 'b' 'k' 'm'};
        subplot(1,3,2)
        %clf
        imshow(output_1(:,:,frameNum),[0,500]); 
        for(j=1:numCells)

            hold on; rectangle('Position', bboxes(correctCells(OrderHere(j)),:),'edgecolor',colorsHere{j});
            
            columnsToUse = ((j*4)-3):(j*4);
            bBox_data(frameNum,columnsToUse) = bboxes(correctCells(OrderHere(j)),:);
            
            
        end
        
        display(i)
        %pause()

bboxes_previous = bboxes;
OrderHere_prev = OrderHere;
mediansHere = getQuants_multiCell(rescaleImage(output_1(:,:,frameNum)),bboxes,correctCells(OrderHere));
AllMediansHere(frameNum,:) = mediansHere;
end
else %didn't get every cell - note this and update training algorithm
    TooFewCells = [TooFewCells i];
end
end
end







end