function[random_ans]=mms_function(mean_arr,mean_serv,server_num,user_num) 
%�ú���ģ��M/M/S�Ŷӹ���,����ģ��������
%   mean_arrΪ����ʱ��������
%   mean_servΪ����ʱ�䳣��
%   server_numΪ����������
%   user_num��ʾģ����ܿͻ�����
 
state=zeros(5,user_num);   
%�����˿͵�״̬�þ���洢
%ÿ�б�ʾһλ�˿�
%��һ��Ϊ����ʱ��
%�ڶ���Ϊ����ʱ��
%������Ϊ�ȴ�ʱ��
%������Ϊ���ù˿͵���ʱ�ĵ�ǰ���г��ȳ�
%�����б�ʾ�ù˿��뿪��ʱ��
                
state(1,:)=exprnd(1/mean_arr,1,user_num);    
%����ʱ��������ָ���ֲ�
%mean_arrΪ����ʱ��������

state(2,:)=exprnd(1/mean_serv,1,user_num);   
%����ʱ�����ָ���ֲ�
%mean_servΪ����ʱ�䳣��

for i=1:server_num 
    state(3,1:server_num)=0; 
    state(4,1:server_num)=0; %����ʱ���г���Ϊ0
end
%ǰS������Ĺ˿�����ȴ����ȴ�ʱ����0

arr_time=cumsum(state(1,:)); 
%����ʱ��ʹ���ۼƺͺ�������

state(1,:)=arr_time;
%ԭ����ʱ��������Ϊ����ʱ��
state(5,1:server_num)=sum(state(:,1:server_num));
%����ǰS���˿͵��뿪ʱ��
%�뿪ʱ��=����ʱ��+����ʱ��

serv_desk=state(5,1:server_num);
%���������洢ÿ���������Ϲ˿͵��뿪ʱ��
%��ʱ��ʵ����Ҳ��ÿ����������ʼ���е�ʱ��

for i=(server_num+1):user_num 
%    if arr_time(i)>min(serv_desk) 
%        state(3,i)=0;
%        state(4,i)=0; %����ȴ� ���г���Ϊ0
%    else  
%        state(3,i)=min(serv_desk)-arr_time(i);
   serv_desk1 = serv_desk(serv_desk>arr_time(i-1));
   serv_desk2 = serv_desk1(serv_desk1<arr_time(i));
   ok_server_num = length(serv_desk2); %����һ���˿͵���֮�����������̨��
   if state(4,i-1) + 1 <= ok_server_num  %���еķ������������ڶ��г���
       state(4,i) = 0; %����ȴ�
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
           queue_desk = state(5,i+1-state(4:i):i-1); %����ǰ����˵ķ������ʱ��
           state(3,i) = max(queue_desk) - arr_time(i);
       end
%        serv_desk_sort =  sort(serv_desk);
%        if state(4,i)<=server_num
%            state(3,i) = serv_desk_sort(state(4,i)) - arr_time(i); %�ȴ�ʱ��
%        else
%            state(3,i) = 
%        end
   end
   %����iλ�˿͵���ʱ,�������ʱ��С��ĳ�������Ŀ���ʱ��,����ȴ�,�ȴ�ʱ����0
   %�������ʱ�̴��ڿ���ʱ����С�ķ�������,��ȴ�ʱ��Ϊ����ʱ��-����������ʱ��          
%    end 
   state(5,i)=sum(state(1:3,i));
   %�����iλ�˿͵��뿪ʱ��=����ʱ��+����ʱ��+�ȴ�ʱ��
%    for j=1:server_num  
%         if serv_desk(j)==min(serv_desk) 
%             serv_desk(j)=state(5,i);
%             %ÿλ�˿�����ʹ�ö�����Է������ʱ����̵ķ�����,�ʸ��¸÷������Ŀ���ʱ��
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
%         %���г���Ϊ0�����
%         find_max=0;     
%         for j=1:server_num 
%             if serv_desk(j)==zero_time 
%                 find_max=1;
%                 %�п��еķ�������־
%                 break 
%             end 
%         end 
%         if find_max==1 
%             %����serv_desk
%             serv_desk(j)=state(5,i); 
%             for k=1:server_num 
%                 if serv_desk(k)<arr_time(i) 
%                     serv_desk(k)=zero_time; 
%                 end 
%             end 
%         else 
%             if arr_time(i)>min(serv_desk) 
%                 %�˿��������ܽ���
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
%                 %�˿���Ҫ�Ŷӵ����
%                 block_num=block_num+1; 
%                 block_line=block_line+1; 
%             end 
%         end 
%     else
%         %���г��ȳ���Ϊ0�����
%         n=0;
%         %n��ʾi������ʱ�̶������ܹ����ٵ�����
%         %����i����ʱ�ܹ����еķ�����
%         for k=1:server_num 
%             if arr_time(i)>serv_desk(k) 
%                 n=n+1; 
%                 serv_desk(k)=zero_time; 
%             end 
%         end
%         %����i����ʱ����֮ǰ�Ŷӵ��ܹ��뿪�Ĺ˿�
%         for k=1:block_line 
%             if arr_time(i)>state(5,i-k) 
%                 n=n+1;  
%             end 
%         end 
%         if n<block_line+1 
%            % n<block_line+1 means the queue length is still not zero
%            %�ӳ���Ȼ��Ϊ0�����
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
%             %�ӳ�Ϊ0�����
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
%     %����ʱ�Ķ��г��ȸ�ֵ
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



