function WormPlayer(inputTrackFileName, no_image_flag)

global Prefs;
Prefs = [];
Prefs = define_preferences(Prefs);

if(nargin > 0)
    if(isstruct(inputTrackFileName(1))) % actually, we inputted a Tracks array
        Tracks = inputTrackFileName;
        clear('inputTrackFileName');
        
        if(~isfield(Tracks(1),'Name'))
            [FileName,trackPathName] = uigetfile('*.avi', 'Choose a movie file');
            for(i=1:length(Tracks))
               Tracks(i).Name = sprintf('%s%s%s', trackPathName,filesep,FileName);
            end
        end
        
        trackPathName = ffpath(Tracks(1).Name);
        if(isempty(trackPathName))
            trackPathName = pwd;
        end
    else
        TrackFileName = inputTrackFileName;
        trackPathName = ffpath(inputTrackFileName);
    end
else
    [FileName,trackPathName] = uigetfile('*.mat', 'Choose a track file');
    TrackFileName = [ trackPathName FileName ];
end

axislimits = [];
if(nargin<2)
    no_image_flag = [];
else
    if(ischar(no_image_flag))
        no_image_flag = lower(no_image_flag);
    else
        axislimits = no_image_flag;
        if(size(axislimits,2)==2)
            axislimits = [min(axislimits(:,1)) max(axislimits(:,1)) min(axislimits(:,2)) max(axislimits(:,2))];
        end
        no_image_flag = [];
    end
end


if (~exist('Tracks', 'var') && ~exist('linkedTracks', 'var') && ~exist('rawTracks', 'var') && ~exist('psth_Tracks', 'var') )
    Tracks = load_Tracks(TrackFileName);
end

for(i=1:length(Tracks))
    if(isfield(Tracks(i),'Pirouettes'))
        Tracks(i).Reorientations = Tracks(i).Pirouettes;
        rmfield(Tracks(i),'Pirouettes');
    end
end

% if (exist('psth_Tracks', 'var'))
%     Tracks = psth_Tracks;
%     clear('psth_Tracks');
% end
% 
% if (exist('linkedTracks', 'var'))
%     Tracks = linkedTracks;
%     clear('linkedTracks');
% end
% 
% if (exist('rawTracks', 'var'))
%     Tracks = [];
%     for(i=1:length(rawTracks))
%         Tracks = [ Tracks AnalyseTrack(rawTracks(i)) ];
%     end
%     clear('rawTracks');
% end

if(isfield(Tracks(1),'real_first_frame'))
    for(i=1:length(Tracks))
        Tracks(i).Frames = Tracks(i).Frames + (Tracks(i).real_first_frame-Tracks(i).Frames(1));
        Tracks(i).Time = Tracks(i).Time + (Tracks(i).real_start_time-Tracks(i).Time(1));
    end
end

if(~isfield(Tracks(1),'State'))
    inputTracks = Tracks;
    clear('Tracks');
    for(i=1:length(inputTracks))
        Tracks(i) = AnalyseTrack(inputTracks(i));
    end
    clear('inputTracks');
end

if(~isfield(Tracks(1),'Path'))
    for(i=1:length(Tracks))
        Tracks(i).Path = [Tracks(i).SmoothX; Tracks(i).SmoothY]';
    end
end


%Tracks = make_double(Tracks);

% if(~isfield(Tracks, 'midbody_angle'))
%     for(i=1:length(Tracks))
%         Tracks(i).midbody_angle = body_angle_vs_body_position(Tracks(i).body_contour, 0);
%     end
% end

Prefs.FrameRate = Tracks(1).FrameRate;
Prefs = CalcPixelSizeDependencies(Prefs, Tracks(1).PixelSize);

aviread_to_gray;

for(i=1:length(Tracks))
    
    movie_name = Tracks(i).Name;
    
    if(~file_existence(movie_name))
        % in current directory?
        [movie_name, movpath] = filename_from_partialpath(movie_name);
        if(~file_existence(movie_name))
            
            [candidate_path, upperpath] = filename_from_partialpath(movpath(1:end-1));
            
            movie_name = sprintf('%s%s%s',candidate_path,filesep,movie_name);
            if(file_existence(movie_name))
                % disp(sprintf('Found %s in local directory %s',movie_name, candidate_path))
            else
                movie_name = uigetfile('*.avi', 'Choose a movie file');
            end
        end
    end
    Tracks(i).Name = movie_name;
end
clear('movie_info');


if(~isempty(strfind(no_image_flag,'no')) || ~isempty(strfind(no_image_flag,'back'))) % just use the background
    temp_movie_name = sprintf('%s.temp_background.mat',tempname);
    background = calculate_background(Tracks(1).Name);
    save(temp_movie_name, 'background');
    
    for(i=1:length(Tracks))
        Tracks(i).Name = temp_movie_name;
    end
end

if(~isempty(strfind(no_image_flag,'blank'))) % white backgorund
    temp_movie_name = sprintf('%s.temp_background.mat',tempname);
    background = zeros(Tracks(1).Height, Tracks(1).Width) + 0.7;
    save(temp_movie_name, 'background');
    
    for(i=1:length(Tracks))
        Tracks(i).Name = temp_movie_name;
    end
end


if(strcmpi(no_image_flag,'psth'))
    stimcode = [];
    for(i=1:length(Tracks))
        stimcode = [stimcode Tracks(i).stimulus_vector(Tracks(i).stimulus_vector~=0)];
    end
    stimcode = mode(stimcode);
    if(~isempty(stimcode))
        psth_Tracks = make_psth_Tracks(Tracks, Prefs.psth_pre_stim_period, Prefs.psth_post_stim_period, [0 stimcode],1);
        Tracks = psth_Tracks;
    end
    clear('stimcode');
end

startWormPlayer(Tracks, trackPathName, axislimits);
end


function startWormPlayer(Tracks, trackPathName, axislimits)

% %TODO:
% Graph selection menu
% FPS menu
% jump to frame button working?  only if needed...

hfig = createWormPlayerGUI();

movieData = get(hfig,'userdata');

movieData.Tracks = Tracks;
movieData.play = 'off';
movieData.PreserveFrameNum = 0;
movieData.trackPathName = trackPathName;
movieData.axislimits = axislimits;

set(hfig,'userdata', movieData);

loadTrack(hfig);
SetFPS(hfig);

end

