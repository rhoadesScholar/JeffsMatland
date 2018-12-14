function [fit_level, numWorms, numObjects, meanWormSize] = find_optimal_threshold(Movsubtract, target_numworms, inputlevel, obj_penalty_coeff)
% [fit_level, numWorms, numObjects, meanWormSize] = find_optimal_threshold(Movsubtract, target_numworms, inputlevel, obj_penalty_coeff)
% adjust level to minimize the difference between all objects (numObjects) to real worms (numWorms)

max_level = 0.5; % 0.75; % 0.36; % 0.36; % 0.12;
level_step = -0.005; % -0.0050; % -0.0025;

if(nargin<2)
    target_numworms = 0;
end

if(nargin<3)
    inputlevel = [];
end

if(nargin<4)
    obj_penalty_coeff = 1;
end
bestscore = 1e6;

level_start = max_level;
level_end = 0.0025;

if(nargin>2)
    if(~isempty(inputlevel))
        inputlevel = inputlevel(1);
        if(length(inputlevel)>1)
            obj_penalty_coeff = inputlevel(2);
        end
        input_level_start = min(level_start, (inputlevel + 5*abs(level_step)));
        input_level_end = max(level_end, (inputlevel - 5*abs(level_step)));
        level_start = input_level_start;
        level_end = input_level_end;
        
        fit_level = inputlevel;
    else
        fit_level = graythresh(Movsubtract);
    end
    
    
    [numWorms, numObjects, meanWormSize] = find_numWorms(Movsubtract, fit_level);
    
else
    level = graythresh(Movsubtract);
    [CurrentNumWorms, CurrentNumObjects, mws] = find_numWorms(Movsubtract, level);
    
    fit_level = level;
    numWorms = CurrentNumWorms;
    numObjects = CurrentNumObjects;
    meanWormSize = mws;
    
    if(target_numworms==0)
        score = abs(CurrentNumWorms - CurrentNumObjects);
    else
        score = abs(CurrentNumWorms - target_numworms) + obj_penalty_coeff*abs(CurrentNumWorms - CurrentNumObjects);
    end
    if(CurrentNumWorms == 0)
        score = score + 100000;
    end
    if(score < bestscore)
        bestscore = score;
        fit_level = level;
        numWorms = CurrentNumWorms;
        numObjects = CurrentNumObjects;
        meanWormSize = mws;

        if(bestscore == 0) %bail out....we've found a good level
            return;
        end
    end
    % disp([level CurrentNumWorms CurrentNumObjects score])
end

for(level=level_start:level_step:level_end)
    [CurrentNumWorms, CurrentNumObjects, mws] = find_numWorms(Movsubtract, level);
    if(target_numworms==0)
        score = abs(CurrentNumWorms - CurrentNumObjects);
    else
        score = abs(CurrentNumWorms - target_numworms) + obj_penalty_coeff*abs(CurrentNumWorms - CurrentNumObjects);
    end

    if(CurrentNumWorms == 0)
        score = score + 100000;
    end
    if(score < bestscore)
        bestscore = score;
        fit_level = level;
        numWorms = CurrentNumWorms;
        numObjects = CurrentNumObjects;
        meanWormSize = mws;

        if(bestscore == 0) %bail out....we've found a good level
            return;
        end
    end
    % disp([level CurrentNumWorms CurrentNumObjects score])
end

if(nargin>2) % re-sample the whole range of levels since the focused one didn't work
    if(~isempty(inputlevel))
        
        if(bestscore==0)
            return;
        end
        
        level_start = max_level;
        level_end = 0.0025;

        for(level=level_start:level_step:level_end)

            if(level > input_level_start || level < input_level_end)

                [CurrentNumWorms, CurrentNumObjects, mws] = find_numWorms(Movsubtract, level);
                if(target_numworms==0)
                    score = abs(CurrentNumWorms - CurrentNumObjects);
                else
                    score = abs(CurrentNumWorms - target_numworms) + obj_penalty_coeff*abs(CurrentNumWorms - CurrentNumObjects);
                end

                if(CurrentNumWorms == 0)
                    score = score + 100000;
                end
                if(score < bestscore)
                    bestscore = score;
                    fit_level = level;
                    numWorms = CurrentNumWorms;
                    numObjects = CurrentNumObjects;
                    meanWormSize = mws;

                    if(bestscore==0) %bail out....we've found a good level
                        return;
                    end
                end
                % disp([level CurrentNumWorms CurrentNumObjects score])
            end
        end
    end
end

return;
end

