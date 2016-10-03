clear all;
f = 'morecupttest_00000000_1.mat'
load(f)
close all
for i=1:30
    for j=1:30
        for k=1:30
            if j>=20
                instance1(i,j,k)=3*instance(i,j,k);
%             elseif j<=6
%                 instance1(i,j,k)=10*instance(i,j,k);
            else
                instance1(i,j,k)=0.1*instance(i,j,k);
            end
        end
    end
end
figure;show_sample(instance,0.5)
figure;show_sample(instance1,2.5)
% figure;show_sample(instance1,9.5)

instance = instance1;
save(f,'instance');


% remove 7 from pot train