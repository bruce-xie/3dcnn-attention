
function cvt_script()
if 0
    f = 'morepottrain_00000009_1.mat';
    % location of nozzle and handle
    ttt = 7;
    bbb = 24;
    % weights of nozzle and handle
    a = 10;
    b = 10;
    c = 1;
    
    cvt(f,a,b);
else
    dd1 = './more_pot/30/train';
    ff1 = dir(dd1);
    for i=3:size(ff1,1)
        fff=[dd1,'/',ff1(i).name];
        load(fff);
        instance(instance==10) = 3;
        save(fff,'instance');
    end
    
    dd2 = './more_pot/30/test';
    ff2 = dir(dd2);
    for i=3:size(ff2,1)
        fff=[dd1,'/',ff1(i).name];
        load(fff);
        instance(instance==10) = 3;
        save(fff,'instance');
    end
    
    dd3 = './more_cup/30/train';
    ff3 = dir(dd3);
    for i=3:size(ff3,1)
        fff=[dd1,'/',ff1(i).name];
        load(fff);
        instance(instance==10) = 3;
        save(fff,'instance');
    end
    
    dd4 = './more_cup/30/test';
    ff4 = dir(dd4);
    for i=3:size(ff4,1)
        fff=[dd1,'/',ff1(i).name];
        load(fff);
        instance(instance==10) = 3;
        save(fff,'instance');
    end
end
end


function cvt(f,ttt,bbb)
load(f)
instance1 = zeros(size(instance));
for i=1:30
    for j=1:30
        for k=1:30
            if j>=bbb
                instance1(i,j,k)=a*instance(i,j,k);
            elseif j<=ttt
                instance1(i,j,k)=b*instance(i,j,k);
            else
                instance1(i,j,k)=c*instance(i,j,k);
            end
        end
    end
end
end
% figure;
% subplot(2,1,1);show_sample(instance1,1);xlabel('x');ylabel('y')
% subplot(2,1,2);show_sample(instance1,0.1);xlabel('x');ylabel('y')


% instance = instance1;
% save(f,'instance');

% 1
% remove 7 from pot train