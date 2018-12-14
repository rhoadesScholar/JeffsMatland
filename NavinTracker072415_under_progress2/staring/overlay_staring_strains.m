function [BinData_array, Tracks_struct] = overlay_staring_strains(strainlist, colors, path, prefix)

if(nargin<3)
   path = ''; 
end

if(nargin<4)
   prefix = strainlist{1};
   for(i=2:length(strainlist))
       prefix = sprintf('%s_%s',prefix, strainlist{i});
   end
end

i=1; 
while(i<=length(strainlist))
    
    bindata_filename = sprintf('%s%s%s_1min.BinData.mat',strainlist{i},filesep,strainlist{i});
    tracks_filename = sprintf('%s%s%s.collapseTracks.mat',strainlist{i},filesep,strainlist{i});
    if(file_existence(bindata_filename) && file_existence(tracks_filename))
        
        load(bindata_filename);
        BinData_array(i) = BinData;
        clear('BinData');
        
        load(tracks_filename);
        Tracks_struct(i).Tracks = collapseTracks;
        clear('collapseTracks');
    else
        disp(['Cannot find ',bindata_filename,' and/or ',tracks_filename])
        return
    end
    
    i=i+1;
end

comparison_plot(BinData_array, Tracks_struct, colors,[],path,prefix)

return;
end
