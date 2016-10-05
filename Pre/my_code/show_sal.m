function show_sal(meshdir,outputdir,filetype,viz)
% input: meshdir(str), outputdir(str)
% filetype(str): off or json, viz(num): 0 or 1

filename = dir(meshdir);
for i=1:length(filename)
    tic
    [~,name,ext] = fileparts(filename(i).name);
    meshfile = [meshdir,'/',filename(i).name];
    disp([meshfile,'         ',num2str(i),' out of ',num2str(length(filename))])
    if strcmp(ext(2:end),filetype)
        % compute real voxel
        [flag,instance] = real_voxel(meshfile,filetype,viz);
        if flag ==0
            % something went wrong
            disp([meshfile,'  vertices number:',instance])
        else
            outfile = [outputdir,'/',name,'.mat'];
            save(outfile,'instance');
            if viz
                outfile = [outputdir,'/',name,'.fig'];
                savefig(gcf,outfile)
                outfile = [outputdir,'/',name,'.png'];
                saveas(gcf,outfile)
            end
        end
    end
    toc
end
end

function [flag,instance_sal] = real_voxel(meshfile,filetype,viz)
if strcmp(filetype,'off')
    FV = off_loader(meshfile, 0);
    Mesh = struct('v',FV.vertices,'f',FV.faces);
elseif strcmp(filetype,'json')
    json2data = loadjson(['/media/storage/p2admin/Documents/Hope/voxnet/Pre/voxelization' filesep '392.json']);
    v = json2data.parsed.vertexArray;
    f = json2data.parsed.faceArray+1; % index from .json starts from 0, but required to be 1 for meshSaliencyPipeline
    FV = struct('vertices',v,'faces',f);
    Mesh = struct('v',v,'f',f);
else
    assert(0);
end
if viz
    % plot orignal mesh data
    figure;subplot(2,2,1);show3DModel(FV.faces,FV.vertices,0)
end

% voxel model
volume_size = 26;
pad_size = 2; % and padding of two in each side
instance = polygon2voxel(FV, [volume_size, volume_size, volume_size], 'auto');
instance = padarray(instance, [pad_size, pad_size, pad_size]);
nnz_inst = nnz(instance);
if viz
    % plot binary voxels
    subplot(2,2,2);show_sample(instance,0.5);axis([0,30,0,30,0,30])
end

% compute saliency, using curvature based method
try
    v = sal(Mesh);
catch
    % if something went wrong in curvature code
    flag = 0; instance_sal = length(Mesh.v);
    return
end
% load cup_0030.mat
v = exp(1*v/max(v)); % convert to maximum e^3
fv = recenter(FV,volume_size,pad_size);
if viz
    % plot saliency
    subplot(2,2,3);vis(fv,v);axis([0,30,0,30,0,30])
end

% assign saliency to voxel
instance_sal = vox_sal(instance,fv,v);
if viz
    %only show 5 persent most salient
    sal_ratio = 0.10;
    [~,idx]=sort(instance_sal(:),'ascend');
    t2=idx(1:end-floor(sal_ratio*nnz_inst));
    instance_sal(t2)=0;
    subplot(2,2,4);
    plot3D(instance_sal);
    axis([0,30,0,30,0,30]);xlabel('x');ylabel('y');zlabel('z'); view([1 0 0])
end
flag = 1;
end

function instance_sal=vox_sal(instance,fv,v)
instance_sal = zeros(size(instance));
instance = permute(instance,[2 1 3]);
for i=1:size(instance,1)
    for j=1:size(instance,2)
        for k=1:size(instance,3)
            if instance(i,j,k)==1
                xl = fv.vertices(:,1)>i-1;
                xr = fv.vertices(:,1)<=i;
                yl = fv.vertices(:,2)>j-1;
                yr = fv.vertices(:,2)<=j;
                zl = fv.vertices(:,3)>k-1;
                zr = fv.vertices(:,3)<=k;
                idx = xl.*xr.*yl.*yr.*zl.*zr;
                
                vidx = find(idx);
                if  ~isempty(vidx)
                    tt = max(v(vidx));
                    instance_sal(i,j,k) = tt;
                    %                     disp([i,j,k,tt]);
                else
                    % assign 1 if there is something but not salient
                    instance_sal(i,j,k) = instance(i,j,k);
                end
            end
        end
    end
end
end

function FV=recenter(FV,vsize,pad_size)
zmax = max(FV.vertices(:,3));
zmin = min(FV.vertices(:,3));
ymax = max(FV.vertices(:,2));
ymin = min(FV.vertices(:,2));
xmax = max(FV.vertices(:,1));
xmin = min(FV.vertices(:,1));

cx = xmax+xmin;%center location
cy = ymax+ymin;
cz = zmax+zmin;
lx = xmax-xmin;%length of each side
ly = ymax-ymin;
lz = zmax-zmin;
scale = max([lx,ly,lz]);

FV.vertices(:,1) = (FV.vertices(:,1) +cx/2) / scale * vsize + vsize/2 + pad_size;
FV.vertices(:,2) = (FV.vertices(:,2) +cy/2) / scale * vsize + vsize/2 + pad_size;
FV.vertices(:,3) = (FV.vertices(:,3) +cz/2) / scale * vsize + vsize/2 + pad_size;

end

function vis(FV,v)
p = patch(FV);
p.FaceVertexAlphaData = v/20;
p.FaceAlpha = 'interp';
p.FaceVertexCData=v/20;
set(p,'FaceColor','blue','EdgeColor','none');
daspect([1,1,1])
grid on; axis tight
camlight
lighting gouraud;

axis equal
axis vis3d
%     view(2);
%     axis([0 30 0 30 0 30])
zlabel('z');
xlabel('x');
ylabel('y');
%     axis tight;
%     pause;
%     close(gcf);
view(90,0)
end

function v = sal(Mesh)
global cache_ params_;
cache_ = struct();
params_.scale = 0.003;
params_.windowSize = 0.33 * sqrt(sum((min(Mesh.v)-max(Mesh.v)).^2));
curvature = computeCurvature(Mesh);
epsilon = params_.scale * sqrt(sum((min(Mesh.v)-max(Mesh.v)).^2));
suppressedLevelSaliency = {};
for level = 1:5
    sigma = round((level+1) * epsilon, 6);
    levelSaliency = centerSurround(Mesh, curvature, sigma);
    suppressedLevelSaliency{level} = nonlinearSuppression(Mesh, levelSaliency, sigma);
end
v = sum(cat(2,suppressedLevelSaliency{:}),2);

end