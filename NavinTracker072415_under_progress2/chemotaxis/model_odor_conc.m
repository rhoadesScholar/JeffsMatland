function [C, C_matrix] = model_odor_conc(input_r, input_t)
% C = model_odor_conc(r, t)
% returns the concentration of an odor (arbitary units) at distance r (mm) from
% the source at time t sec for r = 0->200 mm and t = 0 to 120 min (in sec)
% precalculates r_t_matrix at discrete values
% interpolates for off-grid values

C = 0;
C_matrix = [];

global Prefs;
Prefs = define_preferences(Prefs);
D = Prefs.model_diffusion_const;

persistent C_r_t_matrix;
persistent r;
persistent t;


if(nargin<1)
    C_r_t_matrix = [];
    r=[];
    t=[];
    return;
end

% depleting instantaneous point source
% C = exp(-input_r^2./(4*D*input_t))./((4*pi*D*input_t));
% return;

if(isempty(C_r_t_matrix))
    r = [1 5:5:200];
    t = [0.01 0.05 0.1 0.5 1 5:5:120*60];
    
    C_r_t_matrix = [];
    
    filename = 'C_r_t_matrix.mat';
    if(file_existence(filename))
        load(filename);
    else
        filename = 'D:\under_progress2\chemotaxis\C_r_t_matrix.mat';
        if(file_existence(filename))
            load(filename);
        else
            filename = '/Users/npokala/Documents/MATLAB/pelops_mirror/under_progress2/chemotaxis/C_r_t_matrix.mat';
            if(file_existence(filename))
                load(filename);
            else
                filename = '\\Tantalus\Pelops\under_progress2\chemotaxis\C_r_t_matrix.mat';
                if(file_existence(filename))
                    load(filename);
                end
            end
        end
    end
    
    if(isempty(C_r_t_matrix))
        C_r_t_matrix = zeros(length(t), length(r));
        for(i=1:length(r))
            for(j=1:length(t))
                % for a continious point source
                % appropriate for odor drop -> gradient since liquid -> vapor
                % -> diffusion - integration of Crank Eqn 3.5
                fun = @(x) exp(-r(i)^2./(4*D*x))./((4*pi*D*x).^(3/2));
                C_r_t_matrix(j,i) = quadgk(@(x)fun(x),0,t(j));
                
                % for a depleting instantaneous point source
                % C_r_t_matrix(i,j) = exp(-r(i)^2./(4*D*t(j)))./((4*pi*D*t(j)));
            end
        end
        C_r_t_matrix = C_r_t_matrix./max(max(C_r_t_matrix));
    end
    
    [r,t] = meshgrid(r,t);
    
    r = double(r);
    t = double(t);
    C_r_t_matrix = double(C_r_t_matrix);
end

input_r = double(input_r);
input_t = double(input_t);

C = interp2(r,t,C_r_t_matrix,input_r,input_t);

if(nargout>1)
    C_matrix = C_r_t_matrix;
end

return;
end
