function outTracks = load_Tracks(filename)

deprecated_fields_to_delete = {'scaledSpeed','Omegas','Reversals','nonOmegaTurns','Pirouettes','MeanSize','stdSize','LastSize','LastCoordinates','timestamp'};

Tracks=[];

if(~ischar(filename))
    Tracks = filename;
else
    if(file_existence(filename)==0)
        disp([sprintf('%s does not exist',filename)])
        outTracks = [];
        return;
    end
    
    load(filename);
    
    if (exist('psth_Tracks', 'var'))
        Tracks = psth_Tracks;
        clear('psth_Tracks');
    end
    
    if (exist('linkedTracks', 'var'))
        Tracks = linkedTracks;
        clear('linkedTracks');
    end
    
    if (exist('rawTracks', 'var'))
        Tracks = [];
        for(i=1:length(rawTracks))
            Tracks = [ Tracks AnalyseTrack(rawTracks(i)) ];
        end
        clear('rawTracks');
    end
    
    if (exist('collapseTracks', 'var'))
        Tracks = collapseTracks;
        clear('collapseTracks');
    end
    
    if (exist('target_odor_linkedTracks', 'var'))
        Tracks = target_odor_linkedTracks;
        clear('target_odor_linkedTracks');
    end
end

if(~isempty(Tracks))
    for(i=1:length(Tracks))
        if(isfield(Tracks(i),'Pirouettes'))
            Tracks(i).Reorientations = Tracks(i).Pirouettes;
        end
        if(isfield(Tracks(i),'Reorientations'))
            for(j=1:length(Tracks(i).Reorientations))
                if(strcmp(Tracks(i).Reorientations(j).class, 'pure_nonOmegaTurn'))
                    Tracks(i).Reorientations(j).class = 'pure_upsilon';
                end
                if(strcmp(Tracks(i).Reorientations(j).class, 'lRevTurn'))
                    Tracks(i).Reorientations(j).class = 'lRevUpsilon';
                end
                if(strcmp(Tracks(i).Reorientations(j).class, 'sRevTurn'))
                    Tracks(i).Reorientations(j).class = 'sRevUpsilon';
                end
                
                if(strcmp(Tracks(i).Reorientations(j).class, 'pure_nonOmegaTurn.ring'))
                    Tracks(i).Reorientations(j).class = 'pure_upsilon.ring';
                end
                if(strcmp(Tracks(i).Reorientations(j).class, 'lRevTurn.ring'))
                    Tracks(i).Reorientations(j).class = 'lRevUpsilon.ring';
                end
                if(strcmp(Tracks(i).Reorientations(j).class, 'sRevTurn.ring'))
                    Tracks(i).Reorientations(j).class = 'sRevUpsilon.ring';
                end
                
                if(~isfield(Tracks(i).Reorientations(j),'revLenBodyBends'))
                    Tracks(i).Reorientations(j).revLenBodyBends = NaN;
                end
                
                if(isempty(Tracks(i).Reorientations(j).revLenBodyBends))
                    Tracks(i).Reorientations(j).revLenBodyBends = NaN;
                end
            end
        end
        
        
        ot = rmfield(Tracks(i),deprecated_fields_to_delete);
        

        outTracks(i) = ot;
    end
else
    outTracks = [];
end

return;
end
