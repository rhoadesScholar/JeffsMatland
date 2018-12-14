function varargout = bwselect3D(varargin)
%BWSELECT3D Select objects in binary 3D image.
%   BW3 = BWSELECT3D(BW1,C,R,N,SLICE) returns a binary image containing
%   the objects that overlap the voxel (R,C,SLICE). R and C can be
%   scalars or equal-length vectors. SLICE is a positive integer scalar,
%   representing a z-coordinate of BW1 to show. If R and C are vectors, BW3
%   contains the set of objects overlapping with any of the
%   voxels (R(k),C(k),SLICE). N can have a value of either 6, 16 or 26 (the
%   default), where 6 specifies 6-connected 3D objects, 16 specifies
%   16-connected 3D objects and 26 specifies 26-connected 3D objects.
%   Objects are connected sets of "on" pixels (i.e., having value of 1).
%
%   BW3 = BWSELECT3D(BW1,N,SLICE) displays the z-coordinate SLICE of the
%   image BW1 on the screen and lets you select the (R,C) coordinates using
%   the mouse. If you omit BW1, BWSELECT3D operates on the image in the
%   current axes. Use normal button clicks to add points. Pressing
%   <BACKSPACE> or <DELETE> removes the previously selected point. A
%   shift-click, right-click, or double-click selects the final point;
%   pressing <RETURN> finishes the selection without adding a point.
% %
%   [BW3,IDX] = BWSELECT3D(...) returns the linear indices of the 
%   pixels belonging to the selected objects.
%
%   If bwselect3D is called with no output arguments, the resulting
%   image is displayed in a new figure.
%
%   Class Support
%   ------------- 
%   The input image BW1 can be logical or any numeric type and 
%   must be 3-D and nonsparse.  The output image BW3 is logical.
%
%
%   If you use bwselect3D , please let me know: navarro@emse.fr
%
%   Laurent Navarro, 2012 

[BW,r,c,n,slice,newFig] = ParseInputs(varargin{:});

slice=ones(size(r))*slice;
seed_indices = sub2ind(size(BW), r(:), c(:), slice);
BW3 = imfill(~BW, seed_indices, n);
BW3 = BW3 & BW;

switch nargout
case 0
    % BWSELECT3D(...)
    
    if (newFig)
       figure;
    end
    imshow(BW3(:,:,slice(1)));
    
case 1
    % BW3 = BWSELECT3D(...)
    
    varargout{1} = BW3;
    
case 2
    % [BW3,IDX] = BWSELECT3D(...)
    
    varargout{1} = BW3;
    varargout{2} = find(BW3);
    
end

%%%
%%% Subfunction ParseInputs
%%%
function [BW,r,c,style,slice,newFig] = ParseInputs(varargin)

style = 26;
check_style = false;
check_BW = false;
newFig = 0;
narginchk(0,7);
slice=1;

switch nargin
case 0
    % BWSELECT3D
    
    [xdata, ydata, BW(:,:,slice), flag] = getimage;
    if (flag == 0)
        msgId = sprintf('images:bwselect3D:noImageFound', mfilename);
        error(message('images:bwselect3D:noImageFound'))
    end
    newFig = 1; 
    [xi,yi] = getpts;
    
    r = round(axes2pix(size(BW,1), ydata, yi));
    c = round(axes2pix(size(BW,2), xdata, xi));
    slice=round(size(BW,3)/2);
    
case 1
    if ((numel(varargin{1}) == 1) && ...
                ((varargin{1} == 4) || (varargin{1} == 8)))
        % BWSELECT3D(N)
        
        style = varargin{1};
        [xdata,ydata,BW(:,:,slice),flag] = getimage;
        if (flag == 0)
            msgId = sprintf('images:bwselect3D:noImageFound', mfilename);
            error(message('images:bwselect3D:noImageFound'))
        end
        
    else
        % BWSELECT3D(BW)
        
        BW = varargin{1};
        check_BW = true;
        BW_position = 1;
        xdata = [1 size(BW,2)];
        ydata = [1 size(BW,1)];
        slice=round(size(BW,3)/2);
        imshow(BW(:,:,slice),'XData',xdata,'YData',ydata);
        
    end
    
    newFig = 1;
    [xi,yi] = getpts;
    
    r = round(axes2pix(size(BW,1), ydata, yi));
    c = round(axes2pix(size(BW,2), xdata, xi));
    slice=round(size(BW,3)/2);
    
case 3
    % BWSELECT3D(BW, N, SLICE)
    
    BW = varargin{1};
    BW_position = 1;
    check_BW = true;
    
    style = varargin{2};
    style_position = 2;
    check_style = true;
    
    xdata = [1 size(BW,2)];
    ydata = [1 size(BW,1)];
    
    imshow(BW(:,:,varargin{3}),'XData',xdata,'YData',ydata);
    newFig = 1;
    [xi,yi] = getpts;
    
    r = round(axes2pix(size(BW,1), ydata, yi));
    c = round(axes2pix(size(BW,2), xdata, xi));
    slice=varargin{3};
    
case 4
    % BWSELECT3D(BW,Xi,Yi,SLICE)

    BW = varargin{1};
    BW_position = 1;
    check_BW = true;
    
    xdata = [1 size(BW,2)];
    ydata = [1 size(BW,1)];
    xi = varargin{2};
    yi = varargin{3};
    r = round(yi);
    c = round(xi);
    slice=varargin{4};
    
case 5
    % BWSELECT3D(BW,Xi,Yi,N,SLICE)
    
    BW = varargin{1};
    BW_position = 1;
    check_BW = true;
    
    xdata = [1 size(BW,2)];
    ydata = [1 size(BW,1)];
    xi = varargin{2};
    yi = varargin{3};
    r = round(yi);
    c = round(xi);
    
    style = varargin{4};
    style_position = 4;
    check_style = true;
    slice=varargin{5};
     
end

if check_BW
    validateattributes(BW,{'logical' 'numeric'},{'3d' 'nonsparse'}, ...
                  mfilename, 'BW', BW_position);
end

if ~islogical(BW)
    BW = BW ~= 0;
end

if check_style
    validateattributes(style, {'numeric'}, {'scalar'}, mfilename, ...
                  'N', style_position);
end

badPix = find((r < 1) | (r > size(BW,1)) | ...
              (c < 1) | (c > size(BW,2)));
if (~isempty(badPix))
    warning(message('images:bwselect3D:outOfRange'));
    r(badPix) = [];
    c(badPix) = [];
end 
