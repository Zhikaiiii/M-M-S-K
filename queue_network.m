function [state] = queue_network(node_num,mean_arr,mean_serv,user_num, p)
%MMSK_FUNTION函数用于模拟M/M/S/K排队过程,返回模拟结果矩阵
%   mean_arr表示到达时间间隔常数
%   mean_serv表示服务时间常数
%   server_num表示服务台个数
%   user_num表示模拟的总客户数量
%   node_num表示结点数量
%   p表示转移概率矩阵

state=zeros(7,user_num,node_num);
%各个顾客的状态用矩阵存储
%每列表示一位顾客
%第一行为到达时刻
%第二行为服务时间
%第三行为等待时间
%第四行为当该顾客当前所在结点
%第五行表示该顾客离开的时间
%第六行为该顾客是否进入系统的标志,i表示进入了第i个节点,-1表示离开
%第七行表示是否进入过该系统
%假设每个结点都有user_num个用户到达
for i = 1:node_num
    arr_time(i,:) = exprnd(1/mean_arr(i),1,user_num/node_num);
    state(1,(i-1)*user_num/node_num + 1:i*user_num/node_num ,i)=cumsum(arr_time(i,:));
    state(6,(i-1)*user_num/node_num + 1:i*user_num/node_num ,i) = 1;
    state(7,(i-1)*user_num/node_num + 1:i*user_num/node_num ,i) = 1;
end

% cons1=1/mean_arr;
cons2=1/mean_serv;
queue_len = zeros(1,node_num);
% queue_len=0;
% %queue_len表示队列长度
servers=zeros(1,node_num);
%servers表示各个服务器,其存放每个服务器空闲的时刻
server_num = 1;
while ~isempty(find(state(6,:,:) ~= -1))  %系统中还有顾客
    while 1
        all_user = state(1,:,:);
        all_user(all_user==0) = 100000;
        [~,min_idx] = min(min(all_user,[],2));
        node_user = state(1,:,min_idx);
        idx = (state(6,:,min_idx) == -1);
        node_user(idx) = 100000;
        node_user(node_user==0) = 100000;
        [~, i] = min(node_user);
        if state(6,i,min_idx) == 1
            break;
        end
    end
    %计算到达时刻和服务时间
%     arr_interval=exprnd(cons1);
    state(2,i,min_idx)=exprnd(cons2);
    
%     if i>1
%         state(1,i)=state(1,i-1)+arr_interval;
%     else
%         state(1,i)=arr_interval;
%     end
    if queue_len(min_idx)==0
        if state(1,i,min_idx)>servers(min_idx)
            %无队列且有服务器空闲则立刻服务
            servers(min_idx)=state(1,i,min_idx)+state(2,i,min_idx);
            state(3,i,min_idx)=0;
            state(4,i,min_idx)=0;
            state(5,i,min_idx)=servers(min_idx);
            prob = rand;
            sum_prob = 0;
            for m = 1:node_num
                sum_prob = p(min_idx,m) + sum_prob;
                if sum_prob > prob
                    break;
                end
            end
            state(1,i,m) = state(5,i,min_idx);  % 到达下一个结点的时间
            state(6,i,min_idx) = -1;
            state(6,i,m) = 1;
            state(7,i,m) = 1;
            if sum_prob <= prob
                state(6,i,:) = -1;
            end
%                 state(6,i)=1;
        else
            %无队列且没有服务器空闲则开始排队
            %对于开始排队的顾客,其等待时间和离开时间在下个顾客到来时计算
            queue_len(min_idx)=queue_len(min_idx)+1;
            state(4,i,min_idx)=1;
%             state(6,i,min_idx)=1;
        end
    else
        while state(1,i,min_idx)>servers(min_idx)&&queue_len(min_idx)>0
            %依次处理队列中的顾客,FIFO
                    rank=i-queue_len(min_idx);
                    state(3,rank,min_idx)=servers(min_idx)-state(1,rank,min_idx);
                    servers(min_idx)=servers(min_idx)+state(2,rank,min_idx);
                    state(5,rank,min_idx)=servers(min_idx);
                    prob = rand;
                    sum_prob = 0;
                    for m = 1:node_num
                        sum_prob = p(min_idx,m) + sum_prob;
                        if sum_prob > prob
                            break;
                        end
                    end
                    state(1,i,m) = state(5,i,min_idx);  % 到达下一个结点的时间
                    state(6,i,min_idx) = -1;
                    state(6,i,m) = 1;
                    state(7,i,m) = 1;
                    if sum_prob <= prob
                        state(6,i,:) = -1;
                    end
                    queue_len(min_idx)=queue_len(min_idx)-1;
        end
        if queue_len(min_idx)==0&&state(1,i,min_idx)>servers(min_idx)
            %无队列且有服务器空闲则立刻服务
            servers(min_idx)=state(1,i,min_idx)+state(2,i,min_idx);
            state(3,i,min_idx)=0;
            state(4,i,min_idx)=0;
            state(5,i,min_idx)=servers(min_idx);
            prob = rand;
            sum_prob = 0;
            for m = 1:node_num
                sum_prob = p(min_idx,m) + sum_prob;
                if sum_prob > prob
                    break;
                end
            end
            state(1,i,m) = state(5,i,min_idx);  % 到达下一个结点的时间
            state(6,i,min_idx) = -1;
            state(6,i,m) = 1;
            state(7,i,m) = 1;
            if sum_prob <= prob
                state(6,i,:) = -1;
            end
%             state(6,i,min_idx)=1;
        else
            %否则进入队列中排队
            queue_len(min_idx)=queue_len(min_idx)+1;
            state(4,i,min_idx)=queue_len(min_idx);
            state(6,i,min_idx) = -1;
%             state(6,i,min_idx)=1;
        end
    end
end
%上个循环结束时队列不一定为空,进一步处理
%与有新顾客到来时处理队列中顾客的思路相似
% while queue_len>0
%     for k=1:server_num
%         if servers(k)==min(servers)
%             j = 0;
%             m = 1;
%             while (j <queue_len)
%                 if state(6,user_num+1-m) == 1 %在系统内
%                     j = j+1;
%                 end
%                 m = m+1;
%             end
%             m = m-1;
%             rank=user_num+1-m;
%             state(3,rank)=servers(k)-state(1,rank);
%             servers(k)=servers(k)+state(2,rank);
%             state(5,rank)=servers(k);
%             queue_len=queue_len-1;
%             break
%         end
%     end
% end                    
end

