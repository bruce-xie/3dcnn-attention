clear; clc;
delete(gcp('nocreate'))
parpool(12)

pdir = '/home/hope-yao/Documents/Data';
dbdir = [pdir,'/','ModelNet10'];
dir_sal = [pdir,'/','sal'];
dir_vox = [pdir,'/','vox'];
class_names = {'dresser','monitor','night_stand','sofa','table','desk'};
% 'bathtub','bed','chair','desk','dresser','monitor','night_stand','sofa','table','desk'
for tt=2:2
    switch tt
        case 1
            fd = '/test';
        case 2
            fd = '/train';
    end
    for i = 1:length(class_names)
        meshdir = [dbdir,'/',class_names{i},fd];
        outputdir_sal = [dir_sal,'/',class_names{i},fd];
        outputdir_vox = [dir_vox,'/',class_names{i},fd];
        if ~exist(outputdir_sal, 'dir')
            mkdir(outputdir_sal);
        end
        if ~exist(outputdir_vox, 'dir')
            mkdir(outputdir_vox);
        end
        cvt_real_voxel(meshdir,outputdir_sal,outputdir_vox,'off')
    end
end