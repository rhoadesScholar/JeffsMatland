function StimulusRegions = getStimulusRegions(stimulus_vector)

StimulusPoints = find(stimulus_vector > 0);
StimulusRegions = [];

if ( numel(StimulusPoints) <= 0 )
    return;
end

StimulusRegions(1,1) = StimulusPoints(1);
StimulusRegions(1,2) = StimulusPoints(1);

StimulusRegionNum = 1;

for i = 2:length(StimulusPoints)
   if (  StimulusPoints(i) == StimulusPoints(i-1) + 1 )
       StimulusRegions(StimulusRegionNum,2) = StimulusPoints(i);
   else
       StimulusRegionNum = StimulusRegionNum + 1;
       StimulusRegions(StimulusRegionNum,1) = StimulusPoints(i);
       StimulusRegions(StimulusRegionNum,2) = StimulusPoints(i);
   end
end

return;

end