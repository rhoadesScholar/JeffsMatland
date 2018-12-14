function [BinData, collapseTracks] = join_food_sansFood_staring_BinData(dirname, suffix)

BinData = [];
collapseTracks = [];

if(nargin<2)
    suffix='';
end

global Prefs;
Prefs = define_preferences(Prefs);

dirname = char(dirname);

prefix = prefix_from_path(dirname);

if(isempty(suffix))
    dummystring = sprintf('%s%s%s%s%s_%s.avg.BinData_array.mat',dirname,filesep,'sansFood',filesep,prefix,'sansFood');
else
    dummystring = sprintf('%s%s%s_%s%s%s_%s_%s.BinData_array.mat',dirname,filesep,'sansFood',suffix,filesep,prefix,'sansFood',suffix);
end

if(file_existence(dummystring)==0)
    disp([sprintf('%s does not exist',dummystring)])
    return;
end
sansFood_BinData_array = load_BinData_arrays(dummystring);
sansFood_BinData_array = extract_BinData_array(sansFood_BinData_array,0,3600);


[instantaneous_fieldnames, freq_fieldnames, n_inst_fields, n_freq_fields] = get_BinData_fieldnames(sansFood_BinData_array(1));



if(isempty(suffix))
    dummystring = sprintf('%s%s%s%s%s_%s.avg.BinData_array.mat',dirname,filesep,'food',filesep,prefix,'food');
else
    dummystring = sprintf('%s%s%s_%s%s%s_%s_%s.BinData_array.mat',dirname,filesep,'food',suffix,filesep,prefix,'food',suffix);
end
if(file_existence(dummystring)==0)
    disp([sprintf('%s does not exist',dummystring)])
    return;
end
food_BinData_array = load_BinData_arrays(dummystring);
food_BinData_array = extract_BinData_array(food_BinData_array,0,600);

% since we have 10min (600sec)off-food
for(i=1:length(food_BinData_array))
    food_BinData_array(i).time = food_BinData_array(i).time - 600;
    food_BinData_array(i).freqtime = food_BinData_array(i).freqtime - 600;
end


% % for fitting, scramble the food signal randomly duplicate
% % obviously, this is NOT kosher and will need to be redone w/ longer
% % on-food movies .... however, if we assume that the food state is a stable
% % on, this should not be unreasonable for now
% dummy_BinData = food_BinData;
% dummy_BinData.time = dummy_BinData.time - 300; dummy_BinData.freqtime = dummy_BinData.freqtime - 300;
% food_BinData = hookup_BinData(dummy_BinData, food_BinData);
% clear('dummy_BinData');
% y = rand(1,length(food_BinData.speed));
% [s,idx] = sort(y);
% for(p=1:length(instantaneous_fieldnames))
%     s_field = sprintf('%s_s',instantaneous_fieldnames{p});
%     err_field = sprintf('%s_err',instantaneous_fieldnames{p});
%     food_BinData.(instantaneous_fieldnames{p}) = food_BinData.(instantaneous_fieldnames{p})(idx);
%
%     if(isfield(food_BinData,s_field))
%         food_BinData.(s_field) = food_BinData.(s_field)(idx);
%         food_BinData.(err_field) = food_BinData.(err_field)(idx);
%     end
% end
% y = rand(1,length(food_BinData.lRev_freq));
% [s,idx] = sort(y);
% for(p=1:length(freq_fieldnames))
%     s_field = sprintf('%s_s',freq_fieldnames{p});
%     err_field = sprintf('%s_err',freq_fieldnames{p});
%     food_BinData.(freq_fieldnames{p}) = food_BinData.(freq_fieldnames{p})(idx);
%     if(isfield(food_BinData,s_field))
%         food_BinData.(s_field) = food_BinData.(s_field)(idx);
%         food_BinData.(err_field) = food_BinData.(err_field)(idx);
%     end
% end




% NaN fill dummy_BinData values for time 1/FrameRate -> 180sec
dummy_BinData = initialize_BinData;
dummy_BinData.time = Prefs.SpeedEccBinSize:Prefs.SpeedEccBinSize:180; % zeros(1,length(length(Prefs.SpeedEccBinSize/2:Prefs.SpeedEccBinSize:180))) + NaN;
dummy_BinData.freqtime = Prefs.FreqBinSize:Prefs.FreqBinSize:180; %  zeros(1,length(Prefs.FreqBinSize/2:Prefs.FreqBinSize:180)) + NaN;
for(p=1:length(instantaneous_fieldnames))
    s_field = sprintf('%s_s',instantaneous_fieldnames{p});
    err_field = sprintf('%s_err',instantaneous_fieldnames{p});
    dummy_BinData.(instantaneous_fieldnames{p}) = zeros(1,length(dummy_BinData.time)) + NaN;
end
for(p=1:length(freq_fieldnames))
    s_field = sprintf('%s_s',freq_fieldnames{p});
    err_field = sprintf('%s_err',freq_fieldnames{p});
    dummy_BinData.(freq_fieldnames{p}) = zeros(1,length(dummy_BinData.freqtime)) + NaN;
end
for(p=1:length(n_inst_fields))
    dummy_BinData.(n_inst_fields{p}) = zeros(1,length(dummy_BinData.time)) + NaN;
end
for(p=1:length(n_freq_fields))
    dummy_BinData.(n_freq_fields{p}) = zeros(1,length(dummy_BinData.freqtime)) + NaN;
end

for(i=1:length(food_BinData_array))
    f1(i) = hookup_BinData(food_BinData_array(i), dummy_BinData);
end
clear('food_BinData_array');
food_BinData_array = f1;
clear('dummy_BinData');
clear('f1');

for(i=1:length(sansFood_BinData_array))
    sansFood_BinData_array(i).time = sansFood_BinData_array(i).time + 180;
    sansFood_BinData_array(i).freqtime = sansFood_BinData_array(i).freqtime + 180;
end

len = min([length(food_BinData_array) length(sansFood_BinData_array)]);
for(i=1:len)
    BinData_array(i) = alternate_binwidth_BinData(hookup_BinData(food_BinData_array(i), sansFood_BinData_array(i)),60);
end

BinData = mean_BinData_from_BinData_array(BinData_array);
if(~isempty(suffix))
    BinData.Name = sprintf('%s_%s',prefix, suffix);
else
    BinData.Name = prefix;
end
save_BinData(BinData, dirname, BinData.Name);

dummystring = sprintf('%s%s%s.BinData_array.mat',dirname,filesep,BinData.Name);
save(dummystring,'BinData_array');




collapseTracks=[];
%
%     dummystring = sprintf('%s%s%s%s%s_%s.collapseTracks.mat',dirname,filesep,'food',filesep,prefix,'food');
%     load(dummystring);
%     foodTracks = collapseTracks;
%     % % NOT kosher ... discussed above
%     % for(i=1:length(collapseTracks))
%     %     collapseTracks(i) = reframe_Track(collapseTracks(i), collapseTracks(i).Frames(1) + 300*collapseTracks(1).FrameRate);
%     % end
%     for(i=1:length(foodTracks))
%         foodTracks(i) = append_track(foodTracks(i), collapseTracks(length(foodTracks)-i+1));
%     end
%     clear('collapseTracks');
%     for(i=1:length(foodTracks))
%         foodTracks(i).Time = foodTracks(i).Time - 600;
%     end
%     foodTracks = sort_tracks_by_length(foodTracks);
%
%
%     dummystring = sprintf('%s%s%s%s%s_%s.collapseTracks.mat',dirname,filesep,'sansFood',filesep,prefix,'sansFood');
%     load(dummystring);
%     for(i=1:length(collapseTracks))
%         collapseTracks(i) =  reframe_Track(collapseTracks(i), collapseTracks(i).Frames(1) + (600+180)*collapseTracks(1).FrameRate);
%     end
%     sansFoodTracks = collapseTracks;
%     clear('collapseTracks');
%     sansFoodTracks = sort_tracks_by_length(sansFoodTracks);
%
%     minlength = length(foodTracks);
%     if(length(sansFoodTracks) < minlength)
%         minlength = length(sansFoodTracks);
%     end
%     foodTracks = foodTracks(1:minlength);
%     sansFoodTracks = sansFoodTracks(1:minlength);
%
%
%     i=1;
%     while(i<=length(foodTracks))
%         collapseTracks(i) = append_track( foodTracks(i), sansFoodTracks(i), 'join' ) ;
%         collapseTracks(i).Time = collapseTracks(i).Time - 600;
%         i=i+1;
%     end
%     collapseTracks = sort_tracks_by_length(collapseTracks);
%     clear('foodTracks');
%     clear('sansFoodTracks');
%
%     dummystring = sprintf('%s%s%s.collapseTracks.mat',dirname,filesep,prefix);
%     save_Tracks(dummystring,collapseTracks);
%     clear('collapseTracks'); % free and reload ... more efficient use of memory
%     load(dummystring);
%


close all;
plot_data(BinData_array, collapseTracks, [], dirname, BinData.Name);


return;
end

