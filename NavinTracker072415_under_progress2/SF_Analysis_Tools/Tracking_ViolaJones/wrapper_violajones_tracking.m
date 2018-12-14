
function [outputData storedRotatedImages outputData_cellPosInfo] = wrapper_violajones_tracking(frameStart)

%%%%%%INITIAL VARIABLES
%% 
%detector = vision.CascadeObjectDetector('neuronDetector_ser4_spec.xml','MinSize',[32 35],'MaxSize',[40 44],'MergeThreshold',12,'ScaleFactor',1.02);; % for ser-4
%detector = vision.CascadeObjectDetector('neuronDetector_ser4_spec_inclRot.xml','MinSize',[32 35],'MaxSize',[33 36],'MergeThreshold',12,'ScaleFactor',1.01);% for ser-4
%detector = vision.CascadeObjectDetector('neuronDetector_ser4_spec_inclRot2.xml','MinSize',[32 35],'MaxSize',[33 36],'MergeThreshold',12,'ScaleFactor',1.01);% for ser-4
%detector = vision.CascadeObjectDetector('neuronDetector_ser4_spec_inclRot3.xml','MinSize',[32 35],'MaxSize',[34 37],'MergeThreshold',8,'ScaleFactor',1.005);% for ser-4
detector = vision.CascadeObjectDetector('ser4_101414.xml','MinSize',[40 35],'MaxSize',[42 37],'MergeThreshold',14,'ScaleFactor',1.01); %10/14/14
%detector = vision.CascadeObjectDetector('neuronDetector3.xml','MinSize',[37 32],'MaxSize',[46 55],'MergeThreshold',12,'ScaleFactor',1.01) % for AIY/AIA/AVB/RIA

surrAreaToRead = 100;
minPixelsMoved = 30;
outputData = zeros([[70 70] 3000],'uint16');
outputData_cellPosInfo(1:20000,1:8) = NaN; %col1 = rotAngle; col2=size of rotMatrix; col3 = top left of bBox in rot image(X) col4=topleft of bBox in rot Image(Y) col5-6 = topleft bBox in orig
consFailFrame=0;
changingFastFlag = 0;

quantsPrev = [0 0 0 0 0];
quantsPrevFull = [0 0 0 0 0 0 0 0 0 0];
rotAnglePrev = 0;
counter=0;
FourthImageFlag = 0;
AllQuantsPrev = [];
AllQuantsPrevFull = [];
AllChangesQuantFull = [];

storedRotatedImages = struct('images',[]);
%% 



%Initialize on the first image

firstImageFlag=1;
[fn pn]=uigetfile('*.tif','select first file in movie');
movieFile=[pn fn];


% go through a loop opening up one image at a time

D=dir([pn,'*.tif']);
framesToSkip=[];

for (i=frameStart:length(D))
    testHere = intersect(i,framesToSkip);
    if(length(testHere)==0)
    if(firstImageFlag==1)
        display('back at begin')
        [Pos_In_Rot_Image fn pn rotAngle orig_X_pos orig_Y_pos] = InitializeGroupTracker(pn,D,i);
    end
    clearvars newRotAngle

    SkipFrameLog = 0;
    [bboxes temp_Mov] = getCandidateBBoxes(orig_X_pos,orig_Y_pos,rotAngle,D,i,pn,detector);
    startingRotAngle = rotAngle;
    
    %find closest "face" in bboxes
    numRowBboxes = size(bboxes,1);
    %%%%%ADJUST ROTANGLE IF YOU DON'T FIND ANYTHING AT FIRST
    %% 
    if(numRowBboxes==0)
        %then you didn't find the cells -- try some rotated images
        
        [bboxes temp_Mov] = getCandidateBBoxes(orig_X_pos,orig_Y_pos,rotAngle+8,D,i,pn,detector); %add 8
        numRowBboxes = size(bboxes,1);
        if(numRowBboxes>0)
            rotAngle = rotAngle +8;
        else
            [bboxes temp_Mov] = getCandidateBBoxes(orig_X_pos,orig_Y_pos,rotAngle-8,D,i,pn,detector); %subtract 8
            numRowBboxes = size(bboxes,1);
            if(numRowBboxes>0)
            rotAngle = rotAngle -8;
            else
                [bboxes temp_Mov] = getCandidateBBoxes(orig_X_pos,orig_Y_pos,rotAngle+16,D,i,pn,detector); %add 16
                numRowBboxes = size(bboxes,1);
                if(numRowBboxes>0)
                    rotAngle = rotAngle +16;
                else
                [bboxes temp_Mov] = getCandidateBBoxes(orig_X_pos,orig_Y_pos,rotAngle-16,D,i,pn,detector); %subtract 16
                numRowBboxes = size(bboxes,1);
                if(numRowBboxes>0)
                rotAngle = rotAngle -16;
                end
                end
            end
        end
            display('couldnt find any bboxes, but after rotation')
            %display(bboxes)
    end
    %% 
    
    [Y indexMin] = getDistanceFromLastBBox(temp_Mov,bboxes);
    
    if(numRowBboxes==0 || Y>minPixelsMoved) % if a few tries fail, then go more systematic
        newRotAngle = getCellsCloser(orig_X_pos,orig_Y_pos,rotAngle,D,i,pn,detector,minPixelsMoved);
        rotAngle = newRotAngle(1);
        display('Had to systematically look for bboxes')
        %display(rotAngle)
        [bboxes temp_Mov] = getCandidateBBoxes(orig_X_pos,orig_Y_pos,newRotAngle(1),D,i,pn,detector);
        numRowBboxes = size(bboxes,1);
        correctFirstChoice=0;
        choiceIncr = 0;
        if(firstImageFlag==1)
            while(correctFirstChoice==0)
                choiceIncr = choiceIncr+1;
                if(choiceIncr==length(newRotAngle))
                    SkipFrameLog=1;
                    correctFirstChoice=1;
                else
                rotAngle = newRotAngle(choiceIncr);
                [bboxes temp_Mov] = getCandidateBBoxes(orig_X_pos,orig_Y_pos,newRotAngle(choiceIncr),D,i,pn,detector);
                [Y indexMin] = getDistanceFromLastBBox(temp_Mov,bboxes);
                numRowBboxes = size(bboxes,1);
                if(numRowBboxes>0)
                imshow(temp_Mov,[0 500]);
                for(a=1:length(bboxes(:,1)))
                    hold on; rectangle('Position',bboxes(a,:),'edgecolor','b');
                end
                rectangle('Position',bboxes(indexMin,:),'edgecolor','r');
                correctFirstChoice= input('is this right? (1=YES; 0=NO)');
                end
                end
            end
        end
    end
    
    [Y indexMin] = getDistanceFromLastBBox(temp_Mov,bboxes);
    quantsHere = getQuants_v1(temp_Mov,bboxes,indexMin);
    quantsHereFull = getQuants_v2(temp_Mov,bboxes,indexMin);
    changeInQuantFull = sum(abs(quantsHereFull-quantsPrevFull));
    changeInQuant = abs(quantsHere-quantsPrev);
    
    centerDistr = sum(changeInQuant(2:4));
    changeInfinalQuant = changeInQuant(5);
    
    if(firstImageFlag~=1)
    if(centerDistr>.00025 || Y>minPixelsMoved || changeInQuantFull>0.0008) %0.000375
        display('didnt like first bbox')
        %display(centerDistr)
        %display(changeInQuantFull)
        %display(changeInfinalQuant)
        %display(Y)
        imshow(temp_Mov,[0 500]); %if you want to display what you are getting
        for(a=1:length(bboxes(:,1)))
            hold on; rectangle('Position',bboxes(a,:),'edgecolor','b');
        end
        rectangle('Position',bboxes(indexMin,:),'edgecolor','r');
        pause(0.3);
        %then you might have jumped to something else---check if you can
        %improve
        %display('trying other close objects')
        %pause;
        if(exist('newRotAngle')~=1)
        newRotAngle = getCellsCloser(orig_X_pos,orig_Y_pos,startingRotAngle,D,i,pn,detector,minPixelsMoved);
        end
        
        endFlag=0;
        indexDistr=1;
        bestInd=1;
        
        while(endFlag == 0)
            rotAngle = newRotAngle(indexDistr);
            [bboxes temp_Mov] = getCandidateBBoxes(orig_X_pos,orig_Y_pos,rotAngle,D,i,pn,detector);
            numRowBboxes = size(bboxes,1);
            if(numRowBboxes>0)
                [Y,indexMin] = getDistanceFromLastBBox(temp_Mov,bboxes);
                quantsHere = getQuants_v1(temp_Mov,bboxes,indexMin);
                quantsHereFull = getQuants_v2(temp_Mov,bboxes,indexMin);
                changeInQuantFull_Temp = sum(abs(quantsHereFull-quantsPrevFull));
                changeInQuant = abs(quantsHere-quantsPrev);
                centerDistr_temp = sum(changeInQuant(2:4));
                changeInfinalQuant_temp = changeInQuant(5);
                changeInRotAngle = rotAngle-startingRotAngle;

                 imshow(temp_Mov,[0 500]); %if you want to display what you are getting
                 for(a=1:length(bboxes(:,1)))
                     hold on; rectangle('Position',bboxes(a,:),'edgecolor','b');
                 end
                 rectangle('Position',bboxes(indexMin,:),'edgecolor','r');
%                 display('trying new Bboxes')
%                 display(indexDistr)
%                 display(Y);
%                 display(changeInQuant)
%                 display(changeInQuantFull)
%                 display(changeInRotAngle)
%                 pause;
                
                if(changeInQuantFull_Temp<changeInQuantFull)
                    if(Y<(minPixelsMoved+12))
                    %if(changeInfinalQuant_temp<(changeInfinalQuant+0.0001))
                    display('improved in this version')
                    %pause;
                    changeInQuantFull = changeInQuantFull_Temp;
                    centerDistr = centerDistr_temp;
                    changeInfinalQuant = changeInfinalQuant_temp;
                    bestInd = indexDistr;
                    %if(centerDistr<0.00015 && changeInQuant(5)<.00025 && changeInQuantFull<0.0003 && Y<minPixelsMoved)
                    %    display('found a satisfactory fit')
                    %    endFlag=1;
                    %end
                    %end
                    end
                end
            end
            indexDistr=indexDistr+1;
            if(indexDistr==50)
                endFlag=1;
            end

        end
        

        rotAngle = newRotAngle(bestInd);
        [bboxes temp_Mov] = getCandidateBBoxes(orig_X_pos,orig_Y_pos,rotAngle,D,i,pn,detector);
        numRowBboxes = size(bboxes,1);
        [Y,indexMin] = getDistanceFromLastBBox(temp_Mov,bboxes);
        quantsHere = getQuants_v1(temp_Mov,bboxes,indexMin);
        quantsHereFull = getQuants_v2(temp_Mov,bboxes,indexMin);
        changeInQuantFull = sum(abs(quantsHereFull-quantsPrevFull));
        changeInQuant = abs(quantsHere-quantsPrev);
        centerDistr_temp = sum(changeInQuant(2:4));
        changeInfinalQuant_temp = changeInQuant(5);
        changeInRotAngle = rotAngle-startingRotAngle;
        display(bestInd);
        display(Y);
        display(changeInQuant)
        display(changeInQuantFull)
        display(changeInRotAngle)
        imshow(temp_Mov,[0 500]); %if you want to display what you are getting
        for(a=1:length(bboxes(:,1)))
            hold on; rectangle('Position',bboxes(a,:),'edgecolor','b');
        end
        rectangle('Position',bboxes(indexMin,:),'edgecolor','g');
        %pause;
        
    end
    end
    
    %% 
    % Now you have cells; check distance
        
        [Y,indexMin] = getDistanceFromLastBBox(temp_Mov,bboxes);
        %display(Y);
        if(firstImageFlag==1)
            changeInQuantFull=0;
        end
        
        if(FourthImageFlag==1)
            lastTwoChanges = AllChangesQuantFull(end-1:end);
            AllThreeChanges = [lastTwoChanges changeInQuantFull];
            numHigh = length(find(AllThreeChanges>0.0006));
            if(numHigh>2)
                changingFastFlag=1;
                consFailFrame = 5;
            end
        end
        
        display(Y)
        display(minPixelsMoved)
        display(changeInQuantFull)
        display(changingFastFlag)

        if(Y>minPixelsMoved || changeInQuantFull>0.0011 || changingFastFlag==1)
            %then you will fail on this frame
            %display(i)
            SkipFrameLog=1;
            display('failed on this frame');
            consFailFrame = consFailFrame+1;
            %pause;
            rotAngle = startingRotAngle;
            outputData(:,:,i) = 0;
            if(consFailFrame>3)
                %then loop back with a new start
                if(changingFastFlag==1)
                    display(AllThreeChanges)
                    display('intensity changing rapidly')
                else
                display('this is a problematic patch')
                end
                consFailFrame=0;
                display(i)
                fileNumber = input ('At what frame should we resume');
                if(fileNumber==0)
                    return;
                end
                [Pos_In_Rot_Image fn pn rotAngle orig_X_pos orig_Y_pos] = InitializeGroupTracker(pn,D,fileNumber);
                framesToSkip = (i+1):(fileNumber-1);
                SkipFrameLog = 1;
                AllQuantsPrev = [];
                AllQuantsPrevFull = [];
                quantsPrev = [0 0 0 0 0];
                quantsPrevFull = [0 0 0 0 0 0 0 0 0 0];
                changingFastFlag=0;
                rotAnglePrev = 0;
                counter=0;
                FourthImageFlag = 0;
                firstImageFlag=1;
            end
        else
            consFailFrame=0;
        end
        %% 
        
        

%Backcalculate where cell was in this image and log data
if(SkipFrameLog==0)  

%if(mod(i,20)==0)  %% 
imshow(temp_Mov,[0 500]); %if you want to display what you are getting
for(a=1:length(bboxes(:,1)))
    hold on; rectangle('Position',bboxes(a,:),'edgecolor','b');
end
rectangle('Position',bboxes(indexMin,:),'edgecolor','r');
display(i)
pause(.05)
%end
I=imcrop(temp_Mov,bboxes(indexMin,:));
quantsHere = getQuants_v1(temp_Mov,bboxes,indexMin);
quantsHereFull = getQuants_v2(temp_Mov,bboxes,indexMin);
changeInQuant = abs(quantsHere-quantsPrev);
changeInQuantFull = sum(abs(quantsHereFull-quantsPrevFull));
changeInCenterDistr = sum(changeInQuant(2:4));
changeInAng = rotAngle-rotAnglePrev;
%display(changeInCenterDistr)
%display(changeInQuantFull)
%display(changeInAng)
%display(Y)
%pause;
%% 
%% 

imgPoint = [];
imgPoint = ones(size(temp_Mov));
bbox_recent_image = bboxes(indexMin,1:2);
imgPoint((round(bbox_recent_image(2))-1):(round(bbox_recent_image(2))+2), round((bbox_recent_image(1))-1):(round(bbox_recent_image(1))+2)) = 127;

imgPointRot = imrotate(imgPoint, -rotAngle);
deRotatedImage = imrotate(temp_Mov,-rotAngle);

% Remove zero rows
imgPointRot(all(~deRotatedImage,2),:) = [];
deRotatedImage(all(~deRotatedImage,2),:) = [];

% Remove zero columns
imgPointRot( :, all(~deRotatedImage,1) ) = [];
deRotatedImage( :, all(~deRotatedImage,1) ) = [];

% original position of cells
[orig_X_pos_smallWindow, orig_Y_pos_smallWindow] = find(imgPointRot==127);
if(consFailFrame==0 && changeInQuantFull<.001)
    
orig_X_pos = orig_X_pos + (orig_X_pos_smallWindow(1)-100);
orig_Y_pos = orig_Y_pos + (orig_Y_pos_smallWindow(1)-100);
end
%and log frame of data

current_bbox = bboxes(indexMin,:);
centerOfCurrentBbox_A = current_bbox(2)+(current_bbox(4)/2);
centerOfCurrentBbox_B = current_bbox(1)+(current_bbox(3)/2);
topLeft_CurrentOutput_A = round(centerOfCurrentBbox_A-35);
topLeft_CurrentOutput_B = round(centerOfCurrentBbox_B-35);

newData = imcrop(temp_Mov, [topLeft_CurrentOutput_B topLeft_CurrentOutput_A 69 69]);
outputData(:,:,i) = newData;
sizeOfRotImage = size(temp_Mov);
DistFromBBoxToOuterBox_X = current_bbox(1)-topLeft_CurrentOutput_B;
DistFromBBoxToOuterBox_Y = current_bbox(2)-topLeft_CurrentOutput_A;
outputData_cellPosInfo(i,1:8) = [rotAngle sizeOfRotImage(1) topLeft_CurrentOutput_A topLeft_CurrentOutput_A orig_X_pos orig_Y_pos DistFromBBoxToOuterBox_X DistFromBBoxToOuterBox_Y];
storedRotatedImages(i).images = temp_Mov;
%% 
if(consFailFrame==0)
rotAnglePrev = rotAngle;
if(FourthImageFlag==1)  
    lastRow = length(AllQuantsPrev(:,1));
    quantsPrevA = AllQuantsPrev((end-3):end,:);
    quantsPrev = mean(quantsPrevA);
    quantsPrevB = AllQuantsPrevFull((end-3):end,:);
    quantsPrevFull = mean(quantsPrevB);
else
    
    quantsPrev = quantsHere;
    quantsPrevFull = quantsHereFull;
    
end
if(changeInQuantFull<.001)
AllChangesQuantFull = [AllChangesQuantFull changeInQuantFull];
AllQuantsPrev = [AllQuantsPrev; quantsHere];
AllQuantsPrevFull = [AllQuantsPrevFull; quantsHereFull];
end
end
firstImageFlag=0;
end

counter=counter+1;
if(counter>7)
    FourthImageFlag=1;
end
end
end

end
    
    
    
    