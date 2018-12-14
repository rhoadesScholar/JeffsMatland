%detector = vision.CascadeObjectDetector('cellFinder_1.xml','MinSize',[8 8],'MaxSize',[9 9],'MergeThreshold',2,'ScaleFactor',1.01);
detector = vision.CascadeObjectDetector('cellFinder_2.xml','MinSize',[8 8],'MaxSize',[9 9],'MergeThreshold',2,'ScaleFactor',1.01);


% Go through outputData, find 4 cells, check it, then create output Images
output_neurons = zeros([[10 10] 3000],'uint8');
output_blanked = zeros([[70 70] 1000],'uint8');
index=1;
index2=1;

for(i=7710:10:8300)
    frameNum = i;
    checkZero = output_1(1,1,frameNum);
    if(checkZero==0)
    else
        bboxes = step(detector, rescaleImage(output_1(:,:,frameNum)));
        imshow(output_1(:,:,frameNum),[0,500],'InitialMagnification', 400); 
        for(j=1:length(bboxes(:,1)))
            hold on; rectangle('Position', bboxes(j,:),'edgecolor','r'); hold on; text(bboxes(j,1),bboxes(j,2),num2str(j));

        end
        for(l=1:numCells)
            correctCells(l) = input ('What # is actually a cell? Enter in same order as beginning');
        end
        for(l=1:numCells)
            bBoxDataRow((l*4-(4-1)):(l*4)) = bboxes(correctCells(l),:);
        end
        %[centers, radii] = imfindcircles(output_1(:,:,frameNum),[1 5],'Sensitivity',.999,'Method','twostage');
        %if(length(centers(:,1))==4)
            %imshow(output_1(:,:,frameNum),[0 500]); hold on; rectangle('Position', [centers(1,1)-3 centers(1,2)-3 7 7],'edgecolor','r'); hold on; rectangle('Position', [centers(2,1)-3 centers(2,2)-3 7 7],'edgecolor','r'); hold on; rectangle('Position', [centers(3,1)-3 centers(3,2)-3 7 7],'edgecolor','r'); hold on; rectangle('Position', [centers(4,1)-3 centers(4,2)-3 7 7],'edgecolor','r');
            %checkFlag = input ('Are the cells correct? (0=NO;1=YES)');
            %if(checkFlag==1)
            if(bBoxDataRow(3)==9 && bBoxDataRow(7)==9 && bBoxDataRow(11)==9)
            output_neurons(:,:,index) = rescaleImage(imcrop(output_1(:,:,frameNum),bBoxDataRow(1:4)));
            output_neurons(:,:,index+1) = rescaleImage(imcrop(output_1(:,:,frameNum),bBoxDataRow(5:8)));
            output_neurons(:,:,index+2) = rescaleImage(imcrop(output_1(:,:,frameNum),bBoxDataRow(9:12)));
            %output_neurons(:,:,index+3) = rescaleImage(imcrop(output_1(:,:,frameNum),[centers(4,1)-3 centers(4,2)-3 7 7]));
            index=index+3;
            end
            medianForFrame = nanmedian(output_1(:,:,frameNum));
            %centers = round(centers)
            output_temp = output_1(:,:,frameNum);
            output_temp(bBoxDataRow(2):bBoxDataRow(2)+7,bBoxDataRow(1):bBoxDataRow(1)+7) = medianForFrame;
            output_temp(bBoxDataRow(6):bBoxDataRow(6)+7,bBoxDataRow(5):bBoxDataRow(5)+7) = medianForFrame;
            output_temp(bBoxDataRow(10):bBoxDataRow(10)+7,bBoxDataRow(9):bBoxDataRow(9)+7) = medianForFrame;
            %output_temp((centers(4,2)-3):(centers(4,2)+4),(centers(4,1)-3):(centers(4,1)+4)) = medianForFrame;
            output_blanked(:,:,index2) = rescaleImage(output_temp);
            %clf
            %imshow(output_temp)
            %pause;
            index2=index2+1;
            %end
        %end
    end
end


for K=1:length(output_blanked(1, 1, :))
   outputFileName = sprintf('Neg_img_%d.tif',K+60);
   imwrite(output_blanked(:, :, K), outputFileName);
end

for K=1:length(output_neurons_fin(1, 1, :))
   outputFileName = sprintf('Pos_img_%d.tif',K+60);
   imwrite(output_neurons_fin(:, :, K), outputFileName);
end