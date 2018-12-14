function patchTracks = processRefeed(finalTracks, edge, lawn)%bkgrnd can also be passed as edge to expedite process and find lawn anew
buffer = 4;
if nargin < 3
    [edge, lawn] = findBorderManually (edge);
end

imshow(lawn); hold on; plot(edge(:,1), edge(:,2),'LineWidth', 5);%reality check

w = 1;
patchTracks = struct();
trackNum = 1;
%delay4Index = [];
for t=1:length(finalTracks)
    xAll = [];
    yAll = [];
    iAll = [];
    xydif = abs([finalTracks(t).bound_box_corner - finalTracks(t).Path]) + [finalTracks(t).Wormlength/(buffer*finalTracks(t).PixelSize)];
    bx1 = [finalTracks(t).SmoothX - xydif(:,1)'];
    bx1(bx1 < 1)= 1;
    bx2 = [finalTracks(t).SmoothX + xydif(:,1)'];
    bx2(bx2 > size(lawn,2))=size(lawn,2);
    by1 = [finalTracks(t).SmoothY - xydif(:,2)'];
    by1(by1 < 1) = 1;
    by2 = [finalTracks(t).SmoothY + xydif(:,2)'];
    by2(by2 > size(lawn,1))=size(lawn,1);
    [x1, y1, i1] = polyxpoly(bx1, by1, edge(:,1), edge(:,2));
        if ~isempty(i1)
            xAll = [x1(1)];
            yAll = [y1(1)];
            iAll = [i1(1)];
        end
    [x2, y2, i2] = polyxpoly(bx2, by1, edge(:,1), edge(:,2));
        if ~isempty(i2)
            xAll = [xAll x2(1)];
            yAll = [yAll y2(1)];
            iAll = [iAll i2(1)];
        end
    [x3, y3, i3] = polyxpoly(bx1, by2, edge(:,1), edge(:,2));
        if ~isempty(i3)
            xAll = [xAll x3(1)];
            yAll = [yAll y3(1)];
            iAll = [iAll i3(1)];
        end
    [x4, y4, i4] = polyxpoly(bx2, by2, edge(:,1), edge(:,2));
        if ~isempty(i4)
            xAll = [xAll x4(1)];
            yAll = [yAll y4(1)];
            iAll = [iAll i4(1)];
        end
    [x5, y5, i5] = polyxpoly(finalTracks(t).SmoothX , finalTracks(t).SmoothY,edge(:,1), edge(:,2));
        if ~isempty(i5)
            xAll = [xAll x5(1)];
            yAll = [yAll y5(1)];
            iAll = [iAll i5(1)];
        end
    i = min(iAll);
    x = xAll(iAll == i);
    y = yAll(iAll == i);
    plot(finalTracks(t).SmoothX(1:5:end), finalTracks(t).SmoothY(1:5:end))
    verdict = false;
    if ~isempty(i)%refine lawn encounter
        for v = 1:i
            if ~isnan(finalTracks(t).Path(v,:))
                trackPoints = [bx1(v) by1(v); bx2(v) by1(v); bx1(v) by2(v); bx2(v) by2(v); finalTracks(t).Path(v,:)];
                
                for tP = 1:length(trackPoints)
%                     [distance, intXY] = ldist(trackPoints(tP,:), edge);
%                     closeEdge = intXY(dim);
%                     verdict = (closeEdge > trackPoints(tP,dim)) ~= side;
                    verdict = ~lawn(round(trackPoints(tP,2)), round(trackPoints(tP,1)));
                    if ~verdict
                        break
                    end
                end
                if ~verdict 
                    verdict = v >= 90;
                    i = v;
                    break;
                end
            end
        end
    end
    if ~isempty(i) && verdict
       if isdir('encounters')
           %orI = i;
           i = checkEncounter(i, finalTracks(t), trackNum, [x(1) y(1)]);%MANUAL CHECK HERE$$$
       else
           if exist(sprintf('encounterVids\\%s.mat', finalTracks(t).ID), 'file') < 1
                recordEncounter(i, finalTracks(t), trackNum);
           end
       end
       trackNum = trackNum + 1;
       if i
           %delay4Index(trackNum - 1) = i - orI;
           xy = finalTracks(t).Path(i(1),:);
           mapshow(x(1),y(1),'DisplayType','point','Marker','v');
           mapshow(xy(1),xy(2),'DisplayType','point','Marker','o');
           plot([xy(1) x(1)], [xy(2) y(1)]);
           tempTracks = finalTracks(t);
           tempTracks.refeedIndex = i(1);
           try
               patchTracks = [patchTracks tempTracks];
           catch
               patchTracks = tempTracks;
           end
           %pause(0.1);
           w = w + 1;
       end
    end
end
%dillydally = nanmean(delay4Index)
%pause;
end