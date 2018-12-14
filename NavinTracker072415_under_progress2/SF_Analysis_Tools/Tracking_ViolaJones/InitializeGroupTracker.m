function [Pos_In_Rot_Image fn pn rotAngle orig_X_pos orig_Y_pos] = InitializeGroupTracker(pn,D,fileNumber)

% Get folder, first image, etc.
if(nargin==0)
[fn pn]=uigetfile('*.tif','select first file in movie');
movieFile=[pn fn];
else
    fn = D(fileNumber).name;
end


% open first image, then allow rotation, selection; record these
  

Mov = imread([pn,fn]);
imshow(Mov,[0 500]);
stopFlag = 0;
while(stopFlag==0)
    rotAngle = input ('Choose rotation angle');
    temp = imrotate(Mov,rotAngle);
    clf; figure(1); imshow(temp,[0 500])
    stopFlag = input ('Is the rotation angle correct? (0=NO;1=YES)');
end

display('Zoom in on cells')
pause;
display('Click on upper right corner of bounding box');
h = impoint;
Pos_In_Rot_Image = getPosition(h);


% Backcalculate where cells are in first frame

bbox_first_image = Pos_In_Rot_Image;

imgPoint = [];
imgPoint = ones(size(temp));
imgPoint(round(bbox_first_image(2)):(round(bbox_first_image(2))+1), round(bbox_first_image(1)):(round(bbox_first_image(1))+1)) = 127;

imgPointRot = imrotate(imgPoint, -rotAngle);
deRotatedImage = imrotate(temp,-rotAngle);

% Remove zero rows
imgPointRot(all(~deRotatedImage,2),:) = [];
deRotatedImage(all(~deRotatedImage,2),:) = [];

% Remove zero columns
imgPointRot( :, all(~deRotatedImage,1) ) = [];
deRotatedImage( :, all(~deRotatedImage,1) ) = [];

% original position of cells
[orig_X_pos, orig_Y_pos] = find(imgPointRot==127);
orig_X_pos = orig_X_pos(1);
orig_Y_pos = orig_Y_pos(1);


end
