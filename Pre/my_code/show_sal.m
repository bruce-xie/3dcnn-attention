function instance=show_sal(meshfile)
% visualize both meshed object and its saliency computed by curvature
% method
% usage:
% show_sal('/home/p2admin/Documents/Hope/voxnet/cup/train/cup_0030.off')

meshfile = '/home/p2admin/Documents/Hope/voxnet/cup/train/cup_0030.off';
% load mesh file
if strcmp(meshfile(end-2:end),'off')
    FV = off_loader(meshfile, 0);
    Mesh = struct('v',FV.vertices,'f',FV.faces);
elseif strcmp(meshfile(end-2:end),'son')
    json2data = loadjson(['/media/storage/p2admin/Documents/Hope/voxnet/Pre/voxelization' filesep '392.json']);
    v = json2data.parsed.vertexArray;
    f = json2data.parsed.faceArray+1; % index from .json starts from 0, but required to be 1 for meshSaliencyPipeline
    FV = struct('vertices',v,'faces',f);
    Mesh = struct('v',v,'f',f);
else
    assert(0);
end
% plot orignal mesh data
figure;subplot(2,2,1);show3DModel(FV.faces,FV.vertices,0)

% voxel model
volume_size = 26;
pad_size = 2; % and padding of two in each side
instance = polygon2voxel(FV, [volume_size, volume_size, volume_size], 'auto');
instance = padarray(instance, [pad_size, pad_size, pad_size]);
% plot binary voxels
subplot(2,2,2);show_sample(instance,0.5);

% compute saliency, using curvature based method
% v = sal(Mesh);
load cup_0030.mat
v = 10*v/max(v); % convert to maximum 10
fv = recenter(FV,volume_size,pad_size);
% plot saliency
subplot(2,2,3);vis(fv,v);axis([0,30,0,30,0,30])

% assign saliency to voxel
instance = vox_sal(instance,fv,v);

% plot salient part only
subplot(2,2,4);
show_sample(instance,0.005);
% plot3D(permute(instance,[2 1 3]) ,'pasive');
vis(fv,v);axis([0,30,0,30,0,30])
end

function instance_sal=vox_sal(instance,fv,v)
instance_sal = zeros(size(instance));
for i=1:size(instance,1)
    for j=1:size(instance,2)
        for k=1:size(instance,3)
            if instance(i,j,k)==1
                xl = fv.vertices(:,1)>i-1;
                xr = fv.vertices(:,1)<i;
                yl = fv.vertices(:,2)>j-1;
                yr = fv.vertices(:,2)<j;
                zl = fv.vertices(:,3)>k-1;
                zr = fv.vertices(:,3)<k;
                idx = xl.*xr.*yl.*yr.*zl.*zr;

                vidx = find(idx, 1);
                if  ~isempty(vidx) && j>25
                    tt = max(v(vidx));
                    instance_sal(i,j,k) = tt;
                    disp([i,j,k,tt]);
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

FV.vertices(:,1) = (FV.vertices(:,1) +cx/2) / scale * vsize + vsize/2 + pad_size+1;
FV.vertices(:,2) = (FV.vertices(:,2) +cy/2) / scale * vsize + vsize/2 + pad_size+1;
FV.vertices(:,3) = (FV.vertices(:,3) +cz/2) / scale * vsize + vsize/2 + pad_size+1;
end

function vis(FV,v)
p = patch(FV);
p.FaceVertexAlphaData = v;
p.FaceAlpha = 'interp';
p.FaceVertexCData=v;
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