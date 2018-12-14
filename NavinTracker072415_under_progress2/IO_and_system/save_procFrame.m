function status = save_procFrame(filename, procFrame)

status = 0;

save(filename, 'procFrame');

s = dir(filename);

% failed to write ... 
if(s.bytes <= 2000)
    disp(sprintf('%s failed to save ... will compress %s',filename,timeString)); 
    procFrame = compress_decompress_procFrame(procFrame);
    rm(filename);
    save(filename, 'procFrame');
    s = dir(filename);
    if(s.bytes <= 2000)
        disp(sprintf('%s failed to save after compression ... will try v7.3 %s',filename,timeString)); 
        rm(filename);
        save(filename, 'procFrame','-v7.3');
        s = dir(filename);
        if(s.bytes <= 2000)
            disp(sprintf('%s failed to save after compression and v7.3 %s',filename,timeString)); 
            return;
        end
    end
end

status = 1;

return;
end
