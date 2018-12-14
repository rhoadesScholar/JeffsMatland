function status = save_Tracks(filename, Tracks)

status = 0;

varnamestring = inputname(2);

eval(sprintf('%s = Tracks;',varnamestring));

save(filename, varnamestring);

s = dir(filename);

% failed to write ...
if(s.bytes <= 2000)
    disp(sprintf('%s failed to save  ... will try v7.3 %s',filename,timeString));
    rm(filename);
    save(filename, varnamestring,'-v7.3');
    s = dir(filename);
    if(s.bytes <= 2000)
        disp(sprintf('%s failed to save with v7.3 %s',filename,timeString));
        return;
    end
end

status = 1;

return;
end
