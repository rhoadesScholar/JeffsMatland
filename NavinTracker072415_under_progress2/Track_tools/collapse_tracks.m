function outTracks = collapse_tracks(Tracks, join_flag)

global Prefs;
OPrefs = Prefs;

Prefs.aggressive_linking=2;
outTracks = link_tracks(sort_tracks_by_startframe(Tracks), 0, 0, 0, 'missing');

Prefs = OPrefs;

return;
% 
% if(isempty(Tracks))
%     outTracks=[];
%     return;
% end
% if(nargin<2)
%     join_flag='missing';
% end
% 
% Tracks = sort_tracks_by_startframe(Tracks);
% 
% global Prefs;
% maxTracks = 1000;
% 
% persistent num_track_frags;
% persistent num_recursion_rounds;
% 
% if(isempty(num_recursion_rounds))
%     disp([sprintf('Collapsing tracks\t%s',timeString())])
%     
%     % Tracks = break_up_track_gaps(Tracks); % collapsing better w/o gaps in tracks
%     
% end
% 
% firstframe = min_struct_array(Tracks,'Frames');
% lastframe = max_struct_array(Tracks,'Frames');
% inTracks = sort_tracks_by_starttime(Tracks);
% NumTracks = length(inTracks);
% 
% % for large number of tracks
% if(NumTracks > maxTracks)
%     
%     
%     if(isempty(num_recursion_rounds))
%         disp([sprintf('start recursion to collapse %d tracks\t%s', NumTracks,timeString())])
%     end
%     
%     if(isempty(num_recursion_rounds))
%         num_recursion_rounds = 0;
%     end
%     
%     
%     n = ceil(NumTracks/maxTracks);
%     outTracks=[];
%     start_track=1;
%     end_track=maxTracks;
%     j=1;
%     for(i=1:n)
%         k=1;
%         while(j<=end_track)
%             temp_track(k) = inTracks(j);
%             k=k+1;
%             j=j+1;
%         end
%         temp_outTrack = collapse_tracks(temp_track);
%         outTracks = [outTracks temp_outTrack];
%         clear('temp_track');
%         clear('temp_outTrack');
%         start_track = start_track+maxTracks;
%         end_track = end_track+maxTracks;
%         if(end_track>NumTracks)
%             end_track=NumTracks;
%         end
%     end
%     inTracks = outTracks;
%     clear('outTracks');
%     num_recursion_rounds = num_recursion_rounds+1;
%     
%     
%     disp([sprintf('recursion round %d resulted in %d collapsed tracks\t%s',num_recursion_rounds, length(inTracks),timeString())]);
%     
%     
%     if(~isempty(num_track_frags))
%         if(length(inTracks) == num_track_frags)
%             
%             outTracks = inTracks;
%             outTracks = sort_tracks_by_length(outTracks);
%             
%             disp([sprintf('recursion created %d collapsed tracks\t%s',length(outTracks),timeString())])
%             clear('num_recursion_rounds');
%             clear('num_track_frags');
%             return;
%         end
%     end
%     
%     num_track_frags = length(inTracks);
%     outTracks = collapse_tracks(inTracks);
%     outTracks = sort_tracks_by_length(outTracks);
%     
%     disp([sprintf('recursion created %d collapsed tracks\t%s',length(outTracks),timeString())])
%     clear('num_recursion_rounds');
%     clear('num_track_frags');
%     return;
%     
% end
% 
% if(isempty(num_recursion_rounds))
%     tic
% end
% 
% 
% collapsed_flag=1;
% rnd=1;
% while(collapsed_flag == 1)
%     collapsed_flag=0;
%     
%     num_full_tracks = 0;
%     i=1;
%     while(i<=length(inTracks) ) % && num_full_tracks<=Prefs.MaxNumEthogramTracks)
%         
%         
%         missing_frames=[];
%         
%         
%         if(inTracks(i).Frames(1) > firstframe+Prefs.MinTrackLengthFrames || inTracks(i).Frames(end) < lastframe-Prefs.MinTrackLengthFrames)
%             missing_frames=1;
%         end
%         
%         % for track i, find track j whose start/end is seperated from the end/start of track i by the fewest number of
%         % frames bestgap
%         if(~isempty(missing_frames))
%             j_best=0;
%             bestgap = lastframe;
%             j=1;
%             while(j<=length(inTracks))
%                 if(j~=i)
%                     
%                     gap=1e6;
%                     if(inTracks(j).Frames(end) < inTracks(i).Frames(1))
%                         gap = inTracks(i).Frames(1) - inTracks(j).Frames(end);
%                     else if(inTracks(j).Frames(1) > inTracks(i).Frames(end))
%                             gap =  inTracks(j).Frames(1) - inTracks(i).Frames(end);
%                         end
%                     end
%                     if(gap < bestgap)
%                         j_best = j;
%                         bestgap = gap;
%                     end
%                     
%                     
%                 end
%                 j=j+1;
%             end
%             
%             % append i and j to i, delete j
%             if(j_best>0)
%                 inTracks(i) = append_track(inTracks(i), inTracks(j_best), join_flag);
%                 inTracks(j_best)=[];
%                 collapsed_flag=1;
%             end
%         else
%             num_full_tracks = num_full_tracks+1;
%         end
%         
%         % disp([sprintf('%d\t%d\t%d\t%d\t%s',rnd,i,num_full_tracks,length(inTracks),timeString())])
%         
%         i=i+1;
%     end
%     rnd=rnd+1;
% end
% 
% outTracks = sort_tracks_by_starttime(inTracks);
% 
% if(isempty(num_recursion_rounds))
%     toc
% end
% return;

end
