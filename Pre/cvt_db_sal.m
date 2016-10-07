clear; clc;
pdir = '/home/p2admin/Documents/Hope';


dbdir = [pdir,'/','ModelNet40'];
vxdir = [pdir,'/','voxsal'];
class_names = {'bed','sofa','desk'};

for tt=2:2
    switch tt
        case 1
            fd = '/test';
        case 2
            fd = '/train';
    end
    for i = 1:length(class_names)
        meshdir = [dbdir,'/',class_names{i},fd];
        outputdir = [vxdir,'/',class_names{i},fd];
        if ~exist(outputdir , 'dir')
            mkdir(outputdir);
        end
        cvt_real_voxel(meshdir,outputdir,'off',1)
    end
end