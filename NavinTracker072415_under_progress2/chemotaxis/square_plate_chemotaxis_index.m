function [CI, num_in_left, num_in_right, num_neutral] = square_plate_chemotaxis_index(worms_in_grid)

left_box_columns = [1 2];
right_box_columns = [5 6];
neutral_box_columns = [3 4];
neutral_box_rows = [1 2 5 6];

num_in_left = round(sum(sum(worms_in_grid(:,left_box_columns))));
num_in_right = round(sum(sum(worms_in_grid(:,right_box_columns))));
num_neutral = round(sum(sum(worms_in_grid(neutral_box_rows, neutral_box_columns))));

CI = (num_in_left - num_in_right)/(num_in_left + num_in_right + num_neutral);

return;
end
