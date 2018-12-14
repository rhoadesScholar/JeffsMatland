function SingleFileTrackerAutomatedScript(FileName, varargin)

global Prefs;
Prefs = define_preferences(Prefs);

target_numworms = 0;
pixelsize_MovieName = '';


if(nargin == 0) % running in interactive mode... no arguments given
    
    cd(pwd);
    [FileName, PathName] = uigetfile('*.avi', 'Select AVI Movie For Analysis');
    if FileName == 0
        errordlg('No movie was selected for analysis');
        return;
    end
    [pathstr, FilePrefix, ext] = fileparts(FileName);
    
    cd(pwd);
    [stimfile, pathstr] = uigetfile('*.stim', 'Select Stimulus Interval File');
    stimulusIntervalFile = sprintf('%s%s%s',pathstr,filesep,stimfile);
    if(strcmp(stimulusIntervalFile,filesep)==1)
        stimulusIntervalFile = '';
    end
    
    
else  % probably running from a script or command-line
    [PathName, FilePrefix, ext] = fileparts(FileName);
    
    stimulusIntervalFile = '';
    trackonly_flag = 0;
    binflag = 1;
    linkflag = 1;
    i=1;
    while(i<=length(varargin))
        if(isempty(findstr(char(varargin{i}),'.stim'))==0) % .stim file is a stimulus interval file
            stimulusIntervalFile = varargin{i};
            i=i+1;
        else if(isempty(findstr(char(varargin{i}),'.txt'))==0) % .txt file is a stimulus interval file
                stimulusIntervalFile = varargin{i};
                [stimfilepathstr, stimfileprefix] = fileparts(stimulusIntervalFile);
                if(~isempty(stimfilepathstr))
                    stimulusIntervalFile = sprintf('%s%s%s.txt',stimfilepathstr,filesep,stimfileprefix);
                else
                    stimulusIntervalFile = sprintf('%s.txt',stimfileprefix);
                end
                i=i+1;
            else if(strfind(lower(varargin{i}),lower('Bin'))==1)
                    i=i+1;
                    Prefs.BinSize = varargin{i};
                    Prefs.FreqBinSize = Prefs.BinSize;
                    Prefs.SpeedEccBinSize = Prefs.BinSize;
                    i=i+1;
                else if(strfind(lower(varargin{i}),lower('FreqBin'))==1)
                        i=i+1;
                        Prefs.FreqBinSize = varargin{i};
                        i=i+1;
                    else if(strfind(lower(varargin{i}),lower('SpeedEccBin'))==1)
                            i=i+1;
                            Prefs.SpeedEccBinSize = varargin{i};
                            i=i+1;
                        else if(strcmpi(varargin{i},'numworms')==1)
                                i=i+1;
                                target_numworms = varargin{i};
                                i=i+1;
                            else if(strcmpi(varargin{i},'trackonly')==1)
                                    trackonly_flag = 1;
                                    i=i+1;
                                else if(strcmpi(varargin{i},'binflag')==1)
                                        i=i+1;
                                        binflag=varargin{i};
                                        i=i+1;
                                    else if(strfind(lower(varargin{i}),'scale')==1)
                                            i=i+1;
                                            pixelsize_MovieName = varargin{i};
                                            i=i+1;
                                        else if(strcmpi(varargin{i},'linkflag')==1)
                                                i=i+1;
                                                linkflag=varargin{i};
                                                i=i+1;
                                            else if(strcmpi(varargin{i},'framerate')==1)
                                                    i=i+1;
                                                    Prefs.FrameRate = varargin{i};
                                                    Prefs = CalcPixelSizeDependencies(Prefs, Prefs.DefaultPixelSize);
                                                    i=i+1;
                                                else if(isempty(varargin{i}))
                                                        i=i+1;
                                                    else
                                                        sprintf('Error in SingleFileTrackerAutomatedScript: Do not recognize %s',char(varargin{i}))
                                                        return
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
if(~isempty(pixelsize_MovieName))
    ringfile = sprintf('%s%s.Ring.mat',PathName, FilePrefix);
    
    if(does_this_file_need_making(ringfile))
        Ring = get_pixelsize_from_arbitrary_object(pixelsize_MovieName);
        save(ringfile, 'Ring');
    end
end

command = sprintf('Tracker(''%s'',''%s'',''%s'','''',''numworms'',%d,''framerate'',%d);', PathName, FilePrefix, stimulusIntervalFile, target_numworms,Prefs.FrameRate);
eval(command);

% AnalysisMaster(PathName, 'stimulusIntervalFile',stimulusIntervalFile,'FilePrefix',FilePrefix);

return;
end
