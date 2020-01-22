p = [0 0.1 0.4;0.6 0 0.4;0.3 0.3 0];
node_num = 3;
mean_arr = [1 4 3];
mean_serv = 10;
user_num = 300;
average0 = zeros(100,node_num);
average1 = zeros(100,node_num);
average2 = zeros(100,node_num);
average3 = zeros(100,node_num);
for i = 1:100
    i
    [state] =  queue_network(node_num,mean_arr,mean_serv,user_num, p);
    for k = 1:node_num
        idx = find(state(7,:,k) == 1);
        state2 = state(:,idx,k);
%         average0(i,k) = sum(queue(:,1).*queue(:,2))/max(state2(5,:));
%         average1(i,k) = sum(service(:,1).*service(:,2))/max(state2(5,:));
        average2(i,k) = mean(state2(3,:));
        average3(i,k) = mean(state2(5,:)-state2(1,:));
    end
    
%     idx = find(state(6,:)==1);
%     state2 = state(:,idx);
%     average0 = [average0;sum(queue(:,1).*queue(:,2))/max(state2(5,:))];
%     average1 = [average1;sum(service(:,1).*service(:,2))/max(state2(5,:))];
%     average2 = [average2;mean(state2(3,:))];
%     average3 = [average3;mean(state2(5,:)-state2(1,:))];
%     total0 = total0 + average0;
%     total1 = total1 + average1;
%     total2 = total2 + average2;
%     total3 = total3 + average3;
end
% waiting_queue = mean(average0);
% all_queue = mean(average1) + waiting_queue;
waiting_time = mean(average2);
stop_time = mean(average3);