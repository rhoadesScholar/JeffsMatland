function view_tracks(inputTracks, plot_track_flag)

segment_length = 60*10000; % big number for the full-length track, without gaps

if(nargin<2)
    plot_track_flag=1;
end

nanfilter_flag=0;

global Prefs;

Prefs = define_preferences(Prefs);
% Prefs.RingDistanceCutoffPixels = 0; % ignore the ring for this


scoredTrackNum = 0;


numtracks = length(inputTracks);

for(TrackNum = 1:length(inputTracks))
    
    segmentlength_in_frames = segment_length*inputTracks(TrackNum).FrameRate;

    firstframe=1;

    while(firstframe<length(inputTracks(TrackNum).Size)-2)

        if(nanfilter_flag == 1)
            lastframe = firstframe+1;
            while(~isnan(inputTracks(TrackNum).Size(lastframe)) && lastframe<length(inputTracks(TrackNum).Size) && ...
                    (lastframe-firstframe)<segmentlength_in_frames )
                lastframe = lastframe+1;
            end

            if(isnan(inputTracks(TrackNum).Size(lastframe)))
                lastframe = lastframe-1;
            end
        else
            firstframe = 1;
            lastframe = length(inputTracks(TrackNum).Size);
        end

  %      if((lastframe-firstframe)>10*inputTracks(TrackNum).FrameRate) % at least 10sec long track

            if((lastframe-firstframe) > segmentlength_in_frames)
                lastframe = firstframe-1+segmentlength_in_frames;
                if(lastframe > length(inputTracks(TrackNum).Size))
                    lastframe = length(inputTracks(TrackNum).Size);
                end
            end


            workingtrack = extract_track_segment(inputTracks(TrackNum), firstframe, lastframe);
            
            disp([sprintf('%d\t%s\t%d:%d/%d\t%.2f to %.2f sec',TrackNum, workingtrack.Name, firstframe,lastframe,length(inputTracks(TrackNum).Size),  inputTracks(TrackNum).Time(1),inputTracks(TrackNum).Time(end))])

            if(isfield(inputTracks(TrackNum),'scoredState') || isfield(inputTracks(TrackNum),'minimalState'))
                number_line_unit = '   .     ';
                number_line=[];
                nn=0;
                while(length(number_line)<= length(inputTracks(TrackNum).minimalState))
                    number_line = [number_line num2str(nn) number_line_unit];
                    nn=nn+1;
                end
                number_line = number_line(1:length(inputTracks(TrackNum).minimalState));
                disp([number_line])
                if(isfield(inputTracks(TrackNum),'minimalState'))
                    disp([char(inputTracks(TrackNum).minimalState)])
                end
                if(isfield(inputTracks(TrackNum),'scoredState'))
                    disp([char(inputTracks(TrackNum).scoredState)])
                end
            end
            
            if(plot_track_flag==1)
                figure(2); 
                plot_track(workingtrack);
            end

            
            
            make_local_plot(workingtrack);
            
%            RunPlayMovieFlagEvents(workingtrack);


            
            clear('workingtrack');

  %      end

        firstframe = lastframe+1;
        if(lastframe < length(inputTracks(TrackNum).Size))
            if(firstframe<length(inputTracks(TrackNum).Size))
                while(isnan(inputTracks(TrackNum).Size(firstframe)) && firstframe<length(inputTracks(TrackNum).Size))
                    firstframe=firstframe+1;
                end
            end
        end

    end
    
    pause
end
close all;
return;

end


function make_local_plot(Tracks)

global Prefs;

figure(1);
set(gcf,'position',[50   636   512   200]) % [100 512+55+60 512 200] [100 623 511 202] [x, y, width, height] x,y coords of bottom left corner

% movie window is  [100 60 512 512+55]


subplot(3,1,1);
plot(1:length(Tracks.Frames),(Tracks.AngSpeed));
axis([1 length(Tracks.Frames) -180 180]);
set(gca,  'XMinorTick','on', 'YMinorTick','on','box','off');
ylabel('AngSpeed');

subplot(3,1,2);
plot(1:length(Tracks.Frames),Tracks.Eccentricity);
axis([1 length(Tracks.Frames) 0.5 1]);
set(gca,  'XMinorTick','on', 'YMinorTick','on','box','off');
ylabel('ecc');

% subplot(3,1,3);
% plot(1:length(Tracks.Frames), Tracks.Curvature);
% axis([1 length(Tracks.Frames) -120 120]);
% set(gca,  'XMinorTick','on', 'YMinorTick','on','box','off');
% ylabel('curv');
% xlabel('Frame');

subplot(3,1,3);
plot(1:length(Tracks.Frames), Tracks.Speed);
ymax=0.25;
if(ymax < max(Tracks.Speed))
    ymax = max(Tracks.Speed);
end
axis([1 length(Tracks.Frames) 0 ymax]);
set(gca,  'XMinorTick','on', 'YMinorTick','on','box','off');
ylabel('Speed');
xlabel('Frame');


% subplot(3,1,3);
% plot(1:length(Tracks.Frames), (Tracks.MajorAxes*Tracks.PixelSize/Tracks.Wormlength));
% axis([1 length(Tracks.Frames) 0.4 1.2 ]);
% set(gca,  'XMinorTick','on', 'YMinorTick','on','box','off');
% ylabel('major axis');
% xlabel('Frame');

% subplot(3,1,3);
% plot(1:length(Tracks.Frames), (Tracks.eccSpeed));
% axis([1 length(Tracks.Frames) -0.5 0.5]);
% set(gca,  'XMinorTick','on', 'YMinorTick','on','box','off');
% ylabel('eccSpeed');
% xlabel('Frame');



% for(i=1:length(Tracks.Frames))
%     area(i)=NaN;
%     if(~isnan(Tracks.Size(i)))
%         x = size(Tracks.Image{i});
%         area(i) = x(1)*x(2);
%     end
% end
% subplot(3,1,3);  
% plot(1:length(Tracks.Frames), (area));
% xlim([1 length(Tracks.Frames)]);
% set(gca,  'XMinorTick','on', 'YMinorTick','on','box','off');
% ylabel('box area');
% xlabel('Frame');



return
end

