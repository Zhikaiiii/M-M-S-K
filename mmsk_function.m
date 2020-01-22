function [state,queue_matrix,service_matrix] = mmsk_function(mean_arr,mean_serv,server_num,max_vol,user_num)
%MMSK_FUNTION函数用于模拟M/M/S/K排队过程,返回模拟结果矩阵
%   mean_arr表示到达时间间隔常数
%   mean_serv表示服务时间常数
%   server_num表示服务台个数
%   max_vol表示系统最大容量
%   user_num表示模拟的总客户数量

state=zeros(6,user_num);
%各个顾客的状态用矩阵存储
%每列表示一位顾客
%第一行为到达时刻
%第二行为服务时间
%第三行为等待时间
%第四行为当该顾客到来时的当前队列长度长
%第五行表示该顾客离开的时间
%第六行为该顾客是否进入系统的标志,1表示进入了系统

%记录不同时刻的队列长度
queue_matrix = [];
%记录不同时刻的服务人数
service_matrix = [];

cons1=1/mean_arr;
cons2=1/mean_serv;

queue_len=0;
%queue_len表示队列长度
servers=zeros(1,server_num);
%servers表示各个服务器,其存放每个服务器空闲的时刻
last_time = 0;
for i=1:user_num
    %计算到达时刻和服务时间
    arr_interval=exprnd(cons1);
    state(2,i)=exprnd(cons2);
    if i>1
        state(1,i)=state(1,i-1)+arr_interval;
    else
        state(1,i)=arr_interval;
    end
    if queue_len==0
        if state(1,i)>min(servers)
            if i > 1
                servers = sort(servers);
                busy_server_num = length(servers(servers>state(1,i-1)));
                for l = 1:server_num
                    if state(1,i) > servers(l) && state(1,i-1) < servers(l)
                        now_time = servers(l);
                        queue_matrix = [queue_matrix;now_time-last_time, 0];
                        service_matrix = [service_matrix;now_time-last_time,busy_server_num];
                        busy_server_num = busy_server_num - 1;
                        last_time = now_time;
                    end
                end
            else
                busy_server_num = 0;
            end
            now_time = state(1,i);
            queue_matrix = [queue_matrix;now_time-last_time, 0];
            service_matrix = [service_matrix;now_time-last_time,busy_server_num];
            last_time = now_time;
            %无队列且有服务器空闲则立刻服务
            for j=1:server_num
                if servers(j)==min(servers)
                    servers(j)=state(1,i)+state(2,i);
                    state(3,i)=0;
                    state(4,i)=0;
                    state(5,i)=servers(j);
                    state(6,i)=1;
                    break
                end
            end
        else
            %无队列且没有服务器空闲则开始排队
            %对于开始排队的顾客,其等待时间和离开时间在下个顾客到来时计算
            queue_len=queue_len+1;
            %记录队列长度变为1的开始时间
            now_time = state(1,i);
            queue_matrix = [queue_matrix;now_time-last_time, 0];
            service_matrix = [service_matrix;now_time-last_time,server_num];
            last_time = now_time;
            state(4,i)=1;
            state(6,i)=1;
        end
    else
        while state(1,i)>min(servers)&&queue_len>0
            %依次处理队列中的顾客,FIFO
            for k=1:server_num 
                if servers(k)==min(servers)
                    j = 0;
                    m = 1;
                    while (j <queue_len)
                        if state(6,i-m) == 1 %在系统内
                            j = j+1;
                        end
                        m = m+1;
                    end
                    m = m-1;
                    rank=i-m;
                    state(3,rank)=servers(k)-state(1,rank);
                    % 记录队列长度保持不变的时间
                    now_time = servers(k);
                    queue_matrix = [queue_matrix;now_time-last_time, queue_len];
                    service_matrix = [service_matrix;now_time-last_time,server_num];
                    last_time = now_time;
                    servers(k)=servers(k)+state(2,rank);
                    state(5,rank)=servers(k);
                    queue_len=queue_len-1;
                    break
                end
            end
        end
        %处理第i位顾客
        if (server_num+queue_len)>=max_vol
            %若出现服务中和队列中的顾客总数大于max_vol的情况,可直接考虑下一名顾客
            continue
        end
        if queue_len==0&&state(1,i)>min(servers)
            servers = sort(servers);
            left_server_num = length(servers(servers<state(1,i)));
            for l = 1:server_num
                if state(1,i) > servers(l)
                    now_time = servers(l);
                    queue_matrix = [queue_matrix;now_time-last_time, 0];
                    service_matrix = [service_matrix;now_time-last_time,left_server_num];
                    left_server_num = left_server_num - 1;
                    last_time = now_time;
                end
            end
            %无队列且有服务器空闲则立刻服务
            for j=1:server_num
                if servers(j)==min(servers)
                    servers(j)=state(1,i)+state(2,i);
                    state(3,i)=0;
                    state(4,i)=0;
                    state(5,i)=servers(j);
                    state(6,i)=1;
                    break
                end
            end
        else
            %否则进入队列中排队
            now_time = state(1,i);
            queue_matrix = [queue_matrix;now_time-last_time, queue_len];
            service_matrix = [service_matrix;now_time-last_time,server_num];
            last_time = now_time;
            queue_len=queue_len+1;
            state(4,i)=queue_len;
            state(6,i)=1;
        end
    end
end
%上个循环结束时队列不一定为空,进一步处理
%与有新顾客到来时处理队列中顾客的思路相似
while queue_len>0
    for k=1:server_num
        if servers(k)==min(servers)
            j = 0;
            m = 1;
            while (j <queue_len)
                if state(6,user_num+1-m) == 1 %在系统内
                    j = j+1;
                end
                m = m+1;
            end
            m = m-1;
            rank=user_num+1-m;
            state(3,rank)=servers(k)-state(1,rank);
            now_time = servers(k);
            queue_matrix = [queue_matrix;now_time-last_time, queue_len];
            service_matrix = [service_matrix;now_time-last_time,server_num];
            last_time = now_time;
            servers(k)=servers(k)+state(2,rank);
            state(5,rank)=servers(k);
            queue_len=queue_len-1;
            break
        end
    end
end                    
end

