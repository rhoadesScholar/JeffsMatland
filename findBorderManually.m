function [edge, lawn] = findBorderManually (bkgnd, edge)

figure;
imshow(imadjust(bkgnd));
hold on;

if nargin<2 || isempty(edge)
    edge = ginput2();
else
    plot(edge(:,1), edge(:,2));
end

dim = ~(abs(edge(1,2) - edge(end,2)) > abs(edge(1,1) - edge(end,1))) + 1;
other = (dim==1) + 1;

questdlg('Pick side of lawn.', 'Side of lawn', 'OK', 'OK');
    answer(1) = 'N';
    while answer(1) == 'N'
        food = ginput2(1);
        mapshow(food(1),food(2),'DisplayType','point','Marker','X');
        answer = questdlg('Are you sure there is food there?', 'Confirm', 'Yes', 'No', 'Yes');
    end
    
side = all(food(dim) < edge(:,dim));
lawn = zeros(size(bkgnd));
% lawn(:) = ~side;
for s = 1:(length(edge)-1)
    %ax +by + c = 0
    a = edge(s,2) - edge(s+1,2);
    b = edge(s+1,1) - edge(s,1);
    c = edge(s,1)*edge(s+1,2) - edge(s+1,1)*edge(s,2);
    iV = 1:size(lawn,other);
    for f = floor(edge(s,other)):ceil(edge(s+1,other))
        if f<=0
            f = 1;
        elseif f > size(lawn,dim)
            f = size(lawn,dim);
        end
        if dim == 1
            vec = ((a*iV + b*f + c)<=0);
            lawn(f,:) = vec~=side;%may cause errors
        else
           vec = ((a*f + b*iV + c)<=0);
           lawn(:,f) = vec==side;
        end
    end
end
close
end