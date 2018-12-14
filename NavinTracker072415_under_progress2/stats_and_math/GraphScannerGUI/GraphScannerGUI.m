%GraphScannerGUI script builds GraphScannerGUI class 
% Use this script in order to start the program

% check whether a user is using MATLAB version 7.6 or newer
ver = version; 
ver = str2double(ver(strfind(version,'R')+1:strfind(version,'R')+4));
assert(~(ver < 2008) ,'GraphScannerGUI requires at least MATLAB version 7.6 (R2008a) or newer.');
try
    evalin('base','GSGUI.GraphScannerGUI;')
catch ME
    errordlg(ME.message,ME.identifier)
end
     