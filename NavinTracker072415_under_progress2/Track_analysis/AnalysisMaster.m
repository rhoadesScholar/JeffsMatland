function BinData = AnalysisMaster(Pathname, varargin)

global Prefs;

Prefs = define_preferences(Prefs);


if(nargin==0)
    sprintf('Usage:  AnalysisMaster(Pathname, [stimulusIntervalFile], [FilePrefix], [BinSize, FreqBinSize, SpeedEccBinSize])')
    return
end


binflag = 1;
linkflag = 1;
stimulusIntervalFile = '';
FilePrefix = '';
i=1;
while(i<length(varargin))
    if(strcmp(varargin(i),'stimulusIntervalFile')==1)
        i=i+1;
        stimulusIntervalFile = varargin{i};
        i=i+1;
    else if(strcmp(varargin(i),'FilePrefix')==1)
            i=i+1;
            FilePrefix = varargin{i};
            i=i+1;
        else if(strcmp(varargin(i),'BinSize')==1)
                i=i+1;
                Prefs.BinSize = varargin{i};
                Prefs.FreqBinSize = Prefs.BinSize;
                Prefs.SpeedEccBinSize = Prefs.BinSize;
                i=i+1;
            else if(strcmp(varargin(i),'FreqBinSize')==1)
                    i=i+1;
                    Prefs.FreqBinSize = varargin{i};
                    i=i+1;
                else if(strcmp(varargin(i),'SpeedEccBinSize')==1)
                        i=i+1;
                        Prefs.SpeedEccBinSize = varargin{i};
                        i=i+1;
                    else if(strcmp(varargin(i),'binflag')==1)
                            i=i+1;
                            binflag = varargin{i};
                            i=i+1;
                        else if(strcmp(varargin(i),'linkflag')==1)
                                i=i+1;
                                linkflag = varargin{i};
                                i=i+1;
                            else
                                sprintf('Error in AnalysisMaster: Do not recognize %s',varargin(i))
                                return
                            end
                        end
                    end
                end
            end
        end
    end
end

if(strcmp(Pathname,'')==0)
    while(Pathname(end)==filesep)
        Pathname = Pathname(1:end-1);
    end
    Pathname = filesep_convert(Pathname);
    localpath = sprintf('%s%s',Pathname,filesep);
else
    localpath = '';
end

if(strcmp(FilePrefix,'')==0)
    RawTracksFiles(1).name = sprintf('%s.rawTracks.mat',FilePrefix);
else
    dummystring = sprintf('%s*.rawTracks.mat',localpath);
    RawTracksFiles = dir(dummystring);
end

if(isempty(RawTracksFiles))
    sprintf('%s does not exist',Pathname)
    return;
end

if(strcmp(stimulusIntervalFile,'')==1)
    stimulus = [];
else
    stimulus = load_stimfile(stimulusIntervalFile);
    if(~isempty(stimulus))
        v=1;
        while(v<=length(stimulus(:,1)))
            if(stimulus(v,1)==stimulus(v,2))
                stimulus(v,:)=[];
            else
                v=v+1;
            end
        end
    end
end


if(strcmp(localpath, '')==1)
    prefix = FilePrefix;
else
    prefix = sprintf('%s.avg',prefix_from_path(localpath));
end


dummystring = sprintf('%s%s.collapseTracks.mat',localpath,prefix);
process_RawTracksFiles(RawTracksFiles, stimulusIntervalFile, localpath, prefix);
disp([sprintf('loading %s\t%s', dummystring,timeString())])
load(dummystring);


disp([sprintf('binning and averaging\t%s', timeString())])


if(strcmp(Prefs.averaging_type,'per-worm') || length(RawTracksFiles)==1)
    BinData = bin_and_average_all_tracks(collapseTracks, stimulus); % bin all the data
else
    dummystring = sprintf('%s%s.BinData_array.mat',localpath,prefix);
    disp([sprintf('loading %s\t%s', dummystring,timeString())])
    BinData_array = load_BinData_arrays(dummystring);
    disp([sprintf('averaging binned data\t%s',timeString())])
    BinData = mean_BinData_from_BinData_array(BinData_array);
end

save_BinData(BinData, localpath, prefix);
disp([sprintf('binning and averaging finished ... \t%s', timeString())])

disp([sprintf('plotting data and ethograms\t%s', timeString())]);
close all;
if(strcmp(Prefs.averaging_type,'per-worm') || length(RawTracksFiles)==1)
    plot_data(BinData, collapseTracks, stimulus, localpath, prefix);
else
    plot_data(BinData_array, collapseTracks, stimulus, localpath, prefix);
    clear('BinData_array');
end

% if multiple types of stimulus transitions, need identify and make for all of them       
if(~isempty(stimulus))
    if(strcmp(Prefs.averaging_type,'per-worm'))
        psth_plot(collapseTracks, 'path', localpath, 'prefix',prefix,[0 stimulus(1,3)]);
    else
        psth_per_movie_averaging(RawTracksFiles, localpath, prefix, [0 stimulus(1,3)]);
    end
else
    plot_summary_data(BinData, collapseTracks, stimulus, localpath, prefix);
end

clear('BinData');
clear('collapseTracks');
clear('RawTracksFiles');
clear('dummystring');
clear('prefix');

close all;

return;
end
