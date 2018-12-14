function nobj=findneighbors(neuron1,neuron2,max_hops)
%FINDNEIGHBORS(neuron1,max_hops)
%
%find all neighbors of neuron1
%in maxhops or fewer hops  (maxhops cannot exceed 4)
%
%.if particular left or right suffix is not specified in neuron names,
%the search will be performed for all possible L/R combinations
%
%example: findneighbors('ASH',2);
%will give pathways for ASHL->AWCL, ASHR->ASHR, ASHR->AWCL, and ASHL->AWCR
%
%.synapses can only be traversed in one direction, gap junctions in either
%
%.needs NeuronConnect.xls in same directory (get latest from WormAtlas.org)
%
%Saul Kato
%110531
%

if nargin<3
    max_hops=1;
end

if nargin>1
    neuron2=upper(neuron2);
end

if nargin<1
    neuron1='AWCL';
end

neuron1=upper(neuron1);




verblist={'syn','syp','gap'};
%load database
[num,txt,raw] = xlsread('NeuronConnect.xls','','','basic');
%disp(' ');
%disp(['FINDING NEIGHBORS FOR ' neuron1 ', max ' num2str(max_hops) ' hops.']);
%disp('(syn=synapse, syp=polyadic synapse, gap=gap junction)');
%disp(' ');

%preprocess database
txt(1,:)=[];  %delete header
numrows=size(num,1);
verb=zeros(numrows,1);
for i=1:numrows
    if strcmp(txt{i,3},'S')  
        verb(i)=1;
    elseif strcmp(txt{i,3},'Sp')
        verb(i)=2;
    elseif strcmp(txt{i,3} ,'EJ')
        verb(i)=3;
    end
end

reverb=zeros(numrows,1);
for i=1:numrows
    if strcmp(txt{i,3},'R')  
        reverb(i)=1;
    elseif strcmp(txt{i,3},'Rp')
        reverb(i)=2;
    elseif strcmp(txt{i,3} ,'EJ')
        reverb(i)=3;
    end
end

neuron1L=[neuron1 'L'];
neuron1R=[neuron1 'R'];

for i=1:numrows
    if strcmp(txt(i,1),neuron1)
        firstneuron={neuron1}; break;
    else
        firstneuron={};
    end
end
        
t=0;
for i=1:numrows
    if strcmp(txt(i,1),neuron1L)
        firstneuron={firstneuron{:}, neuron1L}; break
    end
end

for i=1:numrows
     if strcmp(txt(i,1),neuron1R)
        firstneuron={firstneuron{:}, neuron1R}; break
    end
end   


for ii=1:length(firstneuron)
        %disp(' ');
        %disp('------------------------------');
        %disp(['||       ' firstneuron{ii} ]);
        nobj(ii)=jamfunk(firstneuron{ii},max_hops);
end

function snobj=jamfunk(n1,maxhops)
    
    
snobj.n=n1;
m=1; clear numsyn;
%disp('one hop paths:');
%find 1-hop paths
for i=1:numrows
    if strcmp(n1,txt(i,1))
            if verb(i)~=0 && verb(i)~=3
                %plot
                p{m}=[txt{i,1} ' -' num2str(num(i)) verblist{verb(i)} '-> ' txt{i,2} ...
                  ];
                numsyn(m)=num(i);
                %disp(p{m});
                
                %write into nobj
                snobj.downstream{m}=txt{i,2};
                snobj.downjunction{m}=verblist{verb(i)};
                snobj.downstrength(m)=num(i);
                
                m=m+1;
                
                
            end
    end
end


%if (m==1) disp('none'); else disp([num2str(m-1) ' downstream neighbors found.']); end;

%disp('---');
m=1;
for i=1:numrows
        if strcmp(n1,txt(i,2)) 
            if verb(i)~=0  && verb(i)~=3
                p{m}=[txt{i,1} ' -' num2str(num(i)) verblist{verb(i)} '-> ' txt{i,2} ...
                  ];
                numsyn(m)=num(i);
                %disp(p{m});
                
                %write into nobj
                snobj.upstream{m}=txt{i,1};
                snobj.upjunction{m}=verblist{verb(i)};
                snobj.upstrength(m)=num(i);
                
                
                m=m+1;
            end
    end
end

%if (m==1) disp('none'); else disp([num2str(m-1) ' upstream neighbors found.']); end;
%disp('---GAP JUNCTIONS---');
%write out gap junctions
m=1;
for i=1:numrows
    if strcmp(n1,txt(i,2))
        if verb(i)==3
        
        p{m}=[txt{i,1} ' -' num2str(num(i)) verblist{verb(i)} '-> ' txt{i,2}];
                        %disp(p{m});

            snobj.gapneighbor{m}=txt{i,1};
            snobj.gapstrength(m)=num(i);
      %  elseif strcmp(n1,txt(i,1))
      %      snobj.gapneighbor{m}=txt{i,2};
      %      snobj.gapstrength(m)=num(i);
              m=m+1;
        end

    end
end


%%
%find 2-hop paths

if maxhops>1  %2 hops
    %disp(' ');
   % disp('two hop paths:');
    n=1;
    for i=1:numrows
        if strcmp(n1,txt(i,1))
            for j=1:numrows  
                if strcmp(n2,txt(j,2)) && strcmp(txt(j,1),txt(i,2))
                    if verb(i)~=0 && verb(j)~=0
                        pp{n}=[txt{i,1} ' -' num2str(num(i)) verblist{verb(i)} '-> '...
                            txt{i,2}  ' -' num2str(num(j)) verblist{verb(j)} '-> ' txt{j,2}];
                        numpp1(n)=num(i);
                        numpp2(n)=num(j);
                        %disp(pp{n});
                        n=n+1;
                    end
                end
            end
        end
    end
    %if (n==1) disp('none');  else disp([num2str(n-1) ' 2-hop paths found.']); end;
end

%%
%%find 3-hop paths

if maxhops>2 %3 hops
    %disp(' ');
    %disp('three hop paths:');
    
    c2=1;
    for i=1:numrows
        if strcmp(n1,txt(i,1))
            if verb(i)~=0
                ppp_2{c2}=txt(i,2);
                ppp_12{c2}=[num2str(num(i)) verblist{verb(i)}];
                c2=c2+1;
            end
        end
    end
    
    c3=1;
    for i=1:numrows
        if strcmp(n2,txt(i,2))
            if reverb(i)~=0
                ppp_3{c3}=txt(i,1);
                ppp_34{c3}=[num2str(num(i)) verblist{reverb(i)}];
                c3=c3+1;
            end
        end
    end
   c2=c2-1;
   c3=c3-1;
    
    q=1;
    for c=1:c2
        for cc=1:c3
            for i=1:numrows
                if strcmp(ppp_2{c},txt(i,1)) && strcmp(ppp_3{cc},txt(i,2))
                    if verb(i)~=0
                        ppp{q}=[n1 ' -' ppp_12{c} '-> ' txt{i,1} ...
                            ' -' num2str(num(i)) verblist{verb(i)} '-> ' txt{i,2} ...
                            ' -' ppp_34{cc} '-> ' n2];
                        %disp(ppp{q});
                        q=q+1;
                    end
                end
            end   
        end
    end
    %if (q==1) disp('none'); else disp([num2str(q-1) ' 3-hop paths found.']); end;
end
    
end %jamfunk

end %findpaths