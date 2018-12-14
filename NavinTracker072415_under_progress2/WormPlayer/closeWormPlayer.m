function closeWormPlayer(hcb, eventStruct)
hfig=gcbf;
movieData = get(hfig,'userdata');
% if ~isempty(movieData)
%     stop(movieData.htimer); % Shut off timer if running
% end

% if ( exist(movieData.Movie, 'file') )
%     disp(sprintf('Deleting local tempfile %s %s\t%s', movieData.Movie, timeString()));
%     delete(movieData.Movie);
% end

% stop(movieData.movieTimer);
delete(movieData.movieTimer);
aviread_to_gray('rm_temp');

delete(hfig);    % Close window
end