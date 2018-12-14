function [bboxes temp_Mov]  = getCandidateBBoxes(orig_X_pos,orig_Y_pos,rotAngle,D,i,pn,detector)

    temp_Mov = [];
    
    temp_Mov = imread([pn,D(i).name],'PixelRegion',{[(orig_X_pos-100),(orig_X_pos+100)],[(orig_Y_pos-100),(orig_Y_pos+100)]});
    
    temp_Mov = imrotate(temp_Mov,rotAngle);
    
    %center_New_Mov = round(length(temp_Mov(1,:))/2);
    
    %position_Old_Bbox = [center_New_Mov center_New_Mov];
    
    temp_Mov_8bit = rescaleImage(temp_Mov);
    
    bboxes = step(detector, temp_Mov_8bit);
end