function[random_ans]=mms_function(mean_arr,mean_serv,server_num,user_num) 
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

state(2,:)=exprnd(1/mean_serv,1,user_num);   
%服务时间服从指数分布
%mean_serv为服务时间常数

for i=1:server_num 
    state(3,1:server_num)=0; 
    state(4,1:server_num)=0; %到达时队列长度为0
end
%前S个到达的顾客无需等待，等待时间置0

arr_time=cumsum(state(1,:)); 
%到达时间使用累计和函数计算

state(1,:)=arr_time;
%原到达时间间隔更新为到达时间
state(5,1:server_num)=sum(state(:,1:server_num));
%计算前S个顾客的离开时间
%离开时间=到达时间+服务时间

serv_desk=state(5,1:server_num);
%创建向量存储每个服务器上顾客的离开时间
%该时间实际上也是每个服务器开始空闲的时间

for i=(server_num+1):user_num 
%    if arr_time(i)>min(serv_desk) 
%        state(3,i)=0;
%        state(4,i)=0; %无需等待 队列长度为0
%    else  
%        state(3,i)=min(serv_desk)-arr_time(i);
   serv_desk1 = serv_desk(serv_desk>arr_time(i-1));
   serv_desk2 = serv_desk1(serv_desk1<arr_time(i));
   ok_server_num = length(serv_desk2); %在上一个顾客到达之后服务器空闲台数
   if state(4,i-1) + 1 <= ok_server_num  %空闲的服务器数量大于队列长度
       state(4,i) = 0; %无需等待
       state(3,i) = 0;
       for k = state(4,i-1)+1:1
           [~,idx] = min(serv_desk);
           serv_desk(idx) = serv_desk(idx) + state(2,i+1-k);
       end
   else
       state(4,i) = state(4,i-1)+ 1 - ok_server_num;
       for k = ok_server_num:1
           [~,idx] = min(serv_desk);
           serv_desk(idx) = serv_desk(idx) + state(2,i+1-k);
       end
       if state(4,i) == 1
           state(3,i) = min(serv_desk) - arr_time(i);
       else
           queue_desk = state(5,i+1-state(4:i):i-1); %队列前面的人的服务结束时间
           state(3,i) = max(queue_desk) - arr_time(i);
       end
%        serv_desk_sort =  sort(serv_desk);
%        if state(4,i)<=server_num
%            state(3,i) = serv_desk_sort(state(4,i)) - arr_time(i); %等待时间
%        else
%            state(3,i) = 
%        end
   end
   %当第i位顾客到来时,如果到达时刻小于某服务器的空闲时刻,无需等待,等待时间置0
   %如果到达时刻大于空闲时刻最小的服务器的,其等待时间为到达时刻-服务器空闲时间          
%    end 
   state(5,i)=sum(state(1:3,i));
   %计算第i位顾客的离开时刻=到达时刻+服务时间+等待时间
%    for j=1:server_num  
%         if serv_desk(j)==min(serv_desk) 
%             serv_desk(j)=state(5,i);
%             %每位顾客优先使用对其而言服务空闲时间最短的服务器,故更新该服务器的空闲时间
%             break 
%         end                      
%    end 
end 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%second part: compute the queue length during the whole service interval
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        
% zero_time=0;
% %zero_time is used to identify which server is empty 
% 
% serv_desk(1:server_num)=0; 
% block_num=0; 
% block_line=0; 
% for i=1:user_num 
%     if block_line==0
%         %队列长度为0的情况
%         find_max=0;     
%         for j=1:server_num 
%             if serv_desk(j)==zero_time 
%                 find_max=1;
%                 %有空闲的服务器标志
%                 break 
%             end 
%         end 
%         if find_max==1 
%             %更新serv_desk
%             serv_desk(j)=state(5,i); 
%             for k=1:server_num 
%                 if serv_desk(k)<arr_time(i) 
%                     serv_desk(k)=zero_time; 
%                 end 
%             end 
%         else 
%             if arr_time(i)>min(serv_desk) 
%                 %顾客来到即能接受
%                 for k=1:server_num 
%                     if arr_time(i)>serv_desk(k) 
%                         serv_desk(k)=state(5,i); 
%                         break 
%                     end 
%                 end 
%                 for k=1:server_num 
%                     if arr_time(i)>serv_desk(k) 
%                         serv_desk(k)=zero_time; 
%                     end 
%                 end 
%             else
%                 %顾客需要排队的情况
%                 block_num=block_num+1; 
%                 block_line=block_line+1; 
%             end 
%         end 
%     else
%         %队列长度长不为0的情况
%         n=0;
%         %n表示i到来的时刻队列中能够减少的人数
%         %处理i到来时能够空闲的服务器
%         for k=1:server_num 
%             if arr_time(i)>serv_desk(k) 
%                 n=n+1; 
%                 serv_desk(k)=zero_time; 
%             end 
%         end
%         %处理i到来时在其之前排队的能够离开的顾客
%         for k=1:block_line 
%             if arr_time(i)>state(5,i-k) 
%                 n=n+1;  
%             end 
%         end 
%         if n<block_line+1 
%            % n<block_line+1 means the queue length is still not zero
%            %队长仍然不为0的情况
%             block_num=block_num+1; 
%             for k=0:n-1 
%                 if state(5,i-block_line+k)>arr_time(i) 
%                     for m=1:server_num 
%                         if serv_desk(m)==zero_time 
%                             serv_desk(m)=state(5,i-block_line+k); 
%                             break  
%                         end 
%                     end  
%                 end 
%             end 
%             block_line=block_line-n+1; 
%         else
%             %队长为0的情况
%             for k=0:block_line 
%                 if arr_time(i)<state(5,i-k) 
%                     for m=1:server_num 
%                         if serv_desk(m)==zero_time 
%                             serv_desk(m)=state(5,i-k); 
%                             break  
%                         end 
%                     end 
%                 else 
%                     continue 
%                 end 
%             end 
%             block_line=0; 
%         end 
%     end
%     %到达时的队列长度赋值
%     state(4,i)=block_line;
% end
random_ans=state;
                                                    

% plot(state(1,:),'*-');
% figure
% plot(state(2,:),'g');
% figure
% plot(state(3,:),'r*');
% figure
% plot(state(4,:),'y*');
% figure
% plot(state(5,:),'*-');
%  



