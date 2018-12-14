function normalTracks = normalizeSpeedsByN2(allTracks, combine, varargin)%allTracks is cell array of all tracks from each day, combine is boolean or cell of strains to combine
normalTracks = struct();

if nargin > 2
    seperate = varargin{1};
end
if nargin > 3
    dates = varargin{2};
end
for d = 1:length(allTracks)%d for day
    strains = fields(allTracks{d});
%     N2s = strains(contains(strains,'N2'));%make sure only one N2 group a day
%     tempTracks.N2 = allTracks{d}.(N2s{1});
%     [~, N2avgs] = analyzeRefeed(tempTracks);
%     clear tempTracks;
%     normFactor = min([N2avgs.N2.Speed]);
    for s = 1:length(strains)%s for strain
%         speeds = arrayfun(@(track) track.Speed/normFactor, allTracks{d}.(strains{s}), 'UniformOutput', false);
%         for t = 1:length(speeds)
%             allTracks{d}.(strains{s})(t).Speed = speeds{t};
%         end
        
        if iscell(combine) && max(contains(combine,strains{s}))
            if (isfield(normalTracks,strains{s}))
               normalTracks.(strains{s}) = addNextTracks(normalTracks.(strains{s}), allTracks{d}.(strains{s}));
%                oldNormalTracks = normalTracks.(strains{s});
%                try
%                    normalTracks.(strains{s}) = [oldNormalTracks allTracks{d}.(strains{s})];
%                catch
%                    newTracks = allTracks{d}.(strains{s});
%                    newFields = fields(allTracks{d}.(strains{s}));
%                    oldFields = fields(oldNormalTracks);
%                    if length(newFields) > length(oldFields)
%                        newTracks = rmfield(newTracks, setdiff(newFields, oldFields));
%                    elseif length(oldFields) > length(newFields)
%                        oldNormalTracks = rmfield(oldNormalTracks, setdiff(oldFields, newFields));
%                    end 
%                    try
%                         normalTracks.(strains{s}) = [oldNormalTracks newTracks];
%                    catch
%                        newTracks = allTracks{d}.(strains{s});
%                        newFields = fields(allTracks{d}.(strains{s}));
%                        oldFields = fields(oldNormalTracks);
%                        if length(newFields) > length(oldFields)
%                            newTracks = rmfield(newTracks, setdiff(newFields, oldFields));
%                        elseif length(oldFields) > length(newFields)
%                            oldNormalTracks = rmfield(oldNormalTracks, setdiff(oldFields, newFields));
%                        end
%                        normalTracks.(strains{s}) = [oldNormalTracks newTracks];
%                    end
%                 end
            else
               normalTracks.(strains{s}) = allTracks{d}.(strains{s});
            end
        elseif ~iscell(combine) && combine
            if (isfield(normalTracks,strains{s}))
               normalTracks.(strains{s}) = addNextTracks(normalTracks.(strains{s}), allTracks{d}.(strains{s}));
            else
               normalTracks.(strains{s}) = allTracks{d}.(strains{s});
            end
        elseif (nargin > 2) && max(contains(seperate,strains{s}))
            if nargin > 3
                date = dates{d};
            else
                date = d;
            end
            if (isfield(normalTracks,sprintf('%s_%s', strains{s}, date)))
               oldNormalTracks = normalTracks.(sprintf('%s_%s', strains{s}, date));
               try
                   normalTracks.(sprintf('%s_%s', strains{s}, date)) = [oldNormalTracks allTracks{d}.(strains{s})];
               catch
                   newTracks = allTracks{d}.(strains{s});
                   newFields = fields(allTracks{d}.(strains{s}));
                   oldFields = fields(oldNormalTracks);
                   if length(newFields) > length(oldFields)
                       newTracks = rmfield(newTracks, setdiff(newFields, oldFields));
                   elseif length(oldFields) > length(newFields)
                       oldNormalTracks = rmfield(oldNormalTracks, setdiff(oldFields, newFields));
                   end 
                   normalTracks.(sprintf('%s_%s', strains{s}, date)) = [oldNormalTracks newTracks];
                end
            else
               normalTracks.(sprintf('%s_%s', strains{s}, date)) = allTracks{d}.(strains{s});
            end
        end
    end    
end

% if ~iscell(combine) && ~combine
%     normalTracks = allTracks{:};
% end

strains = fields(normalTracks);
N2s = contains(strains,'N2');
strainOrder = [{strains{N2s}} {strains{~N2s}}];
normalTracks = orderfields(normalTracks, strainOrder);

return
end

function tracks = addNextTracks(oldNormalTracks, newTracks)
    try
       tracks = [oldNormalTracks newTracks];
    catch
        success = false;
        count = 0;
       while ~success && count < 3
            newFields = fields(newTracks);
            oldFields = fields(oldNormalTracks);
           if length(newFields) > length(oldFields)
               newTracks = rmfield(newTracks, setdiff(newFields, oldFields));
           elseif length(oldFields) > length(newFields)
               oldNormalTracks = rmfield(oldNormalTracks, setdiff(oldFields, newFields));
           end 
           try
               count = count + 1;
                tracks = [oldNormalTracks newTracks];
                success = true;
           end
       end
   end
end