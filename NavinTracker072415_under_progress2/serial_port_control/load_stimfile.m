function stimulus = load_stimfile(stimfile, experiment_flag)
% stimulus = load_stimfile(stimfile, experiment_flag)

if(nargin<2)
    experiment_flag=0;
end

% if the stimfile is already a stimulus
if(isnumeric(stimfile))
    stimulus = stimfile;
    return;
end

% the inputed blah.stim does not exist, so look for the .txt file ...
if(~file_existence(stimfile))
    [pathstr, FilePrefix] = fileparts(stimfile);
    if(~isempty(pathstr))
        stimfile = sprintf('%s%s%s.txt',pathstr,filesep,FilePrefix);
    else
        stimfile = sprintf('%s.txt',FilePrefix);
    end
end

if(isempty(findstr(stimfile,'.stim'))) % is not a .stim file
    stimulus = txt_to_stim(stimfile, experiment_flag);
    return;
end


fp = fopen(stimfile,'r');

max_num_words = 0;
tline = fgetl(fp);
i=0;
while(ischar(tline))
    
    i=i+1;
    
    [words, num_words] = words_from_line(tline, '%');
    
    if(num_words > max_num_words)
        max_num_words = num_words;
    end
    
    clear('words');
    clear('num_words');
    tline = fgetl(fp);
end
fclose(fp);

stimulus = zeros(i,max_num_words) + NaN;

fp = fopen(stimfile,'r');
tline = fgetl(fp);
i=0;
while(ischar(tline)) 
    i=i+1;
    
    [words, num_words] = words_from_line(tline, '%');
    
    % this "stim" file is actually a txt file
    for(j=1:num_words)
        if(~isempty(find_string_in_cell_array(words,'on')))
            clear('stimulus');
            stimulus = txt_to_stim(stimfile);
            return;
        end
        if(~isempty(find_string_in_cell_array(words,'off')))
            clear('stimulus');
            stimulus = txt_to_stim(stimfile);
            return;
        end
        if(~isempty(find_string_in_cell_array(words,'min')))
            clear('stimulus');
            stimulus = txt_to_stim(stimfile);
            return;
        end
        if(~isempty(find_string_in_cell_array(words,'sec')))
            clear('stimulus');
            stimulus = txt_to_stim(stimfile);
            return;
        end
    end
    
    
    for(j=1:num_words)
        stimulus(i,j) = sscanf(char(words{j}),'%f');
    end
    
    clear('words');
    clear('num_words');
    tline = fgetl(fp);
end
fclose(fp);

return;
end
