function[random_ans]=mms_function2(mean_arr,mean_serv,server_num,user_num) 
%该函数模拟M/M/S排队过程,返回模拟结果矩阵
%   mean_arr为到达时间间隔常数
%   mean_serv为服务时间常数
%   server_num为服务器个数
%   user_num表示模拟的总客户数量
 
state=zeros(5,user_num);   
%各个顾客的状态用矩阵存储
%每列表示一位顾客
%第一行为到达时刻
%第二行为服务时间
%第三行为等待时间
%第四行为当该顾客到来时的当前队列长度长
%第五行表示该顾客离开的时间

state(1,:)=exprnd(1/mean_arr,1,user_num);    
%到达时间间隔服从指数分布
%mean_arr为到达时间间隔常数
arr_time=cumsum(state(1,:)); 
% state(1,:) = arr_time;
state(2,:)=exprnd(1/mean_serv,1,user_num);   
%服务时间服从指数分布
%mean_serv为服务时间常数
state(3,1) = 0;
state(4,1) = 0;
state(5,1) = state(1,1) + state(2,1);
server_state = zeros(1, server_num);
%第一行为下次空闲时间
%第二行为是否空闲
for i = 2:user_num
    %如果还有服务器空闲
    if min(server_state) == 0 
        %等待时间和队列长度为0
        state(3,i) = 0;
        state(4,i) = 0;
        %空闲的服务器
        serv_desk1 = server_state(server_state>arr_time(i-1));
        serv_desk2 = serv_desk1(serv_desk1<=arr_time(i));
        for l = 1: server_num
            if ~isempty(find(serv_desk2==server_state(l)))
                server_state(l) = 0;
            end
        end
        [~,idx] = min(server_state);
        server_state(idx) = arr_time(i)+state(2,i);
%         server_state(2,idx) = 1;
    else
        %在上一个顾客到达和该顾客到达之间服务器空闲台数
        serv_desk1 = server_state(server_state>arr_time(i-1));
        serv_desk2 = serv_desk1(serv_desk1<=arr_time(i));
        ok_server_num = length(serv_desk2); 
        if state(4,i-1) + 1 <= ok_server_num  %空闲的服务器数量大于等于队列长度
            state(4,i) = 0; %无需等待
            state(3,i) = 0;
            for k = state(4,i-1)+1:1  %更新服务器下次空闲时间
                [~,idx] = min(server_state);
                server_state(idx) = server_state(idx) + state(2,i+1-k);
            end
            for j = ok_server_num:state(4,i-1)+2
                [~,idx] = min(server_state(1,:));
                server_state(idx) = 0;
            end
        else
            state(4,i) = state(4,i-1)+ 1 - ok_server_num;
            for k = ok_server_num:1
                [~,idx] = min(server_state);
                if i+1-k<=user_num
                    server_state(idx) = server_state(idx) + state(2,i+1-k);
                end
            end
            if state(4,i) <= server_num %若为队列前几个
                server_sort = sort(server_state);
                state(3,i) = server_sort(state(4,i)) - arr_time(i);
            else
                queue_desk = state(5,i+1-state(4,i):i-server_num); %队列前面的人的服务结束时间
                state(3,i) = max(queue_desk) - arr_time(i);
            end
        end

   end
   %当第i位顾客到来时,如果到达时刻小于某服务器的空闲时刻,无需等待,等待时间置0
   %如果到达时刻大于空闲时刻最小的服务器的,其等待时间为到达时刻-服务器空闲时间          

   %计算第i位顾客的离开时刻=到达时刻+服务时间+等待时间
%    for j=1:server_num  
%         if serv_desk(j)==min(serv_desk) 
%             serv_desk(j)=state(5,i);
%             %每位顾客优先使用对其而言服务空闲时间最短的服务器,故更新该服务器的空闲时间
%             break 
%         end                      
%    end 
end 

state(1,:) = arr_time;
state(5,:)=sum(state(1:3,:));
random_ans = state;
end

