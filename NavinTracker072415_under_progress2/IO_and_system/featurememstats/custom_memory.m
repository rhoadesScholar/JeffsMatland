function mem = custom_memory

if(ispc)
   [~,mem] = memory; 
    return;
end

[~,m]=unix('vm_stat | grep free');
spaces=strfind(m,' ');
mem.PhysicalMemory.Available = str2num(m(spaces(end):end))*4096;

return;
end
