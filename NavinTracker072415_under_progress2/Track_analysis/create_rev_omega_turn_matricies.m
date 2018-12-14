function [OmegaTrans, Reversals, Upsilons] = create_rev_omega_turn_matricies(Track, OmegaTrans, Reversals, Upsilons, RevTransI, PosRevTransI, NegRevTransI)
% [OmegaTrans, Reversals, Upsilons] = create_rev_omega_turn_matricies(Track, OmegaTrans, Reversals, Upsilons, RevTransI, PosRevTransI, NegRevTransI)

global Prefs;

maxRevDurationFrames = Prefs.MaxRevDuration*Track.FrameRate; 
MaxUpsilonOmegaDurationFrames = Prefs.MaxUpsilonOmegaDuration*Track.FrameRate;
minOmegaDurationFrames = Prefs.MinOmegaDuration*Track.FrameRate;
pixelWormLength = Track.Wormlength/Track.PixelSize; % wormlength in pixels
tracklength = length(Track.Frames);

NetTransSort = [];



%remove omegas from reversal transition events
if (OmegaTrans)
    OmegaNum = size(OmegaTrans);
    PosTransOverlap = [];
    NegTransOverlap =[];
    for i = 1:OmegaNum(1)
        PosTransOverlap = [PosTransOverlap, find(PosRevTransI >= OmegaTrans(i,1) & PosRevTransI <= (OmegaTrans(i,2)+4))];
        NegTransOverlap = [NegTransOverlap, find(NegRevTransI >= OmegaTrans(i,1) & NegRevTransI <= (OmegaTrans(i,2)+4))];
    end
    PosRevTransI(PosTransOverlap) = [];
    NegRevTransI(NegTransOverlap) = [];
end
 
%define unitary event ie. transitions including omega bends
if isempty(RevTransI)
    Reversals = [];
    RevTransitions = [];
else
    if isempty(RevTransI)
        RevTransitions = [];
    else
        if isempty(PosRevTransI)
            PosRevTransition = [];
        else
            PosRevTransEndI = find(diff(PosRevTransI) > 2); 
            
            if PosRevTransI(length(PosRevTransI)) ~= PosRevTransI(PosRevTransEndI)
                LastPosRevTransEndI = length(PosRevTransI);
                PosRevTransEndI = [PosRevTransEndI, LastPosRevTransEndI];
            end
            
            if PosRevTransEndI
                PosRevTransition = [PosRevTransI(1), PosRevTransI(PosRevTransEndI(1))];
                for k = 1:length(PosRevTransEndI)-1
                    PosRevTransition = [PosRevTransition; PosRevTransI(PosRevTransEndI(k)+1), PosRevTransI(PosRevTransEndI(k+1))];
                end
                if Track.NumFrames - PosRevTransI(length(PosRevTransI)) < 2
                    PosRevTransition(length(PosRevTransition(:,2)),2) = Track.NumFrames;
                end
            else
                PosRevTransition = [PosRevTransI(1), PosRevTransI(length(PosRevTransI))];
            end
        end
        
        if isempty(NegRevTransI)
            NegRevTransition = [];
        else
            NegRevTransEndI = find(diff(NegRevTransI) > 2);
            if NegRevTransI(length(NegRevTransI)) ~= NegRevTransI(NegRevTransEndI)
                LastNegRevTransEndI = length(NegRevTransI);
                NegRevTransEndI = [NegRevTransEndI, LastNegRevTransEndI];
            end
            if NegRevTransEndI
                NegRevTransition = [NegRevTransI(1), NegRevTransI(NegRevTransEndI(1))];
                for k = 1:length(NegRevTransEndI)-1
                    NegRevTransition = [NegRevTransition; NegRevTransI(NegRevTransEndI(k)+1), NegRevTransI(NegRevTransEndI(k+1))];
                end
                if Track.NumFrames - NegRevTransI(length(NegRevTransI)) < 2
                    NegRevTransition(length(NegRevTransition(:,2)),2) = Track.NumFrames;
                end
            else
                NegRevTransition = [NegRevTransI(1), NegRevTransI(length(NegRevTransI))];
            end
        end

        
        
        RevTransitions = [PosRevTransition; NegRevTransition];
        RevTransitions = sort(RevTransitions);
        
    end
    
    
    % filter out single frame blips due to jitter ... 
    % modify for 1 fps movies
    
    StalledTransI=[]; PairedStallI=[]; NonPairedStallI=[];
    if(Track.FrameRate > 1)
        StalledTransI = find(diff(RevTransitions,1,2) < 1);
        PairedStallI = find(diff(StalledTransI)< 2);
        NonPairedStallI = find(diff(PairedStallI)< 2);
    end
    
%     StalledTransI
%     PairedStallI
%     NonPairedStallI
%     RevTransitions(StalledTransI)
%     RevTransitions(StalledTransI(PairedStallI))
%     RevTransitions(StalledTransI(PairedStallI(NonPairedStallI)))
    
    
    if NonPairedStallI
        PairedStallI(NonPairedStallI+1) = [];
    end
    if PairedStallI
        StalledTransI([PairedStallI;1+PairedStallI]) = [];
    end
    % if OmegaTrans
    [StalledOmegaTrans, iT, iO] = intersect(RevTransitions(StalledTransI,:), OmegaTrans, 'rows');
    [StallBeforeOmegaTrans, iP, iQ] = intersect(RevTransitions, OmegaTrans, 'rows');
    iP = iP - 1;
    [StallBeforeOmegaTransI, iR, iS] = intersect(StalledTransI, iP, 'rows');
    iT = [iT;iR];
    StalledTransI(iT) = [];
    % end
    
    RevTransitions(StalledTransI,:) = [];
    
    NetTrans = [RevTransitions;OmegaTrans];
    NetTransSort = sortrows(NetTrans);
    [O,NetTransOmegaI,Oi] = intersect(NetTransSort, OmegaTrans, 'rows');
end

if isempty(NetTransSort)
    NetTransSort = OmegaTrans;
end

rev_matr_generation_ctr=0;
max_cycles_rev_matr_gen=0;
bad_transitions=1;
while(~isempty(bad_transitions) && rev_matr_generation_ctr<=max_cycles_rev_matr_gen)
    
    clear('Reversals');
    Reversals = [];
    CurrentReversals = RevTransitions;
    RemainingReversals = RevTransitions;
    RemainingRevNum = size(RemainingReversals);
        
    if isempty(OmegaTrans)
        %The following takes care of tracks with no omegas but with at least
        %one reversal
        while RemainingRevNum(1) > 1
            
            RevIntervals = diff(RemainingReversals(:,1));
            MinRevInterval = min(RevIntervals);
            ShortestRevInterval = min(find(RevIntervals == MinRevInterval));
            RevLen =  RemainingReversals(ShortestRevInterval+1,2) - RemainingReversals(ShortestRevInterval,1);
            StartToRev = RemainingReversals(ShortestRevInterval,1);
            RevToEnd = Track.NumFrames - RemainingReversals(ShortestRevInterval+1,2);
            if RevLen > maxRevDurationFrames %if this potential reversal without omega bend lasts longer than MaxRevDuration seconds
                RemainingReversals = [];
            else
                Reversals = [Reversals;RemainingReversals(ShortestRevInterval,1),...
                    RemainingReversals(ShortestRevInterval+1,2),...
                    track_path_length_vector(Track, RemainingReversals(ShortestRevInterval,1), RemainingReversals(ShortestRevInterval+1,2) )./pixelWormLength];
                    %% CalcDis(Track.SmoothX(RemainingReversals(ShortestRevInterval,1)),Track.SmoothY(RemainingReversals(ShortestRevInterval,1)),Track.SmoothX(RemainingReversals(ShortestRevInterval+1,2)),Track.SmoothY(RemainingReversals(ShortestRevInterval+1,2)))./pixelWormLength];
                RemainingReversals(ShortestRevInterval:ShortestRevInterval+1,:) = [];
                
            end
            
            RemainingRevNum = size(RemainingReversals);
        end
    else
        
        
        %if there is an omega bend
        %first omega bend
        CurrentOmegaTransI = OmegaTrans(1,:);
        if CurrentOmegaTransI(1) >= maxRevDurationFrames | length(find(NetTransSort(:,1) < CurrentOmegaTransI(1))) >= 2
            RevBeforeOmegaI = find(NetTransSort(:,1) < CurrentOmegaTransI(1));
            if RevBeforeOmegaI
                MaxRBOI = length(RevBeforeOmegaI);
                while MaxRBOI
                    if mod(length(RevBeforeOmegaI),2) == 0
                        if CurrentOmegaTransI(1) - NetTransSort(RevBeforeOmegaI(MaxRBOI),1) > maxRevDurationFrames
                            Reversals = [Reversals; NetTransSort((1:2:RevBeforeOmegaI(MaxRBOI)),1),...
                                NetTransSort((2:2:RevBeforeOmegaI(MaxRBOI)),2),...
                                track_path_length_vector(Track, NetTransSort((1:2:RevBeforeOmegaI(MaxRBOI)),1), NetTransSort((2:2:RevBeforeOmegaI(MaxRBOI)),1) )./pixelWormLength];
                                % CalcDis(Track.SmoothX(NetTransSort((1:2:RevBeforeOmegaI(MaxRBOI)),1)),Track.SmoothY(NetTransSort((1:2:RevBeforeOmegaI(MaxRBOI)),1)),Track.SmoothX(NetTransSort((2:2:RevBeforeOmegaI(MaxRBOI)),1)),Track.SmoothY(NetTransSort((2:2:RevBeforeOmegaI(MaxRBOI)),1)))./pixelWormLength];
                            RevBeforeOmegaI = [];
                        elseif CurrentOmegaTransI(1) - NetTransSort(RevBeforeOmegaI(MaxRBOI),1) < 2*Prefs.FrameRate & CurrentOmegaTransI(1) - NetTransSort(RevBeforeOmegaI(MaxRBOI-1)) < maxRevDurationFrames
                            Reversals = [Reversals; NetTransSort((1:2:max(RevBeforeOmegaI)),1),...
                                NetTransSort((2:2:max(RevBeforeOmegaI)),2),...
                                track_path_length_vector(Track, NetTransSort((min(RevBeforeOmegaI):2:max(RevBeforeOmegaI)),1), NetTransSort((min(RevBeforeOmegaI)+1:2:max(RevBeforeOmegaI)),1) )./pixelWormLength];
                                % CalcDis(Track.SmoothX(NetTransSort((min(RevBeforeOmegaI):2:max(RevBeforeOmegaI)),1)),Track.SmoothY(NetTransSort((min(RevBeforeOmegaI):2:max(RevBeforeOmegaI)),1)),Track.SmoothX(NetTransSort((min(RevBeforeOmegaI)+1:2:max(RevBeforeOmegaI)),1)),Track.SmoothY(NetTransSort((min(RevBeforeOmegaI)+1:2:max(RevBeforeOmegaI)),1)))./pixelWormLength];
                            RevBeforeOmegaI = [];
                        else
                            Reversals = [Reversals; NetTransSort(max(RevBeforeOmegaI),1),...
                                NetTransSort(max(RevBeforeOmegaI)+1,1),...
                                track_path_length_vector(Track, NetTransSort(max(RevBeforeOmegaI),1), NetTransSort(max(RevBeforeOmegaI)+1,1) )./pixelWormLength];
                                %% CalcDis(Track.SmoothX(NetTransSort(max(RevBeforeOmegaI),1)),Track.SmoothY(NetTransSort(max(RevBeforeOmegaI),1)),Track.SmoothX(NetTransSort(max(RevBeforeOmegaI)+1,1)),Track.SmoothY(NetTransSort(max(RevBeforeOmegaI)+1,1)))./pixelWormLength];
                            
                            RevBeforeOmegaI(MaxRBOI) = [];
                        end
                    else
                        if MaxRBOI > 1
                            if CurrentOmegaTransI(1) - NetTransSort(RevBeforeOmegaI(MaxRBOI),1) < 2*Prefs.FrameRate & CurrentOmegaTransI(1) - NetTransSort(RevBeforeOmegaI(MaxRBOI-1)) < maxRevDurationFrames
                                Reversals = [Reversals; NetTransSort(max(RevBeforeOmegaI)-1,1),...
                                    NetTransSort(max(RevBeforeOmegaI),2),...
                                    track_path_length_vector(Track, NetTransSort(max(RevBeforeOmegaI)-1,1), NetTransSort(max(RevBeforeOmegaI),1) )./pixelWormLength];
                                    % CalcDis(Track.SmoothX(NetTransSort(max(RevBeforeOmegaI)-1,1)),Track.SmoothY(NetTransSort(max(RevBeforeOmegaI)-1,1)),Track.SmoothX(NetTransSort(max(RevBeforeOmegaI),1)),Track.SmoothY(NetTransSort(max(RevBeforeOmegaI),1)))./pixelWormLength];
                                RevBeforeOmegaI(MaxRBOI-1:MaxRBOI) = [];
                                %find longest inter-transition interval
                                while length(RevBeforeOmegaI) > 2
                                    EndI = RevBeforeOmegaI;
                                    EndI(1) = [];
                                    StartI = RevBeforeOmegaI;
                                    StartI(length(RevBeforeOmegaI)) = [];
                                    LongRunI = find(NetTransSort(EndI,1)-NetTransSort(StartI,1) == max(NetTransSort(EndI,1)-NetTransSort(StartI,1)));
                                    if LongRunI(1) == 1
                                        Reversals = [Reversals; NetTransSort(RevBeforeOmegaI(2),1),...
                                            NetTransSort(RevBeforeOmegaI(3),2)...
                                            track_path_length_vector(Track, NetTransSort(RevBeforeOmegaI(2),1), NetTransSort(RevBeforeOmegaI(3),2) )./pixelWormLength];
                                            %% CalcDis(Track.SmoothX(NetTransSort(RevBeforeOmegaI(2),1)),Track.SmoothY(NetTransSort(RevBeforeOmegaI(2),1)),Track.SmoothX(NetTransSort(RevBeforeOmegaI(3),2)),Track.SmoothY(NetTransSort(RevBeforeOmegaI(3),2)))./pixelWormLength];
                                        RevBeforeOmegaI(1:3) = [];
                                    elseif LongRunI(1) == length(RevBeforeOmegaI)-1
                                        Reversals = [Reversals; NetTransSort(RevBeforeOmegaI(length(RevBeforeOmegaI)-2),1),...
                                            NetTransSort(RevBeforeOmegaI(length(RevBeforeOmegaI)-1),2), ...
                                            track_path_length_vector(Track, NetTransSort(RevBeforeOmegaI(length(RevBeforeOmegaI)-2),1), NetTransSort(RevBeforeOmegaI(length(RevBeforeOmegaI)-1),2) )./pixelWormLength];
                                            %% CalcDis(Track.SmoothX(NetTransSort(RevBeforeOmegaI(length(RevBeforeOmegaI)-2),1)),Track.SmoothY(NetTransSort(RevBeforeOmegaI(length(RevBeforeOmegaI)-2),1)),Track.SmoothX(NetTransSort(RevBeforeOmegaI(length(RevBeforeOmegaI)-1),2)),Track.SmoothY(NetTransSort(RevBeforeOmegaI(length(RevBeforeOmegaI)-1),2)))./pixelWormLength];
                                        RevBeforeOmegaI(length(RevBeforeOmegaI)-2:length(RevBeforeOmegaI)) = [];
                                    else
                                        Reversals = [Reversals; NetTransSort(RevBeforeOmegaI(LongRunI(1)-1):2:RevBeforeOmegaI(LongRunI(1)+1),1),...
                                            NetTransSort(RevBeforeOmegaI(LongRunI(1)):2:RevBeforeOmegaI(LongRunI(1)+2),2)...
                                            track_path_length_vector(Track, NetTransSort(RevBeforeOmegaI(LongRunI(1)-1):2:RevBeforeOmegaI(LongRunI(1)+1),1), NetTransSort(RevBeforeOmegaI(LongRunI(1)):2:RevBeforeOmegaI(LongRunI(1)+2),2) )./pixelWormLength];
                                            %% CalcDis(Track.SmoothX(NetTransSort(RevBeforeOmegaI(LongRunI(1)-1):2:RevBeforeOmegaI(LongRunI(1)+1),1)),Track.SmoothY(NetTransSort(RevBeforeOmegaI(LongRunI(1)-1):2:RevBeforeOmegaI(LongRunI(1)+1),1)),Track.SmoothX(NetTransSort(RevBeforeOmegaI(LongRunI(1)):2:RevBeforeOmegaI(LongRunI(1)+2),2)),Track.SmoothY(NetTransSort(RevBeforeOmegaI(LongRunI(1)):2:RevBeforeOmegaI(LongRunI(1)+2),2)))./pixelWormLength];
                                        RevBeforeOmegaI(LongRunI(1)-1:LongRunI(1)+2) = [];
                                    end
                                end
                            else
                                Reversals = [Reversals; NetTransSort((1:2:(RevBeforeOmegaI(MaxRBOI)+1)),1),...
                                    NetTransSort((2:2:(RevBeforeOmegaI(MaxRBOI)+1)),1),...
                                    track_path_length_vector(Track, NetTransSort((1:2:(RevBeforeOmegaI(MaxRBOI)+1)),1), NetTransSort((2:2:(RevBeforeOmegaI(MaxRBOI)+1)),1) )./pixelWormLength];
                                    %% CalcDis(Track.SmoothX(NetTransSort((1:2:(RevBeforeOmegaI(MaxRBOI)+1)),1)),Track.SmoothY(NetTransSort((1:2:(RevBeforeOmegaI(MaxRBOI)+1)),1)),Track.SmoothX(NetTransSort((2:2:(RevBeforeOmegaI(MaxRBOI)+1)),1)),Track.SmoothY(NetTransSort((2:2:(RevBeforeOmegaI(MaxRBOI)+1)),1)))./pixelWormLength];
                                
                            end
                        else
                            if CurrentOmegaTransI(1) - NetTransSort(RevBeforeOmegaI(MaxRBOI),1) < maxRevDurationFrames
                                Reversals = [Reversals; NetTransSort((RevBeforeOmegaI(1):2:(max(RevBeforeOmegaI)+1)),1),...
                                    NetTransSort(((RevBeforeOmegaI(1)+1):2:(max(RevBeforeOmegaI)+1)),1),...
                                    track_path_length_vector(Track, NetTransSort((RevBeforeOmegaI(1):2:(max(RevBeforeOmegaI)+1)),1), NetTransSort(((RevBeforeOmegaI(1)+1):2:(max(RevBeforeOmegaI)+1)),1) )./pixelWormLength];
                                    %% CalcDis(Track.SmoothX(NetTransSort((RevBeforeOmegaI(1):2:(max(RevBeforeOmegaI)+1)),1)),Track.SmoothY(NetTransSort((RevBeforeOmegaI(1):2:(max(RevBeforeOmegaI)+1)),1)),Track.SmoothX(NetTransSort(((RevBeforeOmegaI(1)+1):2:(max(RevBeforeOmegaI)+1)),1)),Track.SmoothY(NetTransSort(((RevBeforeOmegaI(1)+1):2:(max(RevBeforeOmegaI)+1)),1)))./pixelWormLength];
                            end
                        end
                        RevBeforeOmegaI = [];
                    end
                    
                    MaxRBOI = length(RevBeforeOmegaI);
                end
            end
        end
        
        %after last omega bend
        CurrentOmegaTransI = OmegaTrans(OmegaNum(1),:);
        
        RevAfterOmegaI = find(NetTransSort(:,1) > CurrentOmegaTransI(:,2));
        if RevAfterOmegaI
            if mod(length(RevAfterOmegaI),2) ==0
                Reversals = [Reversals; NetTransSort(RevAfterOmegaI:2:max(RevAfterOmegaI),1),...
                    NetTransSort(RevAfterOmegaI+1:2:max(RevAfterOmegaI),2),...
                    track_path_length_vector(Track, NetTransSort(RevAfterOmegaI:2:max(RevAfterOmegaI),1), NetTransSort(RevAfterOmegaI+1:2:max(RevAfterOmegaI),1)  )./pixelWormLength];
                    % CalcDis(Track.SmoothX(NetTransSort(RevAfterOmegaI:2:max(RevAfterOmegaI),1)),Track.SmoothY(NetTransSort(RevAfterOmegaI:2:max(RevAfterOmegaI),1)),Track.SmoothX(NetTransSort(RevAfterOmegaI+1:2:max(RevAfterOmegaI),1)),Track.SmoothY(NetTransSort(RevAfterOmegaI+1:2:max(RevAfterOmegaI),1)))./pixelWormLength];
            elseif length(RevAfterOmegaI)~= 1
                Reversals = [Reversals; NetTransSort(RevAfterOmegaI:2:max(RevAfterOmegaI)-1,1),...
                    NetTransSort(RevAfterOmegaI+1:2:max(RevAfterOmegaI)-1,2),...
                    track_path_length_vector(Track, NetTransSort(RevAfterOmegaI:2:max(RevAfterOmegaI)-1,1), NetTransSort(RevAfterOmegaI+1:2:max(RevAfterOmegaI)-1,1) )./pixelWormLength];
                    % CalcDis(Track.SmoothX(NetTransSort(RevAfterOmegaI:2:max(RevAfterOmegaI)-1,1)),Track.SmoothY((NetTransSort(RevAfterOmegaI:2:max(RevAfterOmegaI)-1,1))),Track.SmoothX(NetTransSort(RevAfterOmegaI+1:2:max(RevAfterOmegaI)-1,1)),Track.SmoothY(NetTransSort(RevAfterOmegaI+1:2:max(RevAfterOmegaI)-1,1)))./pixelWormLength];
            end
        end
        
        %for other omega bends
        if OmegaNum(1)>=2
            for i = 2:OmegaNum(1)
                
                RevBeforeOmegaI = [min(find(NetTransSort(:,1)>OmegaTrans(i-1,2))):max(find(NetTransSort(:,1)<OmegaTrans(i,1)))];
                CurrentOmegaTransI = OmegaTrans(i,:);
                
                if RevBeforeOmegaI
                    MaxRBOI = length(RevBeforeOmegaI);
                    while MaxRBOI
                        if mod(length(RevBeforeOmegaI),2) == 0
                            if CurrentOmegaTransI(1) - NetTransSort(RevBeforeOmegaI(MaxRBOI),1) > maxRevDurationFrames
                                Reversals = [Reversals; NetTransSort((min(RevBeforeOmegaI):2:max(RevBeforeOmegaI)),1),...
                                    NetTransSort((min(RevBeforeOmegaI)+1:2:max(RevBeforeOmegaI)),2),...
                                    track_path_length_vector(Track, NetTransSort((min(RevBeforeOmegaI):2:max(RevBeforeOmegaI)),1), NetTransSort((min(RevBeforeOmegaI)+1:2:max(RevBeforeOmegaI)),1) )./pixelWormLength];
                                    % CalcDis(Track.SmoothX(NetTransSort((min(RevBeforeOmegaI):2:max(RevBeforeOmegaI)),1)),Track.SmoothY(NetTransSort((min(RevBeforeOmegaI):2:max(RevBeforeOmegaI)),1)),Track.SmoothX(NetTransSort((min(RevBeforeOmegaI)+1:2:max(RevBeforeOmegaI)),1)),Track.SmoothY(NetTransSort((min(RevBeforeOmegaI)+1:2:max(RevBeforeOmegaI)),1)))./pixelWormLength];
                                RevBeforeOmegaI = [];
                            elseif CurrentOmegaTransI(1) - NetTransSort(RevBeforeOmegaI(MaxRBOI),1) < 2.5*Prefs.FrameRate & CurrentOmegaTransI(1) - NetTransSort(RevBeforeOmegaI(MaxRBOI-1)) < maxRevDurationFrames
                                Reversals = [Reversals; NetTransSort((min(RevBeforeOmegaI):2:max(RevBeforeOmegaI)),1),...
                                    NetTransSort((min(RevBeforeOmegaI)+1:2:max(RevBeforeOmegaI)),2),...
                                    track_path_length_vector(Track, NetTransSort((min(RevBeforeOmegaI):2:max(RevBeforeOmegaI)),1), NetTransSort((min(RevBeforeOmegaI)+1:2:max(RevBeforeOmegaI)),1) )./pixelWormLength];
                                    % CalcDis(Track.SmoothX(NetTransSort((min(RevBeforeOmegaI):2:max(RevBeforeOmegaI)),1)),Track.SmoothY(NetTransSort((min(RevBeforeOmegaI):2:max(RevBeforeOmegaI)),1)),Track.SmoothX(NetTransSort((min(RevBeforeOmegaI)+1:2:max(RevBeforeOmegaI)),1)),Track.SmoothY(NetTransSort((min(RevBeforeOmegaI)+1:2:max(RevBeforeOmegaI)),1)))./pixelWormLength];
                                RevBeforeOmegaI = [];
                            else
                                Reversals = [Reversals; NetTransSort(max(RevBeforeOmegaI),1),...
                                    NetTransSort(max(RevBeforeOmegaI)+1,1),...
                                    track_path_length_vector(Track, NetTransSort(max(RevBeforeOmegaI),1), NetTransSort(max(RevBeforeOmegaI)+1,1) )./pixelWormLength];
                                    %% CalcDis(Track.SmoothX(NetTransSort(max(RevBeforeOmegaI),1)),Track.SmoothY(NetTransSort(max(RevBeforeOmegaI),1)),Track.SmoothX(NetTransSort(max(RevBeforeOmegaI)+1,1)),Track.SmoothY(NetTransSort(max(RevBeforeOmegaI)+1,1)))./pixelWormLength];
                                
                                RevBeforeOmegaI(MaxRBOI) = [];
                            end
                        else
                            if MaxRBOI > 1
                                
                                if (CurrentOmegaTransI(1) - NetTransSort(RevBeforeOmegaI(MaxRBOI),1) < 2*Prefs.FrameRate & CurrentOmegaTransI(1) - NetTransSort(RevBeforeOmegaI(MaxRBOI-1)) < maxRevDurationFrames) | CurrentOmegaTransI(1) - NetTransSort(RevBeforeOmegaI(MaxRBOI),1) > maxRevDurationFrames
                                    Reversals = [Reversals; NetTransSort(max(RevBeforeOmegaI)-1,1),...
                                        NetTransSort(max(RevBeforeOmegaI),2),...
                                        track_path_length_vector(Track, NetTransSort(max(RevBeforeOmegaI)-1,1), NetTransSort(max(RevBeforeOmegaI),1) )./pixelWormLength];
                                        % CalcDis(Track.SmoothX(NetTransSort(max(RevBeforeOmegaI)-1,1)),Track.SmoothY(NetTransSort(max(RevBeforeOmegaI)-1,1)),Track.SmoothX(NetTransSort(max(RevBeforeOmegaI),1)),Track.SmoothY(NetTransSort(max(RevBeforeOmegaI),1)))./pixelWormLength];
                                    RevBeforeOmegaI(MaxRBOI-1:MaxRBOI) = [];
                                    %find longest inter-transition interval
                                    while length(RevBeforeOmegaI) > 2
                                        EndI = RevBeforeOmegaI;
                                        EndI(1) = [];
                                        StartI = RevBeforeOmegaI;
                                        StartI(length(RevBeforeOmegaI)) = [];
                                        LongRunI = find(NetTransSort(EndI,1)-NetTransSort(StartI,1) == max(NetTransSort(EndI,1)-NetTransSort(StartI,1)));
                                        if LongRunI(1) == 1
                                            Reversals = [Reversals; NetTransSort(RevBeforeOmegaI(2),1),...
                                                NetTransSort(RevBeforeOmegaI(3),2)...
                                                track_path_length_vector(Track, NetTransSort(RevBeforeOmegaI(2),1), NetTransSort(RevBeforeOmegaI(3),2) )./pixelWormLength];
                                                %% CalcDis(Track.SmoothX(NetTransSort(RevBeforeOmegaI(2),1)),Track.SmoothY(NetTransSort(RevBeforeOmegaI(2),1)),Track.SmoothX(NetTransSort(RevBeforeOmegaI(3),2)),Track.SmoothY(NetTransSort(RevBeforeOmegaI(3),2)))./pixelWormLength];
                                            RevBeforeOmegaI(1:3) = [];
                                        elseif LongRunI(1) == length(RevBeforeOmegaI)-1
                                            Reversals = [Reversals; NetTransSort(RevBeforeOmegaI(length(RevBeforeOmegaI)-2),1),...
                                                NetTransSort(RevBeforeOmegaI(length(RevBeforeOmegaI)-1),2)...
                                                track_path_length_vector(Track, NetTransSort(RevBeforeOmegaI(length(RevBeforeOmegaI)-2),1), NetTransSort(RevBeforeOmegaI(length(RevBeforeOmegaI)-1),2) )./pixelWormLength];
                                                %% CalcDis(Track.SmoothX(NetTransSort(RevBeforeOmegaI(length(RevBeforeOmegaI)-2),1)),Track.SmoothY(NetTransSort(RevBeforeOmegaI(length(RevBeforeOmegaI)-2),1)),Track.SmoothX(NetTransSort(RevBeforeOmegaI(length(RevBeforeOmegaI)-1),2)),Track.SmoothY(NetTransSort(RevBeforeOmegaI(length(RevBeforeOmegaI)-1),2)))./pixelWormLength];
                                            RevBeforeOmegaI(length(RevBeforeOmegaI)-2:length(RevBeforeOmegaI)) = [];
                                        else
                                            Reversals = [Reversals; NetTransSort(RevBeforeOmegaI(LongRunI(1)-1):2:RevBeforeOmegaI(LongRunI(1)+1),1),...
                                                NetTransSort(RevBeforeOmegaI(LongRunI(1)):2:RevBeforeOmegaI(LongRunI(1)+2),2)...
                                                track_path_length_vector(Track, NetTransSort(RevBeforeOmegaI(LongRunI(1)-1):2:RevBeforeOmegaI(LongRunI(1)+1),1), NetTransSort(RevBeforeOmegaI(LongRunI(1)):2:RevBeforeOmegaI(LongRunI(1)+2),2) )./pixelWormLength];
                                                %% CalcDis(Track.SmoothX(NetTransSort(RevBeforeOmegaI(LongRunI(1)-1):2:RevBeforeOmegaI(LongRunI(1)+1),1)),Track.SmoothY(NetTransSort(RevBeforeOmegaI(LongRunI(1)-1):2:RevBeforeOmegaI(LongRunI(1)+1),1)),Track.SmoothX(NetTransSort(RevBeforeOmegaI(LongRunI(1)):2:RevBeforeOmegaI(LongRunI(1)+2),2)),Track.SmoothY(NetTransSort(RevBeforeOmegaI(LongRunI(1)):2:RevBeforeOmegaI(LongRunI(1)+2),2)))./pixelWormLength];
                                            RevBeforeOmegaI(LongRunI(1)-1:LongRunI(1)+2) = [];
                                        end
                                    end
                                else
                                    Reversals = [Reversals; NetTransSort((RevBeforeOmegaI(1):2:(max(RevBeforeOmegaI)+1)),1),...
                                        NetTransSort(((RevBeforeOmegaI(1)+1):2:(max(RevBeforeOmegaI)+1)),1),...
                                        track_path_length_vector(Track, NetTransSort((RevBeforeOmegaI(1):2:(max(RevBeforeOmegaI)+1)),1), NetTransSort(((RevBeforeOmegaI(1)+1):2:(max(RevBeforeOmegaI)+1)),1) )./pixelWormLength];
                                        %% CalcDis(Track.SmoothX(NetTransSort((RevBeforeOmegaI(1):2:(max(RevBeforeOmegaI)+1)),1)),Track.SmoothY(NetTransSort((RevBeforeOmegaI(1):2:(max(RevBeforeOmegaI)+1)),1)),Track.SmoothX(NetTransSort(((RevBeforeOmegaI(1)+1):2:(max(RevBeforeOmegaI)+1)),1)),Track.SmoothY(NetTransSort(((RevBeforeOmegaI(1)+1):2:(max(RevBeforeOmegaI)+1)),1)))./pixelWormLength];
                                    
                                end
                            else
                                if CurrentOmegaTransI(1) - NetTransSort(RevBeforeOmegaI(MaxRBOI),1) < maxRevDurationFrames
                                    Reversals = [Reversals; NetTransSort((RevBeforeOmegaI(1):2:(max(RevBeforeOmegaI)+1)),1),...
                                        NetTransSort(((RevBeforeOmegaI(1)+1):2:(max(RevBeforeOmegaI)+1)),1),...
                                        track_path_length_vector(Track, NetTransSort((RevBeforeOmegaI(1):2:(max(RevBeforeOmegaI)+1)),1), NetTransSort(((RevBeforeOmegaI(1)+1):2:(max(RevBeforeOmegaI)+1)),1) )./pixelWormLength];
                                        %% CalcDis(Track.SmoothX(NetTransSort((RevBeforeOmegaI(1):2:(max(RevBeforeOmegaI)+1)),1)),Track.SmoothY(NetTransSort((RevBeforeOmegaI(1):2:(max(RevBeforeOmegaI)+1)),1)),Track.SmoothX(NetTransSort(((RevBeforeOmegaI(1)+1):2:(max(RevBeforeOmegaI)+1)),1)),Track.SmoothY(NetTransSort(((RevBeforeOmegaI(1)+1):2:(max(RevBeforeOmegaI)+1)),1)))./pixelWormLength];
                                end
                            end
                            RevBeforeOmegaI = [];
                        end
                        MaxRBOI = length(RevBeforeOmegaI);
                    end
                    
                end
            end
            
        end %end for each Reorientation
        
    end
    
    % bad_transitions are superlong reversals ... delete the initiating
    % angspeed transition spike, and remake the Reversal matrix
    % keep iterating until there are no more bad transitions, or 'till we bail
    clear('bad_transitions');
    bad_transitions=[];
    
    if(~isempty(Reversals))
        bad_transitions = find(Reversals(:,2)-Reversals(:,1)>maxRevDurationFrames);
    end
    
    
    
    if(~isempty(bad_transitions))
        badframe = Reversals(bad_transitions(1),1);
        
        idx = find(RevTransitions(:,1) == badframe);
        RevTransitions(idx,:)=[];
        idx = find(NetTransSort(:,1) == badframe);
        NetTransSort(idx,:)=[];
        
        RevTransitions = sortrows(RevTransitions,1);
        NetTransSort = sortrows(NetTransSort,1);
        
        if(rev_matr_generation_ctr==0)
            max_cycles_rev_matr_gen = 2*length(bad_transitions);
        end
        
        rev_matr_generation_ctr = rev_matr_generation_ctr+1;
    end
    
    
end % end bad_transitions loop


if(~isempty(OmegaTrans))
    OmegaTrans = sortrows(OmegaTrans,1);
    for(j=1:length(OmegaTrans(:,1)))
        OmegaTrans(j,4) = 0; % will be filled by the delta_dir
    end
end
if(~isempty(Reversals))
    Reversals = sortrows(Reversals,1);
    for(j=1:length(Reversals(:,1)))
        Reversals(j,4) = 0; % will be filled by the delta_dir
    end
end


% fuse reversals seperated by a single frame or less
edited_flag=1;
while(edited_flag==1)
    
    edited_flag=0;
    revNum = size(Reversals);
    revNum = revNum(1);
    i=1;
    while(i<revNum)
        if(Reversals(i+1,1) - Reversals(i,2) < 2)
            Reversals(i,2) = Reversals(i+1,2);
            Reversals(i+1,:)=[];
            revNum = size(Reversals);
            revNum = revNum(1);
            edited_flag=1;
        else
            i=i+1;
        end
    end
    
    
    % edit out very long or very short reversals (probably mis-scored or jitters)
    if (~isempty(Reversals))
        s = size(Reversals);
        s1 = s(1);
        i=1;
        while(i<=s1)
            Reversals(i,4) = 0; % set the delta dir to zero for now
            if ( Reversals(i,3) > Prefs.RevLengthLimit ) || ((Reversals(i,2) - Reversals(i,1)) > maxRevDurationFrames) || ...
                    ( Reversals(i,3) < Prefs.SmallReversalThreshold )
                Reversals(i,:) = [];
                s = size(Reversals);
                s1 = s(1);
                edited_flag=1;
            else
                i=i+1;
            end
        end
    end
end

% if the reversal speed dips below Prefs.pauseSpeedThresh, define the
% longest contigious stretch > Prefs.pauseSpeedThresh as the reversal
if (~isempty(Reversals))
    s = size(Reversals);
    s1 = s(1);
    i=1;
    while(i<=s1)
        slow_idx = find(Track.Speed(Reversals(i,1):Reversals(i,2)) <= Prefs.pauseSpeedThresh & ...
            Track.AngSpeed(Reversals(i,1):Reversals(i,2)) < Prefs.AngSpeedThreshold);
        
        if(~isempty(slow_idx))
            fast_idx = find(Track.Speed(Reversals(i,1):Reversals(i,2)) > Prefs.pauseSpeedThresh | ...
                Track.AngSpeed(Reversals(i,1):Reversals(i,2)) >= Prefs.AngSpeedThreshold );
            
            if(isempty(fast_idx))
                Reversals(i,:) = [];
                s = size(Reversals);
                s1 = s(1);
                i=i-1;
            else
                r = Reversals(i,1)-1;
                [start_idx, end_idx] = find_longest_contigious_stretch_in_array(fast_idx);
                Reversals(i,1) = r + fast_idx(start_idx);
                Reversals(i,2) = r + fast_idx(end_idx);
                Reversals(i,3) = track_path_length(Track, Reversals(i,1), Reversals(i,2))/pixelWormLength;
                Reversals(i,4) = 0; % set the delta dir to zero for now
                
                if ( Reversals(i,3) > Prefs.RevLengthLimit ) || ((Reversals(i,2) - Reversals(i,1)) > maxRevDurationFrames) || ...
                        ( Reversals(i,3) < Prefs.SmallReversalThreshold )
                    Reversals(i,:) = [];
                    s = size(Reversals);
                    s1 = s(1);
                    i=i-1;
                end
            end
        end
        i=i+1;
    end
end

% edit OmegaTrans to include neighboring contigious upsilon frames
edited_flag=1;
while(edited_flag==1)
    edited_flag=0;
    OmegaNum = size(OmegaTrans);
    OmegaNum = OmegaNum(1);
    append_flag=0;
    while(append_flag == 0)
        append_flag=1;
        for(i=1:OmegaNum)
            
            %             disp([sprintf('%d %d %f %d %d %d %d %f',  ...
            %                 OmegaTrans(i,1) -1, frame_in_Reversals(Reversals, OmegaTrans(i,1) -1), Track.Eccentricity(OmegaTrans(i,1) -1),...
            %                 OmegaTrans(i,1), OmegaTrans(i,2),...
            %             OmegaTrans(i,2) +1,frame_in_Reversals(Reversals, OmegaTrans(i,2) +1),Track.Eccentricity(OmegaTrans(i,2) +1)  )])
            
            if(OmegaTrans(i,1) > 1)
                if( ( Track.Eccentricity(OmegaTrans(i,1) -1)<=Prefs.UpsilonEccThresh || Track.MajorAxes(OmegaTrans(i,1) -1)/pixelWormLength <= Prefs.OmegaMajorAxesThresh) && frame_in_Reversals(Reversals, OmegaTrans(i,1) -1)==0 )
                    OmegaTrans(i,1) = OmegaTrans(i,1) -1;
                    append_flag=0; edited_flag=1;
                end
            end
            if(OmegaTrans(i,2) < tracklength)
                if( ( Track.Eccentricity(OmegaTrans(i,2) +1)<=Prefs.UpsilonEccThresh || Track.MajorAxes(OmegaTrans(i,2) +1)/pixelWormLength <= Prefs.OmegaMajorAxesThresh) && frame_in_Reversals(Reversals, OmegaTrans(i,2) +1)==0 )
                    OmegaTrans(i,2) = OmegaTrans(i,2) +1;
                    append_flag=0; edited_flag=1;
                end
            end
            
        end
    end
    
    % fuse omegas seperated by a frame or less
    OmegaNum = size(OmegaTrans);
    OmegaNum = OmegaNum(1);
    i=1;
    while(i<OmegaNum)
        if(OmegaTrans(i+1,1) - OmegaTrans(i,2) <= (2))
            OmegaTrans(i,2) = OmegaTrans(i+1,2);
            OmegaTrans(i+1,:)=[];
            OmegaNum = size(OmegaTrans);
            OmegaNum = OmegaNum(1);
            edited_flag=1;
        else
            i=i+1;
        end
    end
end


% edit out very short or long omegas .. some may be picked up as a upsilon
OmegaNum = size(OmegaTrans);
OmegaNum = OmegaNum(1);
i=1;
while(i<=OmegaNum)
    omegalen = OmegaTrans(i,2) - OmegaTrans(i,1);
    if( ( omegalen <= minOmegaDurationFrames ) || ( omegalen > MaxUpsilonOmegaDurationFrames ) )
        OmegaTrans(i,:)=[];
        OmegaNum = size(OmegaTrans);
        OmegaNum = OmegaNum(1);
    else
        i=i+1;
    end
end

% identify non-omega turn frames not in a reversal
upsilon_idx = find(Track.Eccentricity <= Prefs.UpsilonEccThresh);

i=1;
while(i<=length(upsilon_idx))
    if(frame_in_Reversals(Reversals, upsilon_idx(i)) == 1 || frame_in_Reversals(OmegaTrans, upsilon_idx(i)) == 1)
        upsilon_idx(i)=[];
    else
        i=i+1;
    end
end

i=1; j=1;
while(i<=length(upsilon_idx))
    Upsilons(j,1) = upsilon_idx(i);
    Upsilons(j,2) = upsilon_idx(find_end_of_contigious_stretch(upsilon_idx, i));
    Upsilons(j,3) = 0;
    Upsilons(j,4) = 0;
    i = find_end_of_contigious_stretch(upsilon_idx, i)+1;
    j=j+1;
end

% fuse Upsilons seperated by a second or less
UpsilonNum = size(Upsilons);
UpsilonNum = UpsilonNum(1);
i=1;
while(i<UpsilonNum)
    if(Upsilons(i+1,1) - Upsilons(i,2) <= (Prefs.FrameRate))
        Upsilons(i,2) = Upsilons(i+1,2);
        Upsilons(i+1,:)=[];
        UpsilonNum = size(Upsilons);
        UpsilonNum = UpsilonNum(1);
    else
        i=i+1;
    end
end

% edit out very long turns ... these may be paused animals
UpsilonsNum = size(Upsilons);
UpsilonsNum = UpsilonsNum(1);
i=1; 
while(i<=UpsilonsNum)
    Upsilonlen = Upsilons(i,2) - Upsilons(i,1);
    if( Upsilonlen > MaxUpsilonOmegaDurationFrames )
        Upsilons(i,:)=[];
        UpsilonsNum = size(Upsilons);
        UpsilonsNum = UpsilonsNum(1);
    else
        i=i+1;
    end
end

% add eccentricities to Omega and upsilon matricies

if(~isempty(Upsilons))
    for(j=1:length(Upsilons(:,1)))
        Upsilons(j,3) = min(Track.Eccentricity(Upsilons(j,1):Upsilons(j,2)));
        Upsilons(j,4) = 0; % will be filled by the delta_dir
    end
else
    clear('Upsilons');
    Upsilons = [];
end

if(~isempty(OmegaTrans))
    for(j=1:length(OmegaTrans(:,1)))
        OmegaTrans(j,3) = min(Track.Eccentricity(OmegaTrans(j,1):OmegaTrans(j,2)));
        OmegaTrans(j,4) = 0; % will be filled by the delta_dir
    end
else
    clear('OmegaTrans');
    OmegaTrans=[];
end

if(isempty(Reversals))
    clear('Reversals');
    Reversals=[];
end

return;
end


function yes_or_no = frame_in_Reversals(Reversals, frame)

yes_or_no = 0;

if(isempty(Reversals))
    return;
end

for(i=1:length(Reversals(:,1)))
    if(Reversals(i,1) <= frame && frame <= Reversals(i,2))
        yes_or_no=1;
        return;
    end
end

return;
end

