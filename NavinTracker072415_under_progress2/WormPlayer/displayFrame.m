function displayFrame(hfig)

persistent prev_tracknum;
persistent kappa_midbody;
persistent curvature_vs_body_position_matrix;
persistent ctr;

% persistent procFrame;
% persistent prev_prefix;

movieData = get(hfig,'userdata');

Movie = movieData.Movie; 
prefix = Movie(1:(end-4));

FrameNum = movieData.FrameNum;
TrackNum = movieData.TrackNum;

if(isempty(prev_tracknum))
    prev_tracknum = 0;
    ctr = 0;
end

if(TrackNum ~= prev_tracknum)
    if(~isfield(movieData.Tracks(TrackNum),'curvature_vs_body_position_matrix') || ~isfield(movieData.Tracks(TrackNum),'midbody_angle'))
        [curvature_vs_body_position_matrix, kappa_midbody] = curvature_vs_body_position(movieData.Tracks(TrackNum));
    end
    prev_tracknum = TrackNum;
    ctr = 0;
    subplot(8,2,[1 3 5 7 9]);
    hold off
    h = subplot(8,2,[1 3 5 7 9]);
    cla(h,'reset');
    set(h,'xcolor','w'); set(h,'ycolor','w'); set(h,'xtick',[]); set(h,'ytick',[]); ylabel('');
    text(0.5, 0.5, sprintf('Loading Track #%d', TrackNum), ...
                'horizontalalignment','center','verticalalignment','middle'); 
    pause(1);
    aviread_to_gray(Movie, movieData.Tracks(TrackNum).Frames(1:min(100,length(movieData.Tracks(TrackNum).Frames))));
    % aviread_to_gray(Movie, movieData.Tracks(TrackNum).Frames(1:length(movieData.Tracks(TrackNum).Frames)));
end

if(isfield(movieData.Tracks(TrackNum),'curvature_vs_body_position_matrix'))
    curvature_vs_body_position_matrix = movieData.Tracks(TrackNum).curvature_vs_body_position_matrix';
    kappa_midbody = movieData.Tracks(TrackNum).midbody_angle;
end

% if(isempty(prev_prefix))
%    prev_prefix=''; 
% end
% if(~strcmp(prev_prefix,prefix))
%     prev_prefix = prefix;
%     clear('procFrame');
%     ds = sprintf('%s.procFrame.mat',prefix);
%     load(ds);
% end

TrackFrame = movieData.TrackFrame;
Track = movieData.Tracks(TrackNum);
WormLength = Track.Wormlength/Track.PixelSize; % Convert worm length from mm to pixels

ctr = ctr+1;
if(mod(ctr,100)==0)
    Mov = aviread_to_gray(Movie, FrameNum:movieData.Tracks(TrackNum).Frames(end), 0);
end
Mov = aviread_to_gray(Movie, FrameNum, 0);

imageWidth =  size(Mov.cdata,2); % movieData.Tracks(TrackNum).Width;
imageHeight = size(Mov.cdata,1); % movieData.Tracks(TrackNum).Height;

centroid = [movieData.Tracks(TrackNum).SmoothX(TrackFrame) movieData.Tracks(TrackNum).SmoothY(TrackFrame)];
if ( isempty(centroid) )
    centroid = movieData.Tracks(TrackNum).Path(TrackFrame,:);
end
if ( isempty(centroid) )
    centroid = movieData.Tracks(TrackNum).bound_box_corner(TrackFrame,:);
end
if ( isempty(centroid) )
    centroid = [(movieData.PathBounds(1)+movieData.PathBounds(2))/2, (movieData.PathBounds(3)+movieData.PathBounds(4))/2];
end

figure(hfig);

%Display plots
numPlots = length(movieData.Plot);

%Mov = procFrame_to_movieframe(procFrame(FrameNum), imageHeight, imageWidth);

Mov.cdata = drawFrameDetails(Mov.cdata, hfig);
subplot(8,2,[1 3 5 7 9]); % subplot(numPlots,2,1:2:numPlots*2);

% if ( movieData.ZoomLevel > 0 )
%     Mov.cdata = cropFrame(Mov.cdata, movieData.PathBounds, movieData.ZoomLevel, centroid, imageWidth, imageHeight, WormLength);
% end
% % Show image
% image = imshow(Mov.cdata);


imshow(Mov.cdata);

% draw body midline contour
hold on;
if(~isempty(strfind(Movie,'.mat')))
    plot(movieData.Tracks(TrackNum).body_contour(TrackFrame).x-0.5, movieData.Tracks(TrackNum).body_contour(TrackFrame).y-0.5, 'w');
end

if ( movieData.ZoomLevel > 0 )
    new_axes = cropFrame(Mov.cdata, movieData.PathBounds, movieData.ZoomLevel, centroid, imageWidth, imageHeight, WormLength);
    axis(new_axes);
end
if(~isempty(movieData.axislimits))
    axis(movieData.axislimits);
end

StringA = sprintf('(%.2f, %.2f)',movieData.Tracks(TrackNum).SmoothX(TrackFrame), movieData.Tracks(TrackNum).SmoothY(TrackFrame));

StringC = '';
if(movieData.ZoomLevel==1)
    StringC = 'Track zoom';
else
    if(movieData.ZoomLevel==2)
        StringC = '50% zoom';
    else
        if(movieData.ZoomLevel==3)
            StringC = '25% zoom';
        else
            if(movieData.ZoomLevel==4)
                StringC = '10% zoom';
            else
                if ( movieData.ZoomLevel == 5 )
                    StringC = '5% zoom';
                else
                    if( movieData.ZoomLevel == 6 )
                        StringC = sprintf('%s\n%s','bounding box', 'zoom');
                    end
                end
            end
        end
    end
end

StringD = sprintf('%.2f sec',movieData.Tracks(TrackNum).Time(TrackFrame));

stimstring = '';
if(movieData.Tracks(TrackNum).stimulus_vector(TrackFrame)~=0)
    stimstring = sprintf('%s %d','Stimulus', movieData.Tracks(TrackNum).stimulus_vector(TrackFrame));
end

custom_metric_str = '';
if(isfield(movieData.Tracks(TrackNum),'custom_metric'))
    custom_metric_str = sprintf('%.2f',movieData.Tracks(TrackNum).custom_metric(TrackFrame));
end

ylabel({StringA;' ';StringD;StringC;stimstring;custom_metric_str}, 'Rotation',0, ...
        'HorizontalAlignment', 'right');

hold off;

% Now draw plots

for i = 1:numPlots
    
    currentAxes = subplot(numPlots+1,2,i*2);
    
    if ( isfield(Track, movieData.Plot(i).ydata ) )
        YData = getfield(Track, movieData.Plot(i).ydata);
        
        if(strcmpi(movieData.Plot(i).ydata,'speed'))
            rev_idx = [find(strcmp(num_state_convert(floor(movieData.Tracks(TrackNum).State)),'lRev')) find(strcmp(num_state_convert(floor(movieData.Tracks(TrackNum).State)),'sRev'))];
            YData(rev_idx) = -YData(rev_idx);
        end
        
    end
    if ( isfield(Track, movieData.Plot(i).xdata ) )
        XData = getfield(Track, movieData.Plot(i).xdata);
    end
    
    minX = XData(1);
    maxX = XData(end);
    
    YData_extension = 0; % 0.1*abs(max(YData)-min(YData));
    
    minY = min(YData) - YData_extension;
    maxY = max(YData) + YData_extension;
    
    if ( length(movieData.Plot(i).ylim) == 2 )
        minY = min(minY, movieData.Plot(i).ylim(1));
        maxY = max(maxY, movieData.Plot(i).ylim(2));
    end
    
    if(isnan(minY))
        minY = 0;
    end
    
    if(isnan(maxY))
        maxY = 1;
    end
    
    %plot frame indicator
    line = plot([FrameNum,FrameNum], [minY,maxY], movieData.Plot(i).frameindicator);
    set(line, 'ButtonDownFcn', @clickGotoFrame);
    hold on;
    line = plot(XData, YData, movieData.Plot(i).plotstyle,'linewidth',2);
    set(line, 'ButtonDownFcn', @clickGotoFrame);
    
    if(strcmp(movieData.Plot(i).ydata,'Direction') || strcmp(movieData.Plot(i).ydata,'AngSpeed'))
        minY = -180;
        maxY = 180;
    end
    
    StringA = fix_title_string(movieData.Plot(i).ydata);
    StringB = num2str(YData(TrackFrame));
    if(strcmp(movieData.Plot(i).ydata,'Direction') || strcmp(movieData.Plot(i).ydata,'AngSpeed'))
        minY = -180;
        maxY = 180;
    end
    
    axis([minX maxX minY maxY]);
    set(gca,'xtick',[]); %,'ytick',[])
    
        ylabel({StringA;StringB}, 'Rotation',0, ...
        'HorizontalAlignment', 'right');
    set(currentAxes, 'ButtonDownFcn', @clickGotoFrame);
    hold off;
    
end

% midbody angle
if(~isempty(kappa_midbody))
    currentAxes = subplot(numPlots+1,2,(numPlots+1)*2);
    YData = kappa_midbody;
    % minY=-0.5; maxY=0.5;
    minY=min(kappa_midbody); maxY=max(kappa_midbody);
    if(length(XData) == length(kappa_midbody))
        line = plot([FrameNum,FrameNum], [minY,maxY], movieData.Plot(i).frameindicator);
        set(line, 'ButtonDownFcn', @clickGotoFrame);
        hold on;
        line = plot(XData, YData, 'b','linewidth',2);
        set(line, 'ButtonDownFcn', @clickGotoFrame);
        axis([minX maxX minY maxY]);
        set(gca,'xtick',[]);
        StringA = fix_title_string('midbody angle');
        StringB = num2str(YData(TrackFrame));
        ylabel({StringA;StringB}, 'Rotation',0, ...
            'HorizontalAlignment', 'right');
        set(currentAxes, 'ButtonDownFcn', @clickGotoFrame);
        hold off;
    end
end

if(isfield(movieData.Tracks(TrackNum),'custom_metric'))
    % if(nansum((movieData.Tracks(TrackNum).custom_metric)) > 0)
        currentAxes = subplot(numPlots+1,2,(numPlots+1)*2);
        YData = movieData.Tracks(TrackNum).custom_metric;
        minY=min(YData); maxY=max(YData);
        % minY = 0; maxY = 180;
        if(length(XData) == length(YData))
            line = plot([FrameNum,FrameNum], [minY,maxY], movieData.Plot(i).frameindicator);
            set(line, 'ButtonDownFcn', @clickGotoFrame);
            hold on;
            line = plot(XData, YData, movieData.Plot(i).plotstyle,'linewidth',2);
            set(line, 'ButtonDownFcn', @clickGotoFrame);
            axis([minX maxX minY maxY]);
            set(gca,'xtick',[]);
            StringA = fix_title_string('custom metric');
            StringB = num2str(YData(TrackFrame));
            ylabel({StringA;StringB}, 'Rotation',0, ...
                'HorizontalAlignment', 'right');
            set(currentAxes, 'ButtonDownFcn', @clickGotoFrame);
            hold off;
        end
    % end
end




% put the x-axis label at the bottom
set(gca,'xtickMode', 'auto');
xlabel([movieData.Plot(i).xlabel, ' ', num2str(XData(TrackFrame))]);
hold off;

% ethogram, body angle image, stimulus markers

minX = min(movieData.Tracks(TrackNum).Frames);
maxX = max(movieData.Tracks(TrackNum).Frames);

% plot body angle image
if(~isempty(curvature_vs_body_position_matrix))
    currentAxes = subplot(8,2,11); % subplot(numPlots,2,(numPlots-2)*2);
    plot_curvature_vs_body_position_matrix(curvature_vs_body_position_matrix, movieData.Tracks(TrackNum).Frames)
    
    hold on;
    minY=1; maxY=size(curvature_vs_body_position_matrix,1);
    line = plot([FrameNum-movieData.Tracks(TrackNum).Frames(1)+1,FrameNum-movieData.Tracks(TrackNum).Frames(1)+1], [minY,maxY], 'k','linewidth',2);
    set(line, 'ButtonDownFcn', @clickGotoFrame);
    hold on;
    line = plot([FrameNum-movieData.Tracks(TrackNum).Frames(1)+1,FrameNum-movieData.Tracks(TrackNum).Frames(1)+1], [minY,maxY], 'k','linewidth',2);
    set(line, 'ButtonDownFcn', @clickGotoFrame);

    ylim([minY, maxY]);
    
    set(gca,'xtick',[]);
    set(currentAxes, 'ButtonDownFcn', @clickGotoFrame);
    
    hold off;
end

%  plot state-strip image
currentAxes = subplot(8,2,13); % subplot(numPlots,2,(numPlots-1)*2);
single_Track_ethogram(Track);
axis xy
hold on;
minY=0.5; maxY=1.5;

line = plot([FrameNum,FrameNum], [minY,maxY], 'k');
set(line, 'ButtonDownFcn', @clickGotoFrame);
hold on;
line = plot([FrameNum,FrameNum], [minY,maxY], 'k');
set(line, 'ButtonDownFcn', @clickGotoFrame);

axis([minX, maxX, minY, maxY]);
set(gca,'xtick',[]);

StringB = fix_title_string(sprintf('%s\n\n',num_state_convert(movieData.Tracks(TrackNum).State(TrackFrame))));
if(movieData.Tracks(TrackNum).State(TrackFrame) > num_state_convert('fwd_state'))
    if(movieData.Tracks(TrackNum).State(TrackFrame) < num_state_convert('missing'))
        reori_idx = reorientation_frame(movieData.Tracks(TrackNum), TrackFrame);
        if(~isempty(reori_idx))
            if(isfield(movieData.Tracks(TrackNum).Reorientations(reori_idx),'revLenBodyBends'))
            StringB = fix_title_string(sprintf('%s\n%.1f deg\n%.2f bodylengths\n%.1f bodybends\n%.2f ecc',movieData.Tracks(TrackNum).Reorientations(reori_idx).class, ...
                movieData.Tracks(TrackNum).Reorientations(reori_idx).delta_dir, ...
                movieData.Tracks(TrackNum).Reorientations(reori_idx).revLen, ...
                movieData.Tracks(TrackNum).Reorientations(reori_idx).revLenBodyBends, ...
                movieData.Tracks(TrackNum).Reorientations(reori_idx).ecc));
            else
                           StringB = fix_title_string(sprintf('%s\n%.1f deg\n%.2f bodylengths\n%.2f ecc',movieData.Tracks(TrackNum).Reorientations(reori_idx).class, ...
                movieData.Tracks(TrackNum).Reorientations(reori_idx).delta_dir, ...
                movieData.Tracks(TrackNum).Reorientations(reori_idx).revLen, ...
                movieData.Tracks(TrackNum).Reorientations(reori_idx).ecc)); 
            end
        end
    end
end

ylabel({StringB}, 'Rotation',0, ...
    'HorizontalAlignment', 'right');
ylabh = get(gca,'YLabel');
set(ylabh,'Position',get(ylabh,'Position') - [0 0.75 0]); % [0 0.5 0]
set(currentAxes, 'ButtonDownFcn', @clickGotoFrame);
hold off;

% plot stimulus bar
if(isfield(movieData.Tracks(TrackNum), 'stimulus_vector'))
    currentAxes = subplot(8,2,15); % subplot(numPlots,2,numPlots*2);
    
    single_track_stimulusShade(movieData.Tracks(TrackNum));
    axis xy
    hold on;
    minY=0.5; maxY=1.5;
    
    line = plot([FrameNum,FrameNum], [minY,maxY], 'k');
    set(line, 'ButtonDownFcn', @clickGotoFrame);
    
    axis([minX, maxX, minY, maxY]);
    
    set(gca,'xtick',[]);
    StringA = 'Stimulus';
    StringB = num2str(movieData.Tracks(TrackNum).stimulus_vector(TrackFrame));
    ylabel({StringA;StringB}, 'Rotation',0, 'HorizontalAlignment', 'right','VerticalAlignment','middle');
    set(currentAxes, 'ButtonDownFcn', @clickGotoFrame);
    hold off;
end

% x-axes for left plots
set(gca,'xtickMode', 'auto');

xlabel([movieData.Plot(i).xlabel, ' ', num2str(XData(TrackFrame))]);
hold off;

% sliders

H = movieData.FrameSlider;
set(H, 'enable', 'on', ...
    'Value', TrackFrame, ...
    'SliderStep', [1,10]/movieData.TrackNumFrames, ...
    'Max', movieData.TrackNumFrames, ...
    'Min', 1);

FrameSliderString = ['Frame ' num2str(TrackFrame) ' of ' num2str(movieData.TrackNumFrames) ' (actual frame ' num2str(FrameNum) ')'];
H = movieData.FrameSliderText;
set(H, 'string', FrameSliderString);

if(movieData.NumTracks > 1)
    H = movieData.TrackSlider;
    set(H, 'enable', 'on', ...
        'Value', TrackNum, ...
        'SliderStep', [1,10]/movieData.NumTracks, ...
        'Max', movieData.NumTracks, ...
        'Min', 1);
    
    TrackSliderString = ['Track ' num2str(TrackNum) ' of ' num2str(movieData.NumTracks) ];
    H = movieData.TrackSliderText;
    set(H, 'string', TrackSliderString);
else
    H = movieData.TrackSlider;
    set(H, 'enable', 'off');
end

H = movieData.FrameSelectorBeg;
set(H, 'string', movieData.Tracks(TrackNum).Frames(1), 'enable', 'on');
H = movieData.FrameSelectorEnd;
set(H, 'string', movieData.Tracks(TrackNum).Frames(movieData.TrackNumFrames), 'enable', 'on');

if(isfield(Track, 'stimulus_vector'))
    if ( Track.stimulus_vector(TrackFrame) > 0)
        StimulusTextDisplay = ['Stimulus ' num2str(Track.stimulus_vector(TrackFrame)) ' on'];
    else
        StimulusTextDisplay = '';
    end
    H = movieData.StimulusText;
    set(H, 'string', StimulusTextDisplay);
end

end

