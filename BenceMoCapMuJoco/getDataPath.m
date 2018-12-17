function [data_path, blob_path, blob_data_path] = getDataPath(load_path)

titanic_blob = 'http://140.247.178.149:5900/';
valemax_blob = 'http://140.247.178.129:5900/';
sultana_blob = 'http://140.247.178.35:5900/';
minotaur_blob = 'http://140.247.178.191:5900/';

titanic_samba = '\\140.247.178.8\';
valemax_samba = '\\140.247.178.42\';
sultana_samba = '\\140.247.178.57\';
minotaur_samba = '\\140.247.178.65\';
holylfs_samba = '\\olveczky.rc.fas.harvard.edu\olveczky_lab_holy2\Ashesh\';
holylfs_samba_SW = '\\olveczky.rc.fas.harvard.edu\olveczky_lab_holy2\Steffen\';

samba_common = 'asheshdhawale\Data\'; % specific to your data folders
blob_common = '/root/data/asheshdhawale/Data/'; % specific to your data folders

if contains(load_path, 'Dhanashri')
%     data_path = [valemax_samba samba_common 'Dhanashri\'];
    data_path = [holylfs_samba 'Dhanashri\'];
    blob_path = valemax_blob;
    blob_data_path = [blob_common 'Dhanashri/'];
    
elseif contains(load_path, 'Hamir')
%     data_path = [sultana_samba samba_common 'Hamir\'];
    data_path = [holylfs_samba 'Hamir\'];
    blob_path = sultana_blob;
    blob_data_path = [blob_common 'Hamir/'];
    
elseif contains(load_path, 'Hindol')
%     data_path = [titanic_samba samba_common 'Hindol\'];
    data_path = [holylfs_samba 'Hindol\'];
    blob_path = titanic_blob;
    blob_data_path = [blob_common 'Hindol/'];
    
elseif contains(load_path, 'Kamod')
    data_path = [holylfs_samba 'Kamod\'];
    blob_path = sultana_blob;
    blob_data_path = [blob_common 'Kamod/'];
    
elseif contains(load_path, 'Jaunpuri')
%     data_path = [valemax_samba samba_common 'Jaunpuri\'];
    data_path = [holylfs_samba 'Jaunpuri\'];
    blob_path = valemax_blob;
    blob_data_path = [blob_common 'Jaunpuri/'];
    
elseif contains(load_path, 'Gara')
    data_path = [valemax_samba samba_common 'Gara\'];
    blob_path = valemax_blob;
    blob_data_path = [blob_common 'Gara/'];
    
elseif contains(load_path, 'Gandhar')
    data_path = [valemax_samba samba_common 'Gandhar\'];
    blob_path = valemax_blob;
    blob_data_path = [blob_common 'Gandhar/'];
    
elseif contains(load_path, 'GaudMalhar')
    data_path = [valemax_samba samba_common 'GaudMalhar\'];
    blob_path = valemax_blob;
    blob_data_path = [blob_common 'GaudMalhar/'];
    
elseif contains(load_path, 'Gunakari')
    data_path = [valemax_samba samba_common 'Gunakari\'];
    blob_path = valemax_blob;
    blob_data_path = [blob_common 'Gunakari/'];
    
elseif contains(load_path, 'Gorakh')
    data_path = [valemax_samba samba_common 'Gorakh\'];
    blob_path = valemax_blob;
    blob_data_path = [blob_common 'Gorakh/'];
    
elseif contains(load_path, 'Desh')
    data_path = [valemax_samba samba_common 'Desh\'];
    blob_path = valemax_blob;
    blob_data_path = [blob_common 'Desh/'];
    
elseif contains(load_path, 'Champakali')
    data_path = [titanic_samba samba_common 'Champakali\'];
    blob_path = titanic_blob;
    blob_data_path = [blob_common 'Champakali/'];
    
elseif contains(load_path, 'SW158')
%     data_path = [minotaur_samba samba_common 'SW158\'];
    data_path = [holylfs_samba 'SW158\'];
    blob_path = minotaur_blob;
    blob_data_path = [blob_common 'SW158/'];
    
elseif contains(load_path, 'SW163')
%     data_path = [minotaur_samba samba_common 'SW163\'];
    data_path = [holylfs_samba 'SW163\'];
    blob_path = minotaur_blob;
    blob_data_path = [blob_common 'SW163/'];   
    
elseif contains(load_path, 'SW116')
    data_path = [holylfs_samba_SW 'SW116\'];

elseif contains(load_path, 'SW160')
    data_path = [holylfs_samba_SW 'SW160\'];
    
elseif contains(load_path, 'SW166')
    data_path = [holylfs_samba_SW 'SW166\'];

    
end

