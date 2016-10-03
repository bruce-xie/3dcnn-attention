
function cvt_script()
    f = 'morepottrain_00000009_1.mat';

    % location of nozzle and handle
    ttt = 7;
    bbb = 24;
    % weights of nozzle and handle
    a = 10;
    b = 10;
    c = 1;
    
    cvt(f,a,b);
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