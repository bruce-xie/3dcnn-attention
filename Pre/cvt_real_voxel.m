function cvt_real_voxel(meshdir,outputdir1,outputdir2,filetype)
% input: meshdir(str), outputdir1(str) for saliency,outputdir2(str) for non saliency,
% filetype(str): off or json, viz(num): 0 or 1 or 2

if meshdir(end) == '/'
    meshdir = meshdir(1:end-1);
end
filename = dir(meshdir);

parfor i=1:length(filename)
    tic
    [~,name,ext] = fileparts(filename(i).name);
    meshfile = [meshdir,'/',filename(i).name];
    
    if strcmp(ext(2:end),filetype)  % &&strcmp(name,'bathtub_0109')
        
        angle_inc = 30;  % keep the same with 3DShapeNet
        for viewpoint = 1 : 360/angle_inc
            if (viewpoint==1)
                viz = 1;
            else
                viz = 0;
            end
            
            ang = (viewpoint-1)*angle_inc;
            flag = 0;
            f1 = [outputdir1,'/',name,'.val'];
            f2 = [outputdir1,'/',name,'.val.mat'];
            if exist(f1, 'file')
                movefile(f1,f2)
            end
            if exist(f2, 'file')
                flag = f2;
            end
            [instance_sal,instance,h,vtxsal] = real_voxel(meshfile,viz,ang,flag);
            if length(vtxsal) == 1
                % something went wrong
                disp([meshfile, '********** FAILED! **********'])
            else
                %                 destname = [dest_tsdf_path '/' files(i).name(1:end-4) '_' num2str(viewpoint) '.mat'];
                outfile1 = [outputdir1,'/',name,'_', num2str(viewpoint),'.mat'];
                if exist([outputdir1,'/',name,'.mat'], 'file')
                    delete([outputdir1,'/',name,'.mat']) % abandom previous file without rotation
                end
                outfile2 = [outputdir2,'/',name,'_', num2str(viewpoint),'.mat'];
                if flag==0 % saliency value haven't been stored yet
                    outfile3 = [outputdir1,'/',name,'.val'];
                else 
                    outfile3 = flag;
                end
                if viz
                    outfile4 = [outputdir1,'/',name,'.png'];
                else
                    outfile4 = viz;
                end
                save_result(outfile1,instance_sal,outfile2,instance,outfile3,vtxsal,outfile4,h);
                disp([meshfile,' Percentage: ',num2str(i),'/',num2str(length(filename)),' DONE!'])
            end
        end
    end
    toc
end
end

function    save_result(outfile1,instance_sal,outfile2,instance,outfile3,vtxsal,outfile4,h)
save(outfile1,'instance_sal');
save(outfile2,'instance');
if outfile3 % saliency value haven't been stored yet
    save(outfile3,'vtxsal');
end
if outfile4
    saveas(h,outfile4)
    close all;
end
end