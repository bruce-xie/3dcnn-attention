function write_input_data(off_path, data_path, classes, volume_size, pad_size, angle_inc)
% Put the mesh object in a volume grid and save the volumetric
% represenation file.
% This is the input volumetric data for 3D ShapeNets.
% off_path: root off data folder
% data_path: destination volumetric data folder

phases = {'train', 'test'};

data_size = pad_size * 2 + volume_size;
for c = 1 : length(classes)
    fprintf('writing the %s category\n', classes{c});
    category_path = [off_path '/' classes{c}];
    dest_path = [data_path '/' classes{c} '/' num2str(data_size)];
    if ~exist(dest_path, 'dir')
        mkdir(dest_path);
    end
    % for train and test phases
    for t = 1 : numel(phases)
        phase = phases{t};
        off_list = [category_path '/' phase];
        dest_tsdf_path = [dest_path '/' phase];
        if ~exist(dest_tsdf_path, 'dir')
            mkdir(dest_tsdf_path);
        end
        files = dir(off_list);
        for i = 1 : length(files)     
            if strcmp(files(i).name, '.') || strcmp(files(i).name, '..') || files(i).isdir == 1 || ~strcmp(files(i).name(end-2:end), 'off')
                continue;
            end
            filename = [off_list '/' files(i).name];
            for viewpoint = 1 : 360/angle_inc
                destname = [dest_tsdf_path '/' files(i).name(1:end-4) '_' num2str(viewpoint) '.mat'];
                off_data = off_loader(filename, (viewpoint-1)*angle_inc);
                instance = polygon2voxel(off_data, [volume_size, volume_size, volume_size], 'auto');
                instance = padarray(instance, [pad_size, pad_size, pad_size]);
                instance = int8(instance);
                save(destname, 'instance');
            end
        end
    end
end
% write_input_data('/home/p2admin/Documents/Hope/ModelNet10', '/home/p2admin/Documents/Hope/cvt', {'bathtub','bed','chair','desk','dresser','monitor','night_stand','sofa','table','toilet'}, 26, 2, 360)
