function num_worm_error = worm_threshold_error(Movsubtract, level)

[numWorms, numObjects] = find_numWorms(Movsubtract, level);
worm_error = abs(numWorms - numObjects);

return;
end

