function lawn_edge = find_lawn_edge(background)


% for(i=1:length(cc.PixelIdxList)) t2=zeros(512,512); t2(cc.PixelIdxList{i})=1; imshow(t2); disp([i]); pause; end



% tried to automate, but didn't want to deal w/ GUI coordination
% to make the program wait while external points brushed out
% these external points might also be removed automatically based on object
% sizes, etc
% in any case, the convex hull resulting from the auto-edge detect is not 
% as accurate as the manually defined one!!! ARRGH!!
% 
% ed = edge(background,'log',0.0015); 
% [r, c] = find(ed==1);
% imshow(background); hold on; plot(c,r,'.')
% linkdata on
% 
% sprintf('Use the brush tool and remove points outside the lawn. Hit return to continue')           
% 
% K = convhull(r,c);
% plot(c(K),r(K),'.r');
% 
% BW = roipoly(background,c(K),r(K));
% linkdata off
% clear('c'); clear('r'); clear('K'); clear('ed'); 

% Andres' drawn lawn edge - inner diameter = lawn edge
% level 0.55-0.7 0.005 steps, take find second largest object 
% pen-ring (largest object is the field)
% find level such that the second largest object only has one hole (a large
% one at that!)
for(level=0.55:0.005:0.7) 
    t1 = im2bw(bkgnd, level); 
    t1=~t1; 
    cc = bwconncomp_sorted(t1,'descend'); 
    edge=zeros(1024,1024); 
    edge(cc.PixelIdxList{2})=1;  
    imshow(edge); 
    disp([level]); 
    pause; 
end

bweuler(edge) number of holes - 1
problem: semicircle can give 0 as well!

ed = edge(ring,'sobel'); [r, c] = find(ed==1); imshow(~ring); hold on; plot(c,r,'.r')

ed = bwmorph(ring,'spur'); ed = bwmorph(ed,'thin',Inf); 
ed = bwmorph(ed,'spur'); ed = bwmorph(ed,'spur'); ed = bwmorph(ed,'spur'); 
ed = bwmorph(ed,'spur'); ed = bwmorph(ed,'spur'); ed = bwmorph(ed,'spur'); 
ed = bwmorph(ed,'spur'); ed = bwmorph(ed,'spur'); ed = bwmorph(ed,'spur'); 
ed = bwmorph(ed,'spur'); ed = bwmorph(ed,'spur'); ed = bwmorph(ed,'spur'); 

[r, c] = find(ed==1); imshow(~ring); hold on; plot(c,r,'.r'); hold off
K = convhull(r,c);
plot(c(K),r(K),'.g');

% BW = roipoly(background); 

dim = size(BW);
col = round(dim(2)/2);
row = min(find(BW(:,col)));
    
i=1;
while(isempty(col) || isempty(row))
    col = round(dim(2)/2) - i;
    if(isempty(col))
        col = round(dim(2)/2) + i;
    end
    row = min(find(BW(:,col)));
    i=i+1;
end

b = bwtraceboundary(BW,[row, col],'N');

% now reverse the columns to have (x,y)
lawn_edge(:,1) = b(:,2);
lawn_edge(:,2) = b(:,1);

clear('b');

return;
end


