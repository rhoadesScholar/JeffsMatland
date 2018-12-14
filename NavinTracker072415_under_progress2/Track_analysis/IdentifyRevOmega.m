function outTrack = IdentifyRevOmega(Track)
% outTrack = IdentifyRevOmega(Track)

global Prefs;

Reversals=[]; OmegaTrans=[]; Reorientations=[]; Upsilons=[];

track_length = length(Track.Frames);

RevOmegaFrameGap = Prefs.RevOmegaMaxGap*Prefs.FrameRate;
direction_avging_frames = 1*Prefs.FrameRate;

%define and find omega bends and reversals
TransI = find(abs(Track.AngSpeed) > Prefs.AngSpeedThreshold);
% TransI = TransI(find(TransI > 1 & TransI < length(Track.Frames) - 1)); % Disregard first and last frame of movie

% no reversals or omegas
if(isempty(TransI))
    Track.Reorientations = Reorientations;
    outTrack = Track;
    return;
end

EccenI = find(Track.Eccentricity <= Prefs.OmegaEccThresh ); % | Track.MajorAxes*Track.PixelSize/Track.Wormlength <= Prefs.OmegaMajorAxesThresh);

if isempty(EccenI)
    OmegaTrans = [];
else
    % find angspeed>Prefs.AngSpeedThreshold AND ecc>Prefs.OmegaEccThresh
    [OmegaTransI,iTrans,iEccen] = intersect(TransI',EccenI','rows');

    if isempty(OmegaTransI)
        OmegaTrans = [];
    else
        %minimum time between two omega transition events
        OmegaTransEndI = find(diff(OmegaTransI)>Prefs.MinOmegaDuration*Prefs.FrameRate);

        if isempty(OmegaTransEndI)
            OmegaTrans = [OmegaTransI(1), OmegaTransI(length(OmegaTransI))];
        else
            OmegaTrans = [OmegaTransI(1), OmegaTransI(OmegaTransEndI(1))];

            for j = 1:length(OmegaTransEndI)-1
                OmegaTrans = [OmegaTrans; OmegaTransI(OmegaTransEndI(j)+1), OmegaTransI(OmegaTransEndI(j+1))];
            end
            OmegaTrans = [OmegaTrans; OmegaTransI(OmegaTransEndI(length(OmegaTransEndI))+1), OmegaTransI(length(OmegaTransI))];
        end
    end

    % get rid of single frame omegas
    if(~isempty(OmegaTrans))
        i=1;
        while(i<=length(OmegaTrans(:,1)))
            if(OmegaTrans(i,1) - OmegaTrans(i,2) == 0)
                OmegaTrans(i,:)=[];
            else
                i=i+1;
            end
        end
    end
end

%find potential change in direction associated with reversals
RevTransI = find(abs(Track.AngSpeed) > Prefs.RevAngSpeedThreshold);
PosRevTransI = find(Track.AngSpeed > Prefs.RevAngSpeedThreshold);
NegRevTransI = find(Track.AngSpeed < -Prefs.RevAngSpeedThreshold);

[OmegaTrans, Reversals, Upsilons] = create_rev_omega_turn_matricies(Track, OmegaTrans, Reversals, Upsilons, RevTransI, PosRevTransI, NegRevTransI);

% add turning angle and/or eccentricity to reversals and OmegaTrans
% create Reorientations object
reori=0;

OmegaNum = size(OmegaTrans);
OmegaNum = OmegaNum(1);
i=1;
while(i<=OmegaNum)
    start_frame = OmegaTrans(i,1);
    omega_end = OmegaTrans(i,2);

    rev_index=[];
    if ~isempty(Reversals)
        rev_index = max(find(start_frame - Reversals(:,2)  <=  RevOmegaFrameGap & Reversals(:,2) <= start_frame));
        if(~isempty(rev_index))
            start_frame = Reversals(rev_index,1);
        end
    end

    [dir_before, dir_after, OmegaTrans(i,4)] = reorientation_bearing(Track, start_frame, omega_end, OmegaTrans, Reversals, Upsilons);
    
    real_omega_flag=1;
    if(isempty(rev_index))
        turn_delta_dir = OmegaTrans(i,4);
        if(abs(OmegaTrans(i,4)) < Prefs.MinDeltaHeadingOmega)
            real_omega_flag = 0;
        end
    else
        [revdir_before, omegadir_after, delta_theta] = reorientation_bearing(Track, OmegaTrans(i,1), OmegaTrans(i,2), OmegaTrans, Reversals, Upsilons);
        revdir_before = corrected_bearing( mean_direction(Track.Direction(Reversals(rev_index,1):Reversals(rev_index,2))) + 180); % opposite direction of reversal
        
        turn_delta_dir = delta_direction(revdir_before, omegadir_after);
        
        if(abs(turn_delta_dir) < Prefs.MinDeltaHeadingRevOmega)
            real_omega_flag = 0;
        end
    end

    if(real_omega_flag==0)
        % convert to Upsilon
        Upsilons = [Upsilons; OmegaTrans(i,:) ];
        Upsilons = sortrows(Upsilons,1);
        
        OmegaTrans(i,:)=[];
        OmegaNum = size(OmegaTrans);
        OmegaNum = OmegaNum(1);
    else
        reori = reori+1;

        Reorientations(reori).start = OmegaTrans(i,1);
        Reorientations(reori).startRev = NaN;
        Reorientations(reori).startTurn = OmegaTrans(i,1);
        Reorientations(reori).end = OmegaTrans(i,2);
        Reorientations(reori).revLen = NaN;
        Reorientations(reori).revLenBodyBends = NaN;
        Reorientations(reori).ecc = OmegaTrans(i,3);
        Reorientations(reori).dir_before = dir_before;
        Reorientations(reori).dir_after = dir_after;
        Reorientations(reori).delta_dir = OmegaTrans(i,4);
        Reorientations(reori).turn_delta_dir = turn_delta_dir;
        Reorientations(reori).class = 'pure_omega';

        if(~isempty(rev_index)) % this is a reveral/omega
            Reversals(rev_index,4) = 0; % marks this reversal as being in use

            Reorientations(reori).startRev = Reversals(rev_index,1);
            Reorientations(reori).revLen = Reversals(rev_index,3);
            Reorientations(reori).revLenBodyBends = NaN; % fill in later

            if(Reorientations(reori).revLen >= Prefs.LargeReversalThreshold)
                Reorientations(reori).class = 'lRevOmega';
            else
                Reorientations(reori).class = 'sRevOmega';
            end
            
            Reversals(rev_index,:)=[];
        end
        i=i+1;
    end
end

% put non-omega Turns into the Reorientation structure

UpsilonNum = size(Upsilons);
UpsilonNum = UpsilonNum(1);
i=1;
while(i<=UpsilonNum)
    start_frame = Upsilons(i,1);
    turn_end = Upsilons(i,2);

    rev_index=[];
    if ~isempty(Reversals)
        rev_index = max(find(start_frame - Reversals(:,2)  <=  RevOmegaFrameGap & Reversals(:,2) <= start_frame));
        if(~isempty(rev_index))
            start_frame = Reversals(rev_index,1);
        end
    end

    [dir_before, dir_after, Upsilons(i,4)] = reorientation_bearing(Track, start_frame, turn_end, OmegaTrans, Reversals, Upsilons);


    real_turn_flag=1;
    if(isempty(rev_index))
        turn_delta_dir = Upsilons(i,4);
        if(abs(Upsilons(i,4)) < Prefs.MinDeltaHeadingUpsilon)
            real_turn_flag = 0;
        end
    else
        [revdir_before, turndir_after, delta_theta] = reorientation_bearing(Track, Upsilons(i,1), Upsilons(i,2), OmegaTrans, Reversals, Upsilons);
        revdir_before = corrected_bearing( mean_direction(Track.Direction(Reversals(rev_index,1):Reversals(rev_index,2))) + 180); % opposite direction of reversal

        turn_delta_dir = delta_direction(revdir_before, turndir_after);

        if(abs(turn_delta_dir) < Prefs.MinDeltaHeadingRevUpsilon)
            real_turn_flag = 0;
        end
    end
    
    
    if(real_turn_flag==0)
        Upsilons(i,:)=[];
        UpsilonNum = size(Upsilons);
        UpsilonNum = UpsilonNum(1);
    else
        reori = reori+1;

        Reorientations(reori).start = Upsilons(i,1);
        Reorientations(reori).startRev = NaN;
        Reorientations(reori).startTurn = Upsilons(i,1);
        Reorientations(reori).end = Upsilons(i,2);
        Reorientations(reori).revLen = NaN;
        Reorientations(reori).revLenBodyBends = NaN;
        Reorientations(reori).ecc = Upsilons(i,3);
        Reorientations(reori).dir_before = dir_before;
        Reorientations(reori).dir_after = dir_after;
        Reorientations(reori).delta_dir = Upsilons(i,4);
        Reorientations(reori).turn_delta_dir = turn_delta_dir;
        Reorientations(reori).class = 'pure_Upsilon';

        if(~isempty(rev_index)) % this is a reveral/turn
            Reversals(rev_index,4) = 0; % marks this reversal as being in use

            Reorientations(reori).startRev = Reversals(rev_index,1);
            Reorientations(reori).revLen = Reversals(rev_index,3);
            Reorientations(reori).revLenBodyBends = NaN;

            if(Reorientations(reori).revLen >= Prefs.LargeReversalThreshold)
                Reorientations(reori).class = 'lRevUpsilon';
            else
                Reorientations(reori).class = 'sRevUpsilon';
            end
            
            Reversals(rev_index,:)=[]; 
        end
        i=i+1;
    end
end

% calc delta-direction for omega-less and turn-less reversals
if ~isempty(Reversals)

    i=1;
    while(i<=length(Reversals(:,1)))
        if(Reversals(i,4)==0)  % if not zero, already included as a revOmega or revUpsilon in Reorientations

            start_frame = Reversals(i,1);
            rev_end = Reversals(i,2);

            [dir_before, dir_after, Reversals(i,4)] = reorientation_bearing(Track, start_frame, rev_end, OmegaTrans, Reversals, Upsilons);
            
            reori = reori+1;
            
            Reorientations(reori).start = Reversals(i,1);
            Reorientations(reori).startRev = Reversals(i,1);
            Reorientations(reori).startTurn = NaN;
            Reorientations(reori).end = Reversals(i,2);
            Reorientations(reori).revLen = Reversals(i,3);
            Reorientations(reori).revLenBodyBends = NaN; % fill in later
            Reorientations(reori).ecc = NaN;
            Reorientations(reori).dir_before = dir_before;
            Reorientations(reori).dir_after = dir_after;
            Reorientations(reori).delta_dir = Reversals(i,4);
            Reorientations(reori).turn_delta_dir = NaN;
            if(Reorientations(reori).revLen >= Prefs.LargeReversalThreshold)
                Reorientations(reori).class = 'pure_lRev';
            else
                Reorientations(reori).class = 'pure_sRev';
            end

        end
        i=i+1;
    end
end

% sort Reorientations and put values for Reorientations.start
if(~isempty(Reorientations))

    start_reori=[];
    for(i=1:length(Reorientations))
        Reorientations(i).start = Reorientations(i).startRev;
        if(isnan(Reorientations(i).start))
            Reorientations(i).start = Reorientations(i).startTurn;
        end
        Reorientations(i).mean_angspeed = Reorientations(i).delta_dir/( (Reorientations(i).end-Reorientations(i).start+1)/Prefs.FrameRate );
        start_reori = [start_reori, Reorientations(i).start];
        
        Reorientations(i).revSpeed = NaN;
        
        % revSpeed
        if(~isnan(Reorientations(i).startRev))
            endframe = Reorientations(i).end;
            if(~isnan(Reorientations(i).startTurn))
                endframe = Reorientations(i).startTurn-1;
            end
            
            Reorientations(i).revSpeed = (nanmean(Track.Speed(Reorientations(i).startRev:endframe)) + nanmedian(Track.Speed(Reorientations(i).startRev:endframe)))/2;
            
        end
    end

    [s, idx] = sort(start_reori);
    clear('s');
    Reorientations = Reorientations(idx);
    clear('idx');
    clear('start_reori');
end

Track.Reorientations = Reorientations;

outTrack = Track;

return;

end

function [dir_before, dir_after, delta_dir] = reorientation_bearing(Track, start_frame, end_frame, OmegaTrans, Reversals, Upsilons)

    dir_before = NaN;
    dir_after = NaN;
    delta_dir = NaN;
    
    track_length = length(Track.Frames);

    [a,b] = find_reorientation_flanking_segments(start_frame, end_frame, track_length, OmegaTrans, Reversals, Upsilons);

    if(~isnan(a))
        dir_before = mean_direction(Track.Direction(a:start_frame-1));
    end
    
    if(~isnan(b))
        dir_after = mean_direction(Track.Direction(end_frame+1:b));
    end
    
    if(~isnan(dir_before) && isnan(dir_after))
        dir_after = Track.Direction(end_frame);
    else
        if(isnan(dir_before) && ~isnan(dir_after))
            dir_before = Track.Direction(start_frame);
        else
            if(isnan(dir_before) && isnan(dir_after))
                dir_before = Track.Direction(start_frame);
                dir_after = Track.Direction(end_frame);
            end
        end
    end
       
    delta_dir = delta_direction(dir_before, dir_after);

return;
end

function [a,b] = find_reorientation_flanking_segments(start_frame, end_frame, track_length, OmegaTrans, Reversals, Upsilons)
% 2 sec of fwd prior to and following the reorientation of interest

global Prefs;
direction_avging_frames = 2*Prefs.FrameRate;

numRev=0;
if ~isempty(Reversals)
    numRev = length(Reversals(:,1));
end

numOm=0;
if ~isempty(OmegaTrans)
    numOm = length(OmegaTrans(:,1));
end

UpsilonNum=0;
if ~isempty(Upsilons)
    UpsilonNum = length(Upsilons(:,1));
end

if(start_frame == 1)
    a=NaN;
else
    a = start_frame - direction_avging_frames;
    if(a<1)
        a = 1;
    end
    done_flag=0;
    while(done_flag==0)
        done_flag=1;
        q=1;
        flag=0;
        if(numOm>0)
            while(flag==0)
                if((OmegaTrans(q,1) <= a) && (a <= OmegaTrans(q,2)))
                    a = OmegaTrans(q,2)+1;
                    done_flag=0;
                else
                    q=q+1;
                end
                if(q>=numOm)
                    flag=1;
                end
            end
        end
        q=1;
        flag=0;
        if(UpsilonNum>0)
            while(flag==0)
                if((Upsilons(q,1) <= a) && (a <= Upsilons(q,2)))
                    a = Upsilons(q,2)+1;
                    done_flag=0;
                else
                    q=q+1;
                end
                if(q>=UpsilonNum)
                    flag=1;
                end
            end
        end
        q=1;
        flag=0;
        if(numRev>0)
            while(flag==0)
                if((Reversals(q,1) <= a) && (a <= Reversals(q,2)))
                    a = Reversals(q,2)+1;
                    done_flag=0;
                else
                    q=q+1;
                end
                if(q>=numRev)
                    flag=1;
                end
            end
        end
    end
end

if(end_frame == track_length)
    b=track_length;
else
    b = end_frame + direction_avging_frames;
    if(b > track_length)
        b = track_length;
    end
    done_flag=0;
    while(done_flag==0)
        done_flag=1;
        q=numOm;
        flag=0;
        if(q==0)
            flag=1;
        end
        while(flag==0)
            if((OmegaTrans(q,1) <= b) && (b <= OmegaTrans(q,2)))
                b = OmegaTrans(q,1)-1;
                done_flag=0;
            else
                q=q-1;
            end
            if(q<=1)
                flag=1;
            end
        end
        q=UpsilonNum;
        flag=0;
        if(q==0)
            flag=1;
        end
        while(flag==0)
            if((Upsilons(q,1) <= b) && (b <= Upsilons(q,2)))
                b = Upsilons(q,1)-1;
                done_flag=0;
            else
                q=q-1;
            end
            if(q<=1)
                flag=1;
            end
        end
        q=numRev;
        flag=0;
        if(q==0)
            flag=1;
        end
        while(flag==0)
            if((Reversals(q,1) <= b) && (b <= Reversals(q,2)))
                b = Reversals(q,1)-1;
                done_flag=0;
            else
                q=q-1;
            end
            if(q<=1)
                flag=1;
            end
        end
    end
end

return;
end


function debug_viewer(Reversals, OmegaTrans, dir_before,dir_after, start_frame, end_frame, a, b, Track, theta)

disp([sprintf('%f\t%f\t%f\t\t%d\t%d\t%d\t%d\t%s',dir_before,dir_after,theta,a,start_frame-1,end_frame+1,b,char(Track.scoredState) )])
close all;
figure(2);
plot(Track.SmoothX(a),Track.SmoothY(a),'o'); hold on; Rx = Track.SmoothX(a) - Track.SmoothX(end_frame+1); Ry = Track.SmoothY(a) - Track.SmoothY(end_frame+1);
plot(Track.SmoothX(end_frame+1),Track.SmoothY(end_frame+1),'or'); hold on;
plot(Track.SmoothX(start_frame:end_frame),Track.SmoothY(start_frame:end_frame),'.g');
plot(Track.SmoothX(a:start_frame-1),Track.SmoothY(a:start_frame-1)); hold on; plot(Track.SmoothX(end_frame+1:b) + Rx,Track.SmoothY(end_frame+1:b) + Ry,'color',[0.7 0.7 0.7]);
plot(Track.SmoothX(end_frame+1:b),Track.SmoothY(end_frame+1:b),'r');
axis ij;
axis equal;
Reversals
OmegaTrans
view_tracks(Track);
return;
end

