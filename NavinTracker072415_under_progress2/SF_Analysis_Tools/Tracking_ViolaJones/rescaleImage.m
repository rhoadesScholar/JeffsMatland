function dblImageS255 = rescaleImage(oldImage)

originalMinValue = double(31);
originalMaxValue = double(500);
originalRange = originalMaxValue - originalMinValue;

% Get a double image in the range 0 to +255
desiredMin = 0;
desiredMax = 255;
desiredRange = desiredMax - desiredMin;
dblImageS255 = desiredRange * (double(oldImage) - originalMinValue) / originalRange + desiredMin;
dblImageS255 = uint8(dblImageS255);

end

