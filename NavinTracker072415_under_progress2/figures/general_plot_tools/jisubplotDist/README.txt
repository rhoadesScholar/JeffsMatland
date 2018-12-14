JISUBPLOT Distribution
8/30/06
John Iversen
iversen@nsi.edu


OVERVIEW: Enhanced replacement for SUBPLOT

      Problem:
          Multi-axis plotting (using SUBPLOT) is great and essential, but has
          shortcomings. The main one is that keeping track of the axis indexes
          can be tedious if you want to do anything more elaborate than plotting
          in row-order. In addition, the size of all axes are the same, and
          spacing is not adjustable.

      Solution: JISUBPLOT + NEXTPLOT
          What you might really want is to set up a grid of subplots once and
          then just tell the figure when you want to move to the next plot,
          letting it take care of the details for you.

          That's what the pair of functions JISUBPLOT and NEXTPLOT can do.

          You can move by row, or by column, or arbitrarily. You can create
          subplots of different sizes. Finally, wouldn't it be nice if
          when you changed a figure's orientation (e.g. orient tall),
          it actually changed shape to reflect that?

      Examples:

	  %% the basic idea
          figure
          jisubplot(4,2,1)        % can be used just like SUBPLOT
          plot(X)
          nextplot                % advance to next axis
          plot(something_else)
          nextplot
          plot(some_other_thing)

          nextplot('newRow')      % start a new row of axes
          plot(something_new)
          nextplot('byCol')       % move down columns
           etc...

          %% jisubplot / nextplot is especially useful in loops
          %%   it will extend to new figures automatically
          figure
          jisubplot(4,4,0) 	    %setup figure, but don’t make the first axis
          for idx = 1:32,
              nextplot	('bycol')
              title(num2str(idx))
              plot(data(idx,:))
          end

          %% a more complete usage: specify orientation, plot spacing and fontsize
          %%  figure window is sized appropriately for orientation
          figure
          jisubplot(5,3,0,'tall',[.3 .3],'fontsize',9)
          nextplot

      Run JISUBPLOTDEMO for executable examples of more advanced usage.


Distribution includes:

jisubplot.m          -- setup figure for automated multi-pane layout
nextplot.m           -- automatically advance to next pane

currentplotis.m      -- test location of current axis

jisubplotdemo.m      -- demonstration of usage

And the following general utility files (used by nextplot)
These are used for parameter/value argument parsing, 
	and may be generally of use.

isparam.m            -- test for presence of a parameter
getparam.m           -- get values following a parameter
strmatch_mixed.m     -- strmatch that can be used on cell arrays with 
                          non-string elements
                          useful when parsing parameter/value lists



