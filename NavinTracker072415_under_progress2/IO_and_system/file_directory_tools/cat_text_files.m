% equivalent to unix cat fileA fileB > fileC

function cat_text_files(fileA, fileB, fileC)


tempA = sprintf('%s',tempname);
tempB = sprintf('%s',tempname);
tempC = sprintf('%s',tempname);



copyfile(fileA, tempA);
copyfile(fileB, tempB);

currentdir = pwd;

cd(tempdir);

command = sprintf('type %s > %s',tempA, tempC);
run_command(command);

command = sprintf('type %s >> %s',tempB, tempC);
run_command(command);

cd(currentdir);

copyfile(tempC, fileC);

rm(tempA);
rm(tempB);
rm(tempC);

return;
end
 