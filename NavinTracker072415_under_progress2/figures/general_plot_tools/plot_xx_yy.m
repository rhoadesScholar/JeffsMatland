% modify this to make more general

function figure_with_two_axis_with_same_grid(x1,y1,x2,y2,x_num_of_grid,y_num_of_grid)
%figure_with_two_axis_with_same_grid plots two sets of 1D data on the same
%figure with two separate axis with the same grid.
%The code also checks if the x-axis data are the same, if the x-axis data
% are not the same, it draws an additional x-axis on the top of the figure.
% The two sets of data with their axes are drawn with two colors for ease of reading
% of the plot.
%
%Inputs:
%       x1:x-axis 1 D vector for set 1 data
%       y1:y-axis 1 D vector for set 1 data
%       x2:x-axis 1 D vector for set 2 data 
%       y2:y-axis 1 D vector for set 2 data 
%       x_num_of_grid: gridding for the x-axis data(optional, will be defaulted if not specified)
%       y_num_of_grid: gridding for the x-axis data(optional, will be defaulted if not specified)
%
%
%Example Usage 1 (x axis data are different):
%     x1 = [0:.3:40];
%     y1 = 6.*cos(x1)./(x1+2);
%     x2 = [1:.2:20];
%     y2 = x2.^2./x2.^3+2;
%     figure_with_two_axis_with_same_grid(x1,y1,x2,y2,3,4)
%
%
%Example Usage 2 (x axis data are the same):
%     x1 = [0:.3:40];
%     y1 = 6.*cos(x1)./(x1+2);
%     x2=x1;
%     y2=0.1.*y1.^2+y1;
%     figure_with_two_axis_with_same_grid(x1,y1,x1,y2,3,4)
%
%
%Example Usage 3 (x axis data are the same, and grid is not specified):
%     x1 = [0:.3:40];
%     y1 = 6.*cos(x1)./(x1+2);
%     x2=x1;
%     y2=0.1.*y1.^2+y1;
%     figure_with_two_axis_with_same_grid(x1,y1,x1,y2)
%
%
%                               Written by Nassim Khaled, 2011

if nargin<5
    x_num_of_grid=5;
    y_num_of_grid=5;
end

[m1,n1]=size(x1);
if m1>n1
    x1=x1';
    y1=y1';
end

[m2,n2]=size(x2);
if m2>n2
    x2=x2';
    y2=y2';
end

figure
if isequal(x1,x2)
   if length(y1)~=length(y2)
            'Error!! Your vectors y1 and y2 should be of the same length'
        close 
        return
   end
 
%Using low-level line and axes routines allows you to superimpose objects easily. 
%Plot the first data, making the color of the line and the corresponding x- and y-axis the same to more easily associate them.

hl1 = line(x1,y1,'Color','r','LineWidth',2);
ax1 = gca;
set(ax1,'XColor','r','YColor','r','LineWidth',2,'FontWeight','bold','FontSize',12,'FontName','Arial')

% Next, create another axes at the same location as the first, placing the x-axis on top and the y-axis on the right. 
% Set the axes Color to none to allow the first axes to be visible and color code the x- and y-axis to match the data.

ax2 = axes('Position',get(ax1,'Position'),...
           'YAxisLocation','right',...
           'Color','none',...
           'XColor','k','YColor','k','LineWidth',2,'FontWeight','bold','FontSize',12,'FontName','Arial');

% Draw the second set of data in the same color as the x- and y-axis.

hl2 = line(x1,y2,'Color','k','LineWidth',2,'Parent',ax2);

xlimits = get(ax1,'XLim');
ylimits = get(ax1,'YLim');
xinc = (xlimits(2)-xlimits(1))/x_num_of_grid;
yinc = (ylimits(2)-ylimits(1))/y_num_of_grid;

% Now set the tick mark locations.

set(ax1,'XTick',[xlimits(1):xinc:xlimits(2)],...
        'YTick',[ylimits(1):yinc:ylimits(2)])
  
xlimits = get(ax2,'XLim');
ylimits = get(ax2,'YLim');
xinc = (xlimits(2)-xlimits(1))/x_num_of_grid;
yinc = (ylimits(2)-ylimits(1))/y_num_of_grid;
    
    
set(ax2,'XTick',[xlimits(1):xinc:xlimits(2)],...
        'YTick',[ylimits(1):yinc:ylimits(2)])
grid on
box on

else
%Using low-level line and axes routines allows you to superimpose objects easily. 
%Plot the first data, making the color of the line and the corresponding x- and y-axis the same to more easily associate them.

hl1 = line(x1,y1,'Color','r','LineWidth',2);
ax1 = gca;
set(ax1,'XColor','r','YColor','r','LineWidth',2,'FontWeight','bold','FontSize',12,'FontName','Arial')

% Next, create another axes at the same location as the first, placing the x-axis on top and the y-axis on the right. 
% Set the axes Color to none to allow the first axes to be visible and color code the x- and y-axis to match the data.

ax2 = axes('Position',get(ax1,'Position'),...
           'XAxisLocation','top',...
           'YAxisLocation','right',...
           'Color','none',...
           'XColor','k','YColor','k','LineWidth',2,'FontWeight','bold','FontSize',12,'FontName','Arial');

% Draw the second set of data in the same color as the x- and y-axis.
size(x2)
size(y2)
hl2 = line(x2,y2,'Color','k','LineWidth',2,'Parent',ax2);

xlimits = get(ax1,'XLim')
ylimits = get(ax1,'YLim')
xinc = (xlimits(2)-xlimits(1))/x_num_of_grid;
yinc = (ylimits(2)-ylimits(1))/y_num_of_grid;

% Now set the tick mark locations.

set(ax1,'XTick',[xlimits(1):xinc:xlimits(2)],...
        'YTick',[ylimits(1):yinc:ylimits(2)])
  
xlimits = get(ax2,'XLim')
ylimits = get(ax2,'YLim')
xinc = (xlimits(2)-xlimits(1))/x_num_of_grid;
yinc = (ylimits(2)-ylimits(1))/y_num_of_grid;
    
    
set(ax2,'XTick',[xlimits(1):xinc:xlimits(2)],...
        'YTick',[ylimits(1):yinc:ylimits(2)])
grid on
end

    