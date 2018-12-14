% performs analysis of the worm body from the Images in a continous Track,
% without missing frames or a ring filtering
% identifies the ends of the body
% assigns head and tail based on State classification

function Track = worm_head_tail2(Track)

if(~isfield(Track, 'body_contour'))
    return;
end

fwd_code = num_state_convert('fwd');
srev_code = num_state_convert('srev');
lrev_code = num_state_convert('lrev');

tracklength = length(Track.State);

step = Track.FrameRate;

% just the forward frames
% identify the first head following start and reorientations with the midbody
% of i+step
% then, head is the closest to head-1 until a reversal

% for forward 

for(i=1:tracklength)
    
    
    if(Track.body_contour(i).midbody > 0)
        
        bodyend_indicies = [1 length(Track.body_contour(i).x)];
        
        head_index=0;
        tail_index=0;
        
        i_step = i+step;
        
        % determine head vs tail based on movement
        
        if(i<tracklength-(Track.FrameRate-1)) % head is the body-end closest to the midbody of i+step if fwd
            
            if(Track.State(i)==fwd_code && Track.State(i_step)==fwd_code )
                % head
                if(~isempty(bodyend_indicies))
                    mindist=1e10;
                    local_head_index=1;
                    for(q=1:length(bodyend_indicies))
                        
                        %if( Track.body_contour(i_step).midbody == 0)
                            xval = Track.SmoothX(i_step);
                            yval = Track.SmoothY(i_step);
                        %else
                        %    xval = Track.body_contour(i_step).x(Track.body_contour(i_step).midbody);
                        %    yval = Track.body_contour(i_step).y(Track.body_contour(i_step).midbody);
                        %end

                          dist_sqrd = ( Track.body_contour(i).x(bodyend_indicies(q)) - xval )^2 + ...
                            ( Track.body_contour(i).y(bodyend_indicies(q)) - yval )^2;
                        
                        if(dist_sqrd < mindist)
                            mindist = dist_sqrd;
                            local_head_index=q;
                        end
                    end
                    head_index = bodyend_indicies(local_head_index);
                    bodyend_indicies(local_head_index)=[];
                    
                    % tail
                    if(length(bodyend_indicies)==1)
                        local_tail_index=1;
                        tail_index = bodyend_indicies(local_tail_index);
                        bodyend_indicies(local_tail_index)=[];
                    end
                end
            end
            
            % tail is the body-end closest to the centroid of
            % i+step if rev % midbody, not centroid
            if( (floor(Track.State(i))==srev_code || floor(Track.State(i))==lrev_code) && ...
                    (floor(Track.State(i_step))==srev_code || floor(Track.State(i_step))==lrev_code) )
                if(~isempty(bodyend_indicies))
                    mindist=1e10;
                    local_tail_index=1;
                    for(q=1:length(bodyend_indicies))
                        
                        %if( Track.body_contour(i_step).midbody == 0)
                            xval = Track.SmoothX(i_step);
                            yval = Track.SmoothY(i_step);
                        %else
                        %    xval = Track.body_contour(i_step).x(Track.body_contour(i_step).midbody);
                        %    yval = Track.body_contour(i_step).y(Track.body_contour(i_step).midbody);
                        %end

                        dist_sqrd = (Track.body_contour(i).x(bodyend_indicies(q)) - xval )^2 + ...
                            (Track.body_contour(i).y(bodyend_indicies(q)) - yval )^2;
                        
                        if(dist_sqrd < mindist)
                            mindist = dist_sqrd;
                            local_tail_index=q;
                        end
                    end
                    tail_index = bodyend_indicies(local_tail_index);
                    bodyend_indicies(local_tail_index)=[];
                    
                    if(length(bodyend_indicies)==1)
                        local_head_index=1;
                        head_index = bodyend_indicies(local_head_index);
                        bodyend_indicies(local_head_index)=[];
                    end
                end
            end
            
        end
        
        % head is the body-end closest to the previous head
        % tail is the body-end closest to the previous tail
        if(i>1  && (head_index == 0 || tail_index == 0)) % bodyend closest to previous bodyend
            
            % done in this manner in case of three potential body-ends
            % head
            if(~isempty(bodyend_indicies))
                if(head_index == 0 && Track.body_contour(i-1).head > 0)
                    mindist=1e10;
                    local_head_index=1;
                    for(q=1:length(bodyend_indicies))
                        dist_sqrd = (Track.body_contour(i).x(bodyend_indicies(q)) - Track.body_contour(i-1).x(Track.body_contour(i-1).head))^2 + ...
                            (Track.body_contour(i).y(bodyend_indicies(q)) - Track.body_contour(i-1).y(Track.body_contour(i-1).head))^2;
                        if(dist_sqrd < mindist)
                            mindist = dist_sqrd;
                            local_head_index=q;
                        end
                    end
                    head_index = bodyend_indicies(local_head_index);
                    bodyend_indicies(local_head_index)=[];
                    
                    if(tail_index == 0)
                        if(length(bodyend_indicies)==1)
                            local_tail_index=1;
                            tail_index = bodyend_indicies(local_tail_index);
                            bodyend_indicies(local_tail_index)=[];
                        end
                    end
                end
            end
            
            % tail
            if(~isempty(bodyend_indicies))
                if(tail_index == 0 && Track.body_contour(i-1).tail > 0)
                    mindist=1e10;
                    local_tail_index=1;
                    for(q=1:length(bodyend_indicies))
                        dist_sqrd = (Track.body_contour(i).x(bodyend_indicies(q)) - Track.body_contour(i-1).x(Track.body_contour(i-1).tail))^2 + ...
                            (Track.body_contour(i).y(bodyend_indicies(q)) - Track.body_contour(i-1).y(Track.body_contour(i-1).tail))^2;
                        if(dist_sqrd < mindist)
                            mindist = dist_sqrd;
                            local_tail_index=q;
                        end
                    end
                    tail_index = bodyend_indicies(local_tail_index);
                    bodyend_indicies(local_tail_index)=[];
                    
                    if(head_index == 0)
                        if(length(bodyend_indicies)==1)
                            local_head_index=1;
                            head_index = bodyend_indicies(local_head_index);
                            bodyend_indicies(local_head_index)=[];
                        end
                    end
                end
            end
        end
        
        
        % identified at least one end
        if(head_index >0 || tail_index >0)
            
            length_contour = length(Track.body_contour(i).x);
            
            reorder_flag=0;
            if(head_index >0 && tail_index >0)
                if(head_index ~= 1 && tail_index ~= length_contour)
                    reorder_flag = 1;
                end
            else
                if(head_index >0 && tail_index ==0)
                    if(head_index ~= 1)
                        reorder_flag = 1;
                    end
                else
                    if(head_index == 0 && tail_index >0)
                        if(tail_index ~= length_contour)
                            reorder_flag = 1;
                        end
                    end
                end
            end
            
            % the order of contour points needs to be reversed so it goes
            % head->>midbody>>->tail
            if(reorder_flag==1)
                Track.body_contour(i).x = Track.body_contour(i).x(end:-1:1);
                Track.body_contour(i).y = Track.body_contour(i).y(end:-1:1);
                t1 = head_index; head_index = tail_index; tail_index = t1;
            end
            
            Track.body_contour(i).head = head_index;
            Track.body_contour(i).tail = tail_index;
            % Track.body_contour(i).midbody = round(length_contour/2); % already defined
            Track.body_contour(i).neck = round(Track.body_contour(i).head + ((length_contour-1)/4) );
            Track.body_contour(i).lumbar = round(Track.body_contour(i).tail - ((length_contour-1)/4) );
            
        end
        
        clear('bodyend_indicies');
    end
    
end

return;
end
