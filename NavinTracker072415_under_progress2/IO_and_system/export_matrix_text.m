function char_matrix = export_matrix_text(inp_matr, filename)
% export_matrix_text(inp_matr, filename)
% saves matrix inp_matr to filename.txt

if(nargin<1)
    disp('char_matrix = export_matrix_text(inp_matr, filename)')
    return;
end

file_ptr = [];
if(nargin>1)
    [path, name, ext] = fileparts(filename);
    if(isempty(ext))
        filename = sprintf('%s.txt',filename);
    end
    file_ptr = fopen(filename,'wt');
end

char_matrix = num2str(inp_matr);

for(i=1:size(inp_matr,1))
    datastring = sprintf('');
    
    for(j=1:size(inp_matr,2))
        datastring = sprintf('%s\t%f',datastring, inp_matr(i,j));
    end
    
    if(~isempty(file_ptr))
        fprintf(file_ptr,'%s\n',datastring);
    end
 
end
if(~isempty(file_ptr))
    fclose(file_ptr);
end

return;
end
