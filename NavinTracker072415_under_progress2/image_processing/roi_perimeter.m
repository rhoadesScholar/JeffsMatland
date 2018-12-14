function [X, Y] = roi_perimeter(background)
% [X, Y] = roi_perimeter(background)
% uses GUI to pick ROI ... returns x and y coords of the entire perimeter

BW = roipoly(background);

dim = size(BW);
col = round(dim(2)/2);
row = min(find(BW(:,col)));

i=1;
while(isempty(col) || isempty(row))
    col = round(dim(2)/2) - i;
    if(col<=0)
        col=[];
    end
    if(isempty(col))
        col = round(dim(2)/2) + i;
        if(col>dim(2))
            col = randint(dim(2));
        end
    end
    row = min(find(BW(:,col)));
    i=i+1;
end
b = bwtraceboundary(BW,[row, col],'N');

X = b(:,2);
Y = b(:,1);

clear('BW');
clear('b');
clear('col');
clear('row');
clear('dim');

return;
end
