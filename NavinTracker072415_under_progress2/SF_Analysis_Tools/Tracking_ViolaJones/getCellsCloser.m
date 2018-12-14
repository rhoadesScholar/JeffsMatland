function newRotAngle = getCellsCloser(orig_X_pos,orig_Y_pos,rotAngle,D,i,pn,detector,minPixelsMoved)
        
        index=1;
        anglesToCheck = [1 -1 2 -2 3 -3 4 -4 5 -5 6 -6 7 -7 8 -8 9 -9 10 -10 11 -11 12 -12 13 -13 14 -14 15 -15 16 -16 17 -17 18 -18 19 -19 20 -20 21 -21 22 -22 23 -23 24 -24 25 -25 26 -26 27 -27 28 -28 29 -29 30 -30 31 -31 32 -32 33 -33 34 -34 35 -35 36 -36 37 -37 38 -38 39 -39 40 -40 ];
        %anglesToCheck = [1 -1 2 -2 3 -3 4 -4 5 -5 6 -6 7 -7 8 -8 9 -9 10 -10 11 -11 12 -12 13 -13 14 -14 15 -15 16 -16 17 -17 18 -18 19 -19 20 -20 21 -21 22 -22 23 -23 24 -24 25 -25 26 -26 27 -27 28];
        closestCells(1:length(anglesToCheck)) = NaN;
        for(j=anglesToCheck)
        [bboxes temp_Mov] = getCandidateBBoxes(orig_X_pos,orig_Y_pos,rotAngle+j,D,i,pn,detector); 
        numRowBboxes = size(bboxes,1);
        center_New_Mov = round(length(temp_Mov(1,:))/2);
        DistanceHere = [];
        if(numRowBboxes>0)

        for(k=1:numRowBboxes)
            DistanceHere(k) = CalcDist(center_New_Mov,center_New_Mov,bboxes(k,1),bboxes(k,2));
        end
        [Y,indexMin] = min(DistanceHere);
        closestCells(index) = Y;
            %display(bboxes(1,:))
            %display(Y)
            %display(index)

            
        else
            closestCells(index) = 100000;
        end
        index=index+1;
        end
        %display(closestCells)
        %[Y2,indexMin2] = min(closestCells);
        [Y3,ind3] = sort(closestCells);
        
        %display(indexMin2)
        for(i=1:49)
        newRotAngle(i) = rotAngle+(anglesToCheck(ind3(i)));
        end
        
        
end