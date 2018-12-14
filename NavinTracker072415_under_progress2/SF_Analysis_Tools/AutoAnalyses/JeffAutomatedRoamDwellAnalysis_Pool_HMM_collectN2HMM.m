function [dwellStateDurations roamStateDurations FractionDwelling FractionRoaming TrackInfo N2_TR N2_E] = JeffAutomatedRoamDwellAnalysis_Pool_HMM_collectN2HMM(allTracks,Date,Genotype)
    [ReversalInfo] = JeffgetAllRevs_HMM_longSpeed(allTracks);
    [dwellStateDurations roamStateDurations FractionDwelling FractionRoaming N2_TR N2_E] = GetHistsAndRatio_HMM_collectN2HMM(allTracks,Date,Genotype);
        
    TrackInfo = struct('dwell_state_durations',[],'roam_state_durations',[],'dwell_state_durations_incl_ends',[],'roam_state_durations_incl_ends',[],'Reversal_Info',[],'State_stability',[]);
    TrackInfo.dwell_state_durations = dwellStateDurations;
    TrackInfo.roam_state_durations = roamStateDurations;
    TrackInfo.Reversal_Info = ReversalInfo;
    
end