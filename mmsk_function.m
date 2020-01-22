function [state,queue_matrix,service_matrix] = mmsk_function(mean_arr,mean_serv,server_num,max_vol,user_num)
%MMSK_FUNTION��������ģ��M/M/S/K�Ŷӹ���,����ģ��������
%   mean_arr��ʾ����ʱ��������
%   mean_serv��ʾ����ʱ�䳣��
%   server_num��ʾ����̨����
%   max_vol��ʾϵͳ�������
%   user_num��ʾģ����ܿͻ�����

state=zeros(6,user_num);
%�����˿͵�״̬�þ���洢
%ÿ�б�ʾһλ�˿�
%��һ��Ϊ����ʱ��
%�ڶ���Ϊ����ʱ��
%������Ϊ�ȴ�ʱ��
%������Ϊ���ù˿͵���ʱ�ĵ�ǰ���г��ȳ�
%�����б�ʾ�ù˿��뿪��ʱ��
%������Ϊ�ù˿��Ƿ����ϵͳ�ı�־,1��ʾ������ϵͳ

%��¼��ͬʱ�̵Ķ��г���
queue_matrix = [];
%��¼��ͬʱ�̵ķ�������
service_matrix = [];

cons1=1/mean_arr;
cons2=1/mean_serv;

queue_len=0;
%queue_len��ʾ���г���
servers=zeros(1,server_num);
%servers��ʾ����������,����ÿ�����������е�ʱ��
last_time = 0;
for i=1:user_num
    %���㵽��ʱ�̺ͷ���ʱ��
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
            %�޶������з��������������̷���
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
            %�޶�����û�з�����������ʼ�Ŷ�
            %���ڿ�ʼ�ŶӵĹ˿�,��ȴ�ʱ����뿪ʱ�����¸��˿͵���ʱ����
            queue_len=queue_len+1;
            %��¼���г��ȱ�Ϊ1�Ŀ�ʼʱ��
            now_time = state(1,i);
            queue_matrix = [queue_matrix;now_time-last_time, 0];
            service_matrix = [service_matrix;now_time-last_time,server_num];
            last_time = now_time;
            state(4,i)=1;
            state(6,i)=1;
        end
    else
        while state(1,i)>min(servers)&&queue_len>0
            %���δ�������еĹ˿�,FIFO
            for k=1:server_num 
                if servers(k)==min(servers)
                    j = 0;
                    m = 1;
                    while (j <queue_len)
                        if state(6,i-m) == 1 %��ϵͳ��
                            j = j+1;
                        end
                        m = m+1;
                    end
                    m = m-1;
                    rank=i-m;
                    state(3,rank)=servers(k)-state(1,rank);
                    % ��¼���г��ȱ��ֲ����ʱ��
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
        %�����iλ�˿�
        if (server_num+queue_len)>=max_vol
            %�����ַ����кͶ����еĹ˿���������max_vol�����,��ֱ�ӿ�����һ���˿�
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
            %�޶������з��������������̷���
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
            %�������������Ŷ�
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
%�ϸ�ѭ������ʱ���в�һ��Ϊ��,��һ������
%�����¹˿͵���ʱ��������й˿͵�˼·����
while queue_len>0
    for k=1:server_num
        if servers(k)==min(servers)
            j = 0;
            m = 1;
            while (j <queue_len)
                if state(6,user_num+1-m) == 1 %��ϵͳ��
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

