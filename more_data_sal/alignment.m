% fpath = './more_data_sal/volumetric_data/more_cup/30/train/';
fpath = './more_data/volumetric_data/more_cup/30/train/';
f=dir(fpath)
figure
for idx=1:9
    ff=[fpath,f(2+idx).name]
    load(ff)
%     
%     for i=1:30
%         for j=1:30
%             for k = 1:30
%                 instance1(k,j,i)=instance(i,j,k);
%             end
%         end
%     end
%     instance = instance1;
%     save(f(2+idx).name,'instance')
%     
    subplot(3,3,idx)
    show_sample(instance,0.1);xlabel('x');ylabel('y')

end

% for i=1:9
%     subplot(3,3,i)
%     axis([0 30 0 30 0 30]); axis off;view(2)
% end