function [plotspikes, upsth] = arrangeSpikeTimes(sptimes, events, histedges, samprate)
    % Arrange spikes into PSTH based on eventTimes and histedges. Samprate
    % input optional (3e4 Hz by default).

    if nargin <4
        samprate = 3e4;
    end

    mem_lim = 15e9;

    ntrials = size(events,1);
    sptimes = double(sptimes);

    upsth = zeros(ntrials, length(histedges));
    plotspikes = [];

    if ntrials*length(sptimes)*2*8 > mem_lim
        for t = 1 : ntrials
            spikes = sptimes((sptimes >= (events(t,1)+histedges(1)*samprate)) & (sptimes <= (events(t,1)+histedges(end)*samprate)));
            spikes = (spikes - events(t,1))/samprate;
            upsth(t,:) = histc(spikes, histedges);

            plotspikes = [plotspikes [spikes'; spikes'*0+t]];
        end
        upsth = upsth(:,1:end-1);
    else
        spikes = sptimes(sptimes >= min(events(:))+histedges(1)*samprate & sptimes <= (max(events(:))+histedges(end)*samprate));
        d_spev = (repmat(spikes, 1, ntrials) - repmat(events(:,1)', length(spikes), 1)) / samprate;
        [upsth, bin] = histc(d_spev, histedges);
        upsth = upsth(1:end-1,:)';

        if isempty(upsth)
            upsth = zeros(ntrials, length(histedges)-1);
        end

        trmat = repmat(1:ntrials, length(spikes), 1);
        plotspikes = [d_spev(bin(:) > 0)'; trmat(bin(:) > 0)'];
    end

    return
end
    
