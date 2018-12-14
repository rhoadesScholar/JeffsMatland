function [allBursts, animalBursts] = getBursts(allFinalTracks, thresh, bef, aft, bin)
%[speedN2, speedCX, speedresc] = getSpeeds(allFinalTracks);


strains = fields(allFinalTracks);
if nargin == 5
    for s = 1:length(strains)
        allFinalTracks.(strains{s}) = nanbinSpeed(allFinalTracks.(strains{s}),bin);
    end
end
allBursts = struct();
animalBursts = struct();
counts = zeros(length(strains),1);
for (s=1:length(strains))%all strains
    for(w=1:length(allFinalTracks.(char(strains(s)))))%all worms per strain
        lastevt=0;
        for (f=1:length(allFinalTracks.(char(strains(s)))(w).Speed))%~all frames per worm
            if (allFinalTracks.(char(strains(s)))(w).Speed(f)>=thresh && (f-bef)>lastevt)
                if ((f-bef)<1)
                    buffer = nan(1,(bef+aft+1)-length(allFinalTracks.(char(strains(s)))(w).Speed(1:(f+aft))));
                    newevt = [buffer allFinalTracks.(char(strains(s)))(w).Speed(1:(f+aft))];
                elseif ((f+aft)>length(allFinalTracks.(char(strains(s)))(w).Speed))
                    buffer = nan(1,(bef+aft+1)-length(allFinalTracks.(char(strains(s)))(w).Speed((f-bef):length(allFinalTracks.(char(strains(s)))(w).Speed))));
                    newevt = [allFinalTracks.(char(strains(s)))(w).Speed((f-bef):length(allFinalTracks.(char(strains(s)))(w).Speed)) buffer];
                else
                    newevt = allFinalTracks.(char(strains(s)))(w).Speed((f-bef):(f+aft));
                end
                
                if (isfield(allBursts,(char(strains(s)))))%add burst speeds to matrix
                    allBursts.(char(strains(s))) = [allBursts.(char(strains(s))); newevt];
                else
                    allBursts.(char(strains(s))) = newevt;
                end
                
                if (isfield(animalBursts,(char(strains(s)))))%add to list of bursting animals
                    animalBursts.(char(strains(s))) = [animalBursts.(char(strains(s))) w];
                else
                    animalBursts.(char(strains(s))) = w;
                end
                
                lastevt = f;
                f = f + aft;
                counts(s)=counts(s)+1;
            end
        end
    end
end

%plotThreeHists(burstsN2, burstsCX, burstsresc, 'n2', 'cx', 'resc', 100); axis([0 .25 0 .25]);

%countStatement = '';
for (s=1:length(strains))
    if isfield(allBursts, strains{s})
        figure;
        imagesc(allBursts.(char(strains(s))),[0.01 0.3]);
        title(strcat(strains(s),' event count = ', num2str(counts(s))));
        %countStatement = strcat(countStatement, strains(i),' event count = ', num2str(counts(i)), '|||||||------>>>>>>>_______');
    end
end
%countStatement
%pause
 
% burstsCX = [];
% t=1;
% f=1;
% j=0;
% CXcnt=0;
% for(i=1:length(allFinalTracks.CX16814))
%     for (f=t:(t+length(allFinalTracks.CX16814(i).Speed)-1))
%         if (speedCX(f)>=thresh && f>j)
%             if ((f-bef)<t)
%                 burstsCX = [burstsCX speedCX(t:(f+aft))];
%             elseif ((f+aft)>(t+length(allFinalTracks.CX16814(i).Speed)-1))
%                 burstsCX = [burstsCX speedCX((f-bef):(t+length(allFinalTracks.CX16814(i).Speed)))];
%             else
%                 burstsCX = [burstsCX speedCX((f-bef):(f+aft))];
%             end
%             j = f+aft;
%             CXcnt=CXcnt+1;
%         end
%     end
%     t=t+length(allFinalTracks.CX16814(i).Speed);
% end
% 
% burstsresc = [];
% t=1;
% f=1;
% j=0;
% resccnt=0;
% for(i=1:length(allFinalTracks.del3del7rescue3C))
%     for (f=t:(t+length(allFinalTracks.del3del7rescue3C(i).Speed)-1))
%         if (speedresc(f)>=thresh && f>j)
%             if ((f-bef)<t)
%                 burstsresc = [burstsresc speedresc(t:(f+aft))];
%             elseif ((f+aft)>(t+length(allFinalTracks.del3del7rescue3C(i).Speed)-1))
%                 burstsresc = [burstsresc speedresc((f-bef):(t+length(allFinalTracks.del3del7rescue3C(i).Speed)))];
%             else
%                 burstsresc = [burstsresc speedresc((f-bef):(f+aft))];
%             end
%             j = f+aft;
%             resccnt=resccnt+1;
%         end
%     end
%     t=t+length(allFinalTracks.del3del7rescue3C(i).Speed);
% end
% 
% plotThreeHists(burstsN2, burstsCX, burstsresc, 'n2', 'cx', 'resc', 100); axis([0 .25 0 .25]);
% 
% ['N2 event count = ', num2str(N2cnt), '; CX16814 event count = ', num2str(CXcnt), '; rescue event count = ', num2str(resccnt)]
% pause
% % %%
% % t=1;
% % f=1;
% % for(i=1:length(allFinalTracks.N2))
% %     for (f=t:100:(t+length(allFinalTracks.N2(i).Speed)))
% %         ['i=', num2str(i), ' f=', num2str(f), ' ', num2str(t), ':', num2str(t+length(allFinalTracks.N2(i).Speed))]
% %         pause
% %     end
% %     t=t+length(allFinalTracks.N2(i).Speed);
% % end