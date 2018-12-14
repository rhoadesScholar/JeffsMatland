function [new_X_pos new_Y_pos] = getRotatedPosition(orig_X_pos,orig_Y_pos,rotAngle,ImageToRotate)
     
    


imgPoint = [];
imgPoint = ones(size(ImageToRotate));
imgPoint(orig_X_pos, orig_Y_pos) = 127;

imgPointRot = imrotate(imgPoint, rotAngle);

% Remove zero rows
%imgPointRot(all(~deRotatedImage,2),:) = [];
%deRotatedImage(all(~deRotatedImage,2),:) = [];

% Remove zero columns
% imgPointRot( :, all(~deRotatedImage,1) ) = [];
% deRotatedImage( :, all(~deRotatedImage,1) ) = [];

% original position of cells
[new_X_pos, new_Y_pos] = find(imgPointRot==127);
end