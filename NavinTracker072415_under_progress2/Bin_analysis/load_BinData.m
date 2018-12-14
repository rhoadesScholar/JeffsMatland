function outBinData = load_BinData(filename)

if(~ischar(filename))
    outBinData = orderfields(update_old_BinData(filename));
    return;
end

if(file_existence(filename)==0)
    outBinData = initialize_BinData;
    return;
end

load(filename);

outBinData = orderfields(update_old_BinData(BinData));

return;
end
