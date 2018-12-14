function linkedTracks = manual_track_linkage(linkedTracks, max_interframe_time)
% manualTracks = manual_track_linkage(linkedTracks, max_interframe_time)

if(nargin<1)
    disp('usage: manualTracks = manual_track_linkage(linkedTracks, [max_interframe_time]), max_interframe_time default 10 sec')
    return;
end

border_thickness = 50;

global Prefs;

OPrefs = Prefs;

Prefs = [];
Prefs = define_preferences(Prefs);
Prefs.PixelSize = linkedTracks(1).PixelSize;
Prefs = CalcPixelSizeDependencies(Prefs, Prefs.PixelSize);

link_flag=1;

% inputMovieName does not exist ... 
% perhaps the wrong path is given  
% see if the file exists in the current directory
if(~file_existence(linkedTracks(1).Name))
    [pathstr, pref, ext] = fileparts(linkedTracks(1).Name);
    inputMovieName = sprintf('%s%s',pref,ext);
    if(~file_existence(inputMovieName))
        error(sprintf('Cannot find %s in the current directory',inputMovieName));
    end
    disp([sprintf('Could not find %s in directory %s\nbut found it in the current directory %s',inputMovieName,pathstr,pwd)])

    for(i=1:length(linkedTracks))
       linkedTracks(i).Name =  inputMovieName;
    end
end

if(nargin < 2)
    max_interframe_time = Prefs.MaxTrackLinkSeconds;
end

max_delta_frames = max_interframe_time*linkedTracks(1).FrameRate;
min_delta_frames = -max_interframe_time*linkedTracks(1).FrameRate/2;
max_dr = Prefs.MaxCentroidShift_mm_per_sec*max_interframe_time;


FileInfo = moviefile_info(linkedTracks(1).Name);
aviread_to_gray;

while(link_flag==1)
    link_flag = 0;
    i=1;
    while(i<=length(linkedTracks))
        
        % linkedTracks = sort_tracks_by_length(linkedTracks);
        
        idx = max(1,(length(linkedTracks(i).Frames)-5*linkedTracks(i).FrameRate)):length(linkedTracks(i).Frames);
        x_i = linkedTracks(i).SmoothX(idx);
        y_i = linkedTracks(i).SmoothY(idx);
        
        allowed_j = []; x= []; y= []; start_idx = [];
        i_endframe = linkedTracks(i).Frames(end);
        for(j=1:length(linkedTracks))
            if(j~=i)
                j_startframe = linkedTracks(j).Frames(1);
                delta_frames = j_startframe - i_endframe;
                
                
                dr = linkedTracks(j).PixelSize*sqrt( ( linkedTracks(i).SmoothX(end) - linkedTracks(j).SmoothX(1) )^2 + ...
                    ( linkedTracks(i).SmoothY(end) - linkedTracks(j).SmoothY(1) )^2 );
                
                if(delta_frames <= max_delta_frames && ...
                        delta_frames > min_delta_frames  && ...
                        dr <= max_dr)
                    
                    idx = 1:min(5*Prefs.MaxTrackLinkSeconds*linkedTracks(i).FrameRate, length(linkedTracks(j).Frames));
                    
                    start_idx = [start_idx (length(x)+1)];
                    x = [x linkedTracks(j).SmoothX(idx) NaN];
                    y = [y linkedTracks(j).SmoothY(idx) NaN];
                    
                    allowed_j = [allowed_j j];
                end
                
            end
        end
         
        if(~isempty(allowed_j))
            
            Mov = aviread_to_gray(linkedTracks(i).Name, linkedTracks(i).Frames(end));
            figure(100);
            imshow(Mov.cdata); hold on;
            
            plot(x_i,y_i,'r');
            text('position',[x_i(end) y_i(end)],'String',sprintf('%d',i),'color','k','fontsize',14);
            
            plot(x, y, 'k'); hold on;
            
            j=1;
            for(si = 1:length(start_idx))
                text('position',[x(start_idx(si)) y(start_idx(si))],'String',sprintf('%d',allowed_j(j)),'color','b');
                j = j+1;
            end
            
            xlims = [x_i x]; ylims = [y_i y];
            axis([max(1,min(xlims)-border_thickness) min(FileInfo.Width,max(xlims)+border_thickness) max(1,min(ylims)-border_thickness) min(FileInfo.Height,max(ylims)+border_thickness)]);
            hold off;
            
                     
            cnames = {'<HTML>&Delta;t (sec)</HTML>','distance (mm)', 'speed (mm/sec)','<HTML>&Delta<HTML><HTML>&theta (deg)<HTML>'};
            dat = [];
            for(jj=1:length(allowed_j))
                j = allowed_j(jj);
                
                rnames{jj} = num2str(j);
                
                dt = ( linkedTracks(j).Frames(1)-linkedTracks(i).Frames(end) )/linkedTracks(j).FrameRate;
                dr = linkedTracks(j).PixelSize*sqrt( ( linkedTracks(i).SmoothX(end) - linkedTracks(j).SmoothX(1) )^2 + ...
                    ( linkedTracks(i).SmoothY(end) - linkedTracks(j).SmoothY(1) )^2 );
                speed = dr/dt;
                d_theta = abs( GetAngleDif( mean_direction(linkedTracks(i).Direction(end-Prefs.FrameRate:end)), mean_direction(linkedTracks(j).Direction(1:1+Prefs.FrameRate)) ) );
                
                dat(jj,:) = [dt dr speed d_theta];
            end
            ht = figure(101); 
            set(ht,'units','normalized','position',[0.7 0.65 0.3 0.25]);
            uitable('parent',ht,'Data',dat,'ColumnName',cnames,'RowName',rnames,'units','normalized','position',[0.1 0.1 0.95 0.8]);
            clear('rnames'); clear('cnames'); clear('dat');
                
            track_idx_txt = char(inputdlg(sprintf('Which track (%s) should be linked to track # %d?\n''q'' to quit',num2str(allowed_j),i)));

            if(~isempty(track_idx_txt))
                if(track_idx_txt(1) == 'q')
                    Prefs = OPrefs;
                    return;
                end
                j = sscanf(track_idx_txt,'%d');
                
                while(isempty(find(allowed_j == j)))
                    track_idx_txt = char(inputdlg(sprintf('Error: %d is not a choice\nWhich track (%s) should be linked to track # %d?\n''q'' to quit',j,num2str(allowed_j),i)));
                    if(track_idx_txt(1) == 'q')
                        Prefs = OPrefs;
                        return;
                    end
                    j = sscanf(track_idx_txt,'%d');
                end
                
                % overlapped time-travelling tracks!
                if(linkedTracks(j).Frames(1) < linkedTracks(i).Frames(end)+1)
                    t1 =  extract_track_segment(linkedTracks(j), linkedTracks(i).Frames(end)+1, linkedTracks(j).Frames(end), 'frames');
                    linkedTracks(i) = append_track(linkedTracks(i), t1, 'interpolate');
                else
                    linkedTracks(i) = append_track(linkedTracks(i), linkedTracks(j), 'interpolate');
                end
                linkedTracks(j) = [];
                link_flag = 1;
            else
                i = i+1;
            end
            close(101);
            close(100);
            pause(0.1);
        else
            i = i+1;
        end
        
    end
end

return;
end

