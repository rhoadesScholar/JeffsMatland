% set NAVIN_CODE_PATH to the root of the source code tree
% pdftk
% cp(sprintf('%s%sput_into_C_windows_system32%spdftk.exe',NAVIN_CODE_PATH,filesep,filesep), 'C:\WINDOWS\System32\pdftk.exe');
%
% ffmpeg
% cp(sprintf('%s%sput_into_C_windows_system32%sffmpeg.exe',NAVIN_CODE_PATH,filesep,filesep), 'C:\WINDOWS\System32\ffmpeg.exe');
%

function navin_code_setup

global SCOPE_NUMBER;
if(isempty(SCOPE_NUMBER))
    SCOPE_NUMBER = [];
end

NAVIN_CODE_PATH = '\\Tantalus\Pelops\under_progress2';

% ncp = non_core_path();
% rmpath(ncp);

restoredefaultpath;

addpath(genpath(NAVIN_CODE_PATH));


regionprops_path = sprintf('%s%simage_processing%scustom_regionprops%s',NAVIN_CODE_PATH,filesep,filesep,filesep);

% remove the custom_regionprops from the path
path_to_del = sprintf('%scustom_regionprops',regionprops_path);
rmpath(path_to_del);
path_to_del = sprintf('%scustom_regionprops_R14',regionprops_path);
rmpath(path_to_del);
path_to_del = sprintf('%scustom_regionprops_32_2011',regionprops_path);
rmpath(path_to_del);
path_to_del = sprintf('%scustom_regionprops_64',regionprops_path);
rmpath(path_to_del);
path_to_del = sprintf('%scustom_regionprops_default',regionprops_path);
rmpath(path_to_del);


% % for student version 7.0.1 version14
% if(~isempty((findstr(version('-release'),'14'))))
%     new_custom_regionprops = sprintf('%scustom_regionprops_R14',regionprops_path);
%     addpath(new_custom_regionprops);
%     return
% end

% for Windows 32-bit
if(~isempty((findstr(mexext,'32'))) && ~isempty((findstr(version('-release'),'2011'))))
    new_custom_regionprops = sprintf('%scustom_regionprops_32_2011',regionprops_path);
    addpath(new_custom_regionprops);
    return
end

% for windows 64-bit
if(~isempty((findstr(mexext,'64'))))
    new_custom_regionprops = sprintf('%scustom_regionprops_64',regionprops_path);
    addpath(new_custom_regionprops);
    return
end

% other version
new_custom_regionprops = sprintf('%scustom_regionprops_default',regionprops_path);
addpath(new_custom_regionprops);


return;
end

