%%%%%%%%%%%USE THIS CODE TO GET A MATRIX WITH AS MANY ROWS AS THERE ARE
%%%%%%%%%%%PIXELS IN THE REGION OF INTEREST


function coordsOfInterest = getROIforCHOP(MovieName)
    Mov1 = aviread_to_gray(MovieName,3);
    Mov = calculate_background(MovieName, 3, 4);
    
    %%%%%for BLUE LIGHT USE testLev = .95 & for GREEN LIGHT USE testLev =
    %%%%%.75
    testLev = .75;
    BW = im2bw(Mov, testLev);
    %BW = ~BW;
    [L,NUM] = bwlabel(BW);

    STATS = regionprops(L, {'Area'});
    LOCATION = regionprops(L, {'PixelList'});

    ObjectIndices = find([STATS.Area] >= 100000);
    %display(testLev);
    if(length(ObjectIndices)==1)
    coordsOfInterest = LOCATION(ObjectIndices).PixelList;
    end

        
  %%%%%%  UNCOMMENT IF YOU WANT TO SEE THE AREA OF INTEREST  
%     Mov1 = aviread_to_gray(MovieName,3);
%     imshow(Mov1.cdata)
%     for(i=1:100:length(LOCATION(ObjectIndices).PixelList(:,1)))
%     %for (i=1:100)    
%         x = LOCATION(ObjectIndices).PixelList(i,1);
%         y = LOCATION(ObjectIndices).PixelList(i,2);
%         hold on; plot(x,y,'+');
%     end
end
    
        