function [im, az, el, az2, el2] = salientViewpoint(Mesh, meshSaliency)
    views = {};

%     fig = figure('Visible','Off');
%     set(fig, 'Position', [0 0 200 200]);
%     colormap(fig, 'gray');
%     caxis([0 1]);
    
    im = getRenderedImage(Mesh, meshSaliency, 0, 0);
    ax = findall(im,'type','axes');

    count = 1;
    azel = {};
    im.Color = [0 0 0];
    for j = -90:10:90
%     for j = [20]
        for i = 1:10:180
            view(360/180*i, j);
            img=im2double(frame2im(getframe(im)));
%             views{count} = double(im.^8);
            views{count} = double(img);
            azel{count} = [360/180*i, j];
%             imwrite(im, sprintf('%.3d-%.3d-%.5d.png', i,j, sum(views{count}(:))));
            count = count + 1;
        end
    end

    maxV = -Inf;
    for i = 1:numel(views)
        red = views{i}(:,:,1);
        v = sum(red(:));
        if maxV < v
            az = azel{i}(1);
            el = azel{i}(2);
            maxV = v;
            maxid = i;
        end
    end
    
    minV = Inf;
    for j = 1:numel(views)
        red = views{j}(:,:,1);
        v = sum(red(:));
        if minV > v
            az2 = azel{j}(1);
            el2 = azel{j}(2);
            minV = v;
            minid = j;
        end
    end
end
