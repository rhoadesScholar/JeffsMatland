% class = '(?<!.Rev_)(upsilon|omega)' --> upsilon or omega no Rev
% class = '(upsilon|omega)' ---> any upsilon or omega
% class = '(.Rev)((?!_upsilon|_omega))' --> any rev not followed by an omeg or  upsilon
% class = '(.Rev)((_upsilon|_omega))' --> any rev  followed by an omeg or upsilon
% class = '(?<!.Rev_)(upsilon)' --> upsilon no Rev
% class = '(?<!.Rev_)(omega)' --> omega no Rev


function delta_dir = delta_dir_array(Tracks,class)

if(nargin<2)
    class='.';
end

delta_dir = [];
for(i=1:length(Tracks))
    for(j=1:length(Tracks(i).Reorientations))
        
        Tracks(i).Reorientations(j).class = strrep(Tracks(i).Reorientations(j).class,'.','_');
        
            if(~isempty(regexp(Tracks(i).Reorientations(j).class,class)))
                delta_dir = [delta_dir Tracks(i).Reorientations(j).delta_dir];
                Tracks(i).Reorientations(j).class
            end
        
    end
end

return;
end
