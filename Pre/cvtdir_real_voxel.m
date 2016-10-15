function cvtdir_real_voxel(meshdir,outputdir,filetype,viz)
% input: meshdir(str), outputdir(str)
% filetype(str): off or json, viz(num): 0 or 1
if meshdir(end) == '/'
    meshdir = meshdir(1:end-1);
end

filename = dir(meshdir);
for i=1:length(filename)
    tic
    [~,name,ext] = fileparts(filename(i).name);
    meshfile = [meshdir,'/',filename(i).name];
    if strcmp(ext(2:end),filetype)                    %&&strcmp(name,'bathtub_0108')
        % compute real voxel
        [instance,h,vtxsal] = real_voxel(meshfile,viz);
        if length(vtxsal) == 1
            % something went wrong
            disp([meshfile,'  vertices number:',num2str(instance),' Percentage: ',num2str(i),'/',num2str(length(filename)),' FAILED!'])
        else
            outfile = [outputdir,'/',name,'.mat'];
            save(outfile,'instance');
            outfile = [outputdir,'/',name,'.val'];
            save(outfile,'vtxsal');
            if viz
                outfile = [outputdir,'/',name,'.png'];
                saveas(h,outfile)
                close all;
            end
            disp([meshfile,' Percentage: ',num2str(i),'/',num2str(length(filename)),' DONE!'])
        end
    end
    toc
end
end
