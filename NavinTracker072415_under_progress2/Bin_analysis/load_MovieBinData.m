function [AvgBinData, MovieBinDataArray] = load_MovieBinData(inputpath)
    
avgbindata_filename = sprintf('%s.BinData.mat',prefix_from_path(deblank(filesep_convert(inputpath))));

load(sprintf('%s%s%s',  inputpath,filesep,avgbindata_filename));

AvgBinData = BinData;
clear('BinData');

dummystring = sprintf('%s%s*.BinData.mat',inputpath,filesep);
bindatalist = dir(dummystring);

i=1;
for j=1:length(bindatalist)
    if(strcmp(bindatalist(j).name,avgbindata_filename)==0)
       
        filename = sprintf('%s%s%s',inputpath,filesep,bindatalist(j).name);
        load(filename);
   
        MovieBinDataArray(i) = BinData;
        clear('BinData');
        i=i+1;
    end
end

return;
end
