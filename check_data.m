clear; close all;
threshold = 0;
ddir = '/home/p2admin/Documents/Hope/voxnet/more_data_curv/volumetric_data';

dd1 = [ddir,'/more_pot/30/train'];
ff1 = dir(dd1);
for i=3:size(ff1,1)
    fff=[dd1,'/',ff1(i).name];
    load(fff);
    cnt = i-2;
    subplot(4,5,cnt);show_sample(instance ,threshold);view(2)
end

dd2 = [ddir,'/more_pot/30/test'];
ff2 = dir(dd2);
for i=3:size(ff2,1)
    fff=[dd2,'/',ff2(i).name];
    load(fff);
    subplot(4,5,10);show_sample(instance ,threshold);view(2)
end

dd3 = [ddir,'/more_cup/30/train'];
ff3 = dir(dd3);
for i=3:size(ff3,1)
    fff=[dd3,'/',ff3(i).name];
    load(fff);
    cnt = 10+i-2;
    subplot(4,5,cnt);show_sample(instance ,threshold);view(2)
end

dd4 = [ddir,'/more_cup/30/test'];
ff4 = dir(dd4);
for i=3:size(ff4,1)
    fff=[dd4,'/',ff4(i).name];
    load(fff);
    subplot(4,5,20);show_sample(instance ,threshold);view(2)
end
