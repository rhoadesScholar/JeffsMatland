%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NAME: magnifyOnFigure_examples
% 
% AUTHOR: David Fernandez Prim (david.fernandez.prim@gmail.com)
%
% PURPOSE: Shows the funcionality of 'magnifyOnFigure'
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;
clear all
close all

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Default interactive mode
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all;
disp( sprintf('This is the default interactive operation mode of ''magnifyOnFigure''') ) 
fig = figure;
hold on;
plot(rand(100,1), 'b'); plot(rand(300, 1), 'r'); 
grid on;
hold off;
magnifyOnFigure;
disp('Press a key...')
pause;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure handle passed as an input argument
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all;
disp( sprintf('The figure handle is here passes as an input argument.') ) 
fig = figure;
hold on;
plot(rand(100,1), 'b'); plot(rand(300, 1), 'r'); 
grid on;
hold off;
magnifyOnFigure(fig);
disp('Press a key...')
pause;


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% An axes handle passed as an input argument
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all;
disp( sprintf('How to specify the target axes in a subplot figure.') ) 
fig = figure; 
ax1 = subplot(2,1,1);
plot(rand(100,1), 'r');
grid on;
ax2 = subplot(2,1,2);
plot(rand(100,1), 'b');
grid on;
magnifyOnFigure(ax1);
disp('Press a key...')
pause;



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Properties (in interactive mode)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all;
disp( sprintf('Playing arround with the properties in interactive mode...') ) 
figHandler = figure;
hold on;
plot(rand(100,1), 'b'); plot(rand(300, 1), 'r'); 
grid on;
hold off; 
ylim([0 2]);
magnifyOnFigure(...
        figHandler,...
        'units', 'pixels',...
        'magnifierShape', 'ellipse',...
        'initialPositionSecondaryAxes', [326.933 259.189 164.941 102.65],...
        'initialPositionMagnifier',     [174.769 49.368 14.1164 174.627],...    
        'mode', 'interactive',...    
        'displayLinkStyle', 'straight',...        
        'edgeWidth', 2,...
        'edgeColor', 'black',...
        'secondaryAxesFaceColor', [0.91 0.91 0.91]... 
            ); 
disp('Press a key...')
pause;


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Properties (in manual mode)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all;
disp( sprintf('Or in manual mode.') ) 
figHandler = figure;
hold on;
plot(rand(100,1), 'b'); plot(rand(300, 1), 'r'); 
grid on;
hold off; 
ylim([0 2]);
magnifyOnFigure(...
        figHandler,...
        'units', 'pixels',...
        'initialPositionSecondaryAxes', [326.933 259.189 164.941 102.65],...
        'initialPositionMagnifier',     [174.769 49.368 14.1164 174.627],...    
        'mode', 'manual',...    
        'displayLinkStyle', 'straight',...        
        'edgeWidth', 2,...
        'edgeColor', 'black',...
        'secondaryAxesFaceColor', [0.91 0.91 0.91]... 
            ); 
disp('Press a key...')
pause;


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Working on images also
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all;
disp( sprintf('How the tool works on images.') ) 
h = figure; 
load clown; 
image(X); 
colormap(map) ; 
axis image
magnifyOnFigure(h, 'displayLinkStyle', 'straight',...
                    'EdgeColor', 'white',...
                    'magnifierShape', 'rectangle',...
                    'frozenZoomAspectratio', 'on',...
                    'edgeWidth', 2);
                
disp('Press a key...')
pause;
close all
                
             
