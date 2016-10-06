clear; clc;
pdir = '/home/p2admin/Documents/Hope';


dbdir = [pdir,'/','ModelNet40'];
vxdir = [pdir,'/','voxsal'];
class_names = {'bathtub','bed','chair','desk','dresser',...
    'monitor','night_stand','sofa','table','toilet'};

i = 1;
for i=1:2
    switch i
        case 1
            fd = '/test';
        case 2
            fd = '/train';
    end
    meshdir = [dbdir,'/',class_names{i},'/test'];
    outputdir = [vxdir,'/',class_names{i},'/test'];
    if ~exist(outputdir , 'dir')
        mkdir(outputdir);
    end
    cvt_real_voxel(meshdir,outputdir,'off',1)
end