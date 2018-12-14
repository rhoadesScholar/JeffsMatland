% the curvature in this function is defined as described by
% Iino and Yoshida J Neurosci 29:5370 (2009)

% For point P on the track:
% A'->A'' linearization centered at A
% B''->B' linearization centered at B
% A->P->B = Prefs.curvStep mm
%
% B'<-B<-B''<-P<-A''<-A<-A'
%
%
%

function curvature_array = track_curvature(Track)

global Prefs;

% curvature_array = straightness(Track.SmoothX, Track.SmoothY); return;


linearization_window = 0.3/Track.PixelSize; % +/- window for linearization around A and B 0.6mm
tol = 0.25/Track.PixelSize; % if we are within 0.25mm of a desired segment-length, keep it

curvature_array(1:Track.NumFrames)=NaN; % default value;

dR = Prefs.curvStep/Track.PixelSize;  % convert from mm to pixels

half_dR = dR/2; % distance from P to A or B

prime_dist =  half_dR + linearization_window;
two_prime_dist = 2*prime_dist;

prime_prime_dist = half_dR - linearization_window;

deg_per_rad = (360/(2*pi));

tracklength = length(Track.SmoothX);

% do not include reversal frames when calculating path curvature
srev_idx = find(floor(Track.State) == num_state_convert('sRev'));
lrev_idx = find(floor(Track.State) == num_state_convert('lRev'));
Track.SmoothX([srev_idx lrev_idx]) = NaN;
Track.SmoothY([srev_idx lrev_idx]) = NaN;

P=2;
while(P < tracklength)
    
    phi = NaN;
    d = NaN;
    
    Aprime = 0; Bprime=0; Aprimeprime=0; Bprimeprime=0;
    
    [A, P_A] = find_point_q_within_target_d_of_p(Track.SmoothX, Track.SmoothY,  P, -half_dR);
    [B, P_B] = find_point_q_within_target_d_of_p(Track.SmoothX, Track.SmoothY,  P, half_dR);
    
    if(A~=0 && B~=0)
        d = (P_A + P_B)*Track.PixelSize; % convert to mm
        phi = delta_direction( Track.Direction(A), Track.Direction(B));
    end
    
    
    [Aprime, P_Aprime] = find_point_q_within_target_d_of_p(Track.SmoothX, Track.SmoothY,  P, -prime_dist);
    if(Aprime~=0)
        [Bprime, P_Bprime] = find_point_q_within_target_d_of_p(Track.SmoothX, Track.SmoothY,  P, prime_dist);
        if(Bprime~=0)
            if(abs(P_Aprime + P_Bprime - two_prime_dist) <= tol)
                [Aprimeprime, P_Aprimeprime] = find_point_q_within_target_d_of_p(Track.SmoothX, Track.SmoothY,  P, -prime_prime_dist);
                [Bprimeprime, P_Bprimeprime] = find_point_q_within_target_d_of_p(Track.SmoothX, Track.SmoothY,  P, prime_prime_dist);
                
                if(Bprime>B && B>Bprimeprime && Bprimeprime > P && P > Aprimeprime && Aprimeprime>A && A > Aprime)
                    phi = delta_direction(mean_direction(Track.Direction(Aprime:Aprimeprime)), mean_direction(Track.Direction(Bprimeprime:Bprime)));
                end
            end
        end
    end
    
    if(~isnan(phi))
        curvature_array(P) = phi/d;
    end
    
    P=P+1;
end

return;
end



% faster alternative using already calc'd Tracks.Direction values
% P=2;
% while(P < tracklength)
%     [A, P_A] = find_point_q_within_target_d_of_p(Track.SmoothX, Track.SmoothY,  P, -half_dR);
%     [B, P_B] = find_point_q_within_target_d_of_p(Track.SmoothX, Track.SmoothY,  P, half_dR);
%
%     if(A>0 && B>0)
%         if(P>A && B>P)
%             d = (P_A + P_B)*Track.PixelSize; % convert to mm
%
%             a_start = A-Prefs.FrameRate;
%             if(a_start<1)
%                 a_start=1;
%             end
%             a_end = A+Prefs.FrameRate;
%             if(a_end>tracklength)
%                 a_end=tracklength;
%             end
%
%             b_start = B-Prefs.FrameRate;
%             if(b_start<1)
%                 b_start=1;
%             end
%             b_end = B+Prefs.FrameRate;
%             if(b_end>tracklength)
%                 b_end=tracklength;
%             end
%
%             phi = GetAngleDif(nanmean(Track.Direction(a_start:a_end)), nanmean(Track.Direction(b_start:b_end)));
%             curvature_array(P) = phi/d;
%         end
%     end
%
%     P=P+1;
% end
% return;


%                         x = Track.SmoothX(Aprime:Aprimeprime);
%                         y = Track.SmoothY(Aprime:Aprimeprime);
%                         linA = polyfit(x,y,1);
%                         clear('x');
%                         clear('y');
%
%                         x = Track.SmoothX(Bprimeprime:Bprime);
%                         y = Track.SmoothY(Bprimeprime:Bprime);
%                         linB = polyfit(x,y,1);
%                         clear('x');
%                         clear('y');
%
%                         phi = deg_per_rad*(atan((linA(1)-linB(1))/(1+linA(1)*linB(1)))); % interior angle between two lines




% function dsqrd = distance_sqrd(x1, y1, x2, y2)
% dsqrd =  ((x2-x1)^2 + (y2-y1)^2);
% return;
% end


function [q_index, d] = find_point_q_within_target_d_of_p(x, y, p_index, target_d)

d=0;
step=1;
d_goal_sqrd = target_d^2;
if(target_d<0)
    step=-1;
end

tracklength = length(x);

q_index = p_index + step;
if(q_index <= 0 || q_index >tracklength)
    q_index = 0;
    return;
end

dsqrd = (x(p_index)-x(q_index))^2 + (y(p_index)-y(q_index))^2;   % distance_sqrd(x(p_index),y(p_index),x(q_index),y(q_index));

while(dsqrd < d_goal_sqrd)
    dsqrd = dsqrd + (x(p_index)-x(q_index))^2 + (y(p_index)-y(q_index))^2; % distance_sqrd(x(p_index),y(p_index),x(q_index),y(q_index));
    q_index = q_index + step;
    
    if(q_index <= 0 || q_index >tracklength)
        q_index = 0;
        return;
    end
end

d = sqrt(dsqrd);

if(isnan(d))
    q_index = 0;
end

return;
end
