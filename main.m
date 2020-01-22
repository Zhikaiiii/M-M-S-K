total0 = 0;
total1 = 0;
total2 = 0;
total3 = 0;
average0 =[];
average1 = [];
average2 = [];
average3 = [];
for i = 1:100
    [state,queue,service] =  mmsk_function(2,0.5,2,5,10000);
    idx = find(state(6,:)==1);
    state2 = state(:,idx);
    average0 = [average0;sum(queue(:,1).*queue(:,2))/max(state2(5,:))];
    average1 = [average1;sum(service(:,1).*service(:,2))/max(state2(5,:))];
    average2 = [average2;mean(state2(3,:))];
    average3 = [average3;mean(state2(5,:)-state2(1,:))];
%     total0 = total0 + average0;
%     total1 = total1 + average1;
%     total2 = total2 + average2;
%     total3 = total3 + average3;
end
% total0 = total0/100;
% total1 = total1/100;
% total2 = total2/100;
% total3 = total3/100;
waiting_queue = mean(average0);
all_queue = mean(average1) + waiting_queue;
waiting_time = mean(average2);
stop_time = mean(average3);

% % plot(waiting_queue,'xb');