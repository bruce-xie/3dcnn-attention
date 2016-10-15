clear; clc;
% copy all mat file which same name files are contained in reference dir
% from source dir to target dir


% reference dir
% rdir = '/home/p2admin/Documents/Hope/voxsal';
rdir = '/home/hope-yao/Documents/Data/doi/vox';

% source dir
sdir = '/home/hope-yao/Documents/Data/doi/sal';

% target dir
tdir = '/home/hope-yao/Documents/Data/doi/sal0';

size = 30;

class_names = {'bathtub','bed','chair','desk','dresser','monitor','night_stand','sofa','table','toilet'};

for tt=1:2
    switch tt
        case 1
            fd = '/test';
        case 2
            fd = '/train';
    end
    for i=1:length(class_names)
        meshdir = [rdir,'/',class_names{i},fd];
%         meshdir = [rdir,'/',class_names{i},'/',num2str(size),fd];
        all_filenames = dir(meshdir);
        disp([meshdir,'  ',num2str(length(all_filenames))]);
        for j=1:length(all_filenames)
            rfname = [rdir,fd,'/',all_filenames(j).name];
            [~,~,ext] = fileparts(rfname);
            if strcmp(ext,'.mat')
                sfname = [sdir,'/',class_names{i},fd,'/',all_filenames(j).name];
                tdname = [tdir,'/volumetric_data/',class_names{i},'/',num2str(size),'/',fd];
                f_rot = ['/',all_filenames(j).name];
                tfname = [tdname,f_rot];
                if ~exist(tdname , 'dir')
                    mkdir(tdname);
                end
                copyfile(sfname ,tfname);
            end
        end
    end
end

