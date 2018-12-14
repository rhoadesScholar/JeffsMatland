% mvt initiation stored in vector of mostly zeros
% non-zero value is the num_state_convert code for that movement.
% For composite motions (lRevOmega for example), the entire motion and the
% reversal are coded at the start frame. The omega/turn is also coded, but
% with the reversed number lRev = 4, Omega = 7, lRevOmega (and the reversal) =4.7, omega
% component coded with 7.4. 
% A pure motion is coded as x.1 . For example, an omega not joined to a
% reversal would be 7.1

function mvt_init = mvt_init_vector(Track)

epsilon=1e-4;

pause_code = num_state_convert('pause');
fwd_code = num_state_convert('fwd');

mvt_init = zeros(1,length(Track.Frames));

% rev, omega, turn initiations
for(k=1:length(Track.Reorientations))
    if(isempty(regexpi(Track.Reorientations(k).class,'ring')==0))

        % pure rev
        if(~isnan(Track.Reorientations(k).startRev) && isnan(Track.Reorientations(k).startTurn))
            mvt_init(Track.Reorientations(k).startRev) = num_state_convert(Track.Reorientations(k).class);
        else
            % pure turn/omega 
            if(isnan(Track.Reorientations(k).startRev) && ~isnan(Track.Reorientations(k).startTurn))
                mvt_init(Track.Reorientations(k).startTurn) = num_state_convert(Track.Reorientations(k).class);
            else % rev omeg/turn
                mvt_init(Track.Reorientations(k).start) = num_state_convert(Track.Reorientations(k).class);
                mvt_init(Track.Reorientations(k).startTurn) = num_state_convert([Track.Reorientations(k).class(5:end)  Track.Reorientations(k).class(1:4)] );
                
            end
        end

    end
end

% pause, depause initiations
i=1;
while(i<=length(Track.State))
   if(abs(Track.State(i) - pause_code)<=epsilon)
       mvt_init(i) = pause_code;
       while(abs(Track.State(i) - pause_code)<=epsilon)
           i=i+1;
           if(i>=length(Track.State))
               i = length(Track.State);
               break;
           end
       end
       if(abs(Track.State(i) - fwd_code)<=epsilon)
           mvt_init(i) = fwd_code;
       end
   end
   i=i+1;
end

% mvt_init = make_single(mvt_init);

return;
end
