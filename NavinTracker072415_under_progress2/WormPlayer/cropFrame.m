function new_axes  = cropFrame(frame, PathBounds, ZoomLevel, centroid, imageWidth, imageHeight, WormLength)

% function [frame, new_axes]  = cropFrame(frame, PathBounds, ZoomLevel, centroid, imageWidth, imageHeight, WormLength)

new_axes = [0 imageWidth 0 imageHeight];
CropDims = [];

if ( ZoomLevel == 1 )

    % Zoom to track
    CropWidth = PathBounds(3) - PathBounds(1);
    CropHeight = PathBounds(4) - PathBounds(2);

    CropDims = max(CropWidth, CropHeight);

    trackXMid = PathBounds(1) + ( (PathBounds(3) - PathBounds(1)) / 2 );
    trackYMid = PathBounds(2) + ( (PathBounds(4) - PathBounds(2)) / 2 );

    minX = trackXMid - ( CropDims/2 );
    minY = trackYMid - ( CropDims/2 );

    
elseif (ZoomLevel == 2 )
    % zoom to 50% of image
    
    CropWidth = imageWidth * .50;
    CropHeight = imageHeight * .50;
    
    minX = centroid(1) - CropWidth/2;
    minY = centroid(2) - CropHeight/2;
    
    CropDims = max(CropWidth, CropHeight);
        
elseif ( ZoomLevel == 3 )
    % zoom to 25% of image
    CropWidth = imageWidth * .25;
    CropHeight = imageHeight * .25;
    
    minX = centroid(1) - CropWidth/2;
    minY = centroid(2) - CropHeight/2;
    
    CropDims = max(CropWidth, CropHeight);

elseif ( ZoomLevel == 4 )
    % zoom to 10% of image
    CropWidth = imageWidth * .1;
    CropHeight = imageHeight * .1;
    
    minX = centroid(1) - CropWidth/2;
    minY = centroid(2) - CropHeight/2;
    
    CropDims = max(CropWidth, CropHeight);

elseif ( ZoomLevel == 5 )
    %zoom to 5% of image
    CropWidth = imageWidth * 0.05;
    CropHeight = imageHeight * 0.05;
    
    minX = centroid(1) - CropWidth/2;
    minY = centroid(2) - CropHeight/2;
    
    CropDims = max(CropWidth, CropHeight);

elseif ( ZoomLevel == 6 )
    %zoom to bounding box
    CropWidth = WormLength;
    CropHeight = WormLength;
    
    minX = centroid(1) - CropWidth/2;
    minY = centroid(2) - CropHeight/2;
    
    CropDims = max(CropWidth, CropHeight);
end


if ( ~isempty(CropDims) )
    % frame = imcrop(frame, [minX, minY, CropDims, CropDims]);
    new_axes = [minX (minX+CropDims)  minY (minY+CropDims)];
end

return

end

