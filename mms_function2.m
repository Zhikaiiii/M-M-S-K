function[random_ans]=mms_function2(mean_arr,mean_serv,server_num,user_num) 
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
arr_time=cumsum(state(1,:)); 
% state(1,:) = arr_time;
state(2,:)=exprnd(1/mean_serv,1,user_num);   
%����ʱ�����ָ���ֲ�
%mean_servΪ����ʱ�䳣��
state(3,1) = 0;
state(4,1) = 0;
state(5,1) = state(1,1) + state(2,1);
server_state = zeros(1, server_num);
%��һ��Ϊ�´ο���ʱ��
%�ڶ���Ϊ�Ƿ����
for i = 2:user_num
    %������з���������
    if min(server_state) == 0 
        %�ȴ�ʱ��Ͷ��г���Ϊ0
        state(3,i) = 0;
        state(4,i) = 0;
        %���еķ�����
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
        %����һ���˿͵���͸ù˿͵���֮�����������̨��
        serv_desk1 = server_state(server_state>arr_time(i-1));
        serv_desk2 = serv_desk1(serv_desk1<=arr_time(i));
        ok_server_num = length(serv_desk2); 
        if state(4,i-1) + 1 <= ok_server_num  %���еķ������������ڵ��ڶ��г���
            state(4,i) = 0; %����ȴ�
            state(3,i) = 0;
            for k = state(4,i-1)+1:1  %���·������´ο���ʱ��
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
            if state(4,i) <= server_num %��Ϊ����ǰ����
                server_sort = sort(server_state);
                state(3,i) = server_sort(state(4,i)) - arr_time(i);
            else
                queue_desk = state(5,i+1-state(4,i):i-server_num); %����ǰ����˵ķ������ʱ��
                state(3,i) = max(queue_desk) - arr_time(i);
            end
        end

   end
   %����iλ�˿͵���ʱ,�������ʱ��С��ĳ�������Ŀ���ʱ��,����ȴ�,�ȴ�ʱ����0
   %�������ʱ�̴��ڿ���ʱ����С�ķ�������,��ȴ�ʱ��Ϊ����ʱ��-����������ʱ��          

   %�����iλ�˿͵��뿪ʱ��=����ʱ��+����ʱ��+�ȴ�ʱ��
%    for j=1:server_num  
%         if serv_desk(j)==min(serv_desk) 
%             serv_desk(j)=state(5,i);
%             %ÿλ�˿�����ʹ�ö�����Է������ʱ����̵ķ�����,�ʸ��¸÷������Ŀ���ʱ��
%             break 
%         end                      
%    end 
end 

state(1,:) = arr_time;
state(5,:)=sum(state(1:3,:));
random_ans = state;
end

