function [state] = queue_network(node_num,mean_arr,mean_serv,user_num, p)
%MMSK_FUNTION��������ģ��M/M/S/K�Ŷӹ���,����ģ��������
%   mean_arr��ʾ����ʱ��������
%   mean_serv��ʾ����ʱ�䳣��
%   server_num��ʾ����̨����
%   user_num��ʾģ����ܿͻ�����
%   node_num��ʾ�������
%   p��ʾת�Ƹ��ʾ���

state=zeros(7,user_num,node_num);
%�����˿͵�״̬�þ���洢
%ÿ�б�ʾһλ�˿�
%��һ��Ϊ����ʱ��
%�ڶ���Ϊ����ʱ��
%������Ϊ�ȴ�ʱ��
%������Ϊ���ù˿͵�ǰ���ڽ��
%�����б�ʾ�ù˿��뿪��ʱ��
%������Ϊ�ù˿��Ƿ����ϵͳ�ı�־,i��ʾ�����˵�i���ڵ�,-1��ʾ�뿪
%�����б�ʾ�Ƿ�������ϵͳ
%����ÿ����㶼��user_num���û�����
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
% %queue_len��ʾ���г���
servers=zeros(1,node_num);
%servers��ʾ����������,����ÿ�����������е�ʱ��
server_num = 1;
while ~isempty(find(state(6,:,:) ~= -1))  %ϵͳ�л��й˿�
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
    %���㵽��ʱ�̺ͷ���ʱ��
%     arr_interval=exprnd(cons1);
    state(2,i,min_idx)=exprnd(cons2);
    
%     if i>1
%         state(1,i)=state(1,i-1)+arr_interval;
%     else
%         state(1,i)=arr_interval;
%     end
    if queue_len(min_idx)==0
        if state(1,i,min_idx)>servers(min_idx)
            %�޶������з��������������̷���
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
            state(1,i,m) = state(5,i,min_idx);  % ������һ������ʱ��
            state(6,i,min_idx) = -1;
            state(6,i,m) = 1;
            state(7,i,m) = 1;
            if sum_prob <= prob
                state(6,i,:) = -1;
            end
%                 state(6,i)=1;
        else
            %�޶�����û�з�����������ʼ�Ŷ�
            %���ڿ�ʼ�ŶӵĹ˿�,��ȴ�ʱ����뿪ʱ�����¸��˿͵���ʱ����
            queue_len(min_idx)=queue_len(min_idx)+1;
            state(4,i,min_idx)=1;
%             state(6,i,min_idx)=1;
        end
    else
        while state(1,i,min_idx)>servers(min_idx)&&queue_len(min_idx)>0
            %���δ�������еĹ˿�,FIFO
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
                    state(1,i,m) = state(5,i,min_idx);  % ������һ������ʱ��
                    state(6,i,min_idx) = -1;
                    state(6,i,m) = 1;
                    state(7,i,m) = 1;
                    if sum_prob <= prob
                        state(6,i,:) = -1;
                    end
                    queue_len(min_idx)=queue_len(min_idx)-1;
        end
        if queue_len(min_idx)==0&&state(1,i,min_idx)>servers(min_idx)
            %�޶������з��������������̷���
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
            state(1,i,m) = state(5,i,min_idx);  % ������һ������ʱ��
            state(6,i,min_idx) = -1;
            state(6,i,m) = 1;
            state(7,i,m) = 1;
            if sum_prob <= prob
                state(6,i,:) = -1;
            end
%             state(6,i,min_idx)=1;
        else
            %�������������Ŷ�
            queue_len(min_idx)=queue_len(min_idx)+1;
            state(4,i,min_idx)=queue_len(min_idx);
            state(6,i,min_idx) = -1;
%             state(6,i,min_idx)=1;
        end
    end
end
%�ϸ�ѭ������ʱ���в�һ��Ϊ��,��һ������
%�����¹˿͵���ʱ��������й˿͵�˼·����
% while queue_len>0
%     for k=1:server_num
%         if servers(k)==min(servers)
%             j = 0;
%             m = 1;
%             while (j <queue_len)
%                 if state(6,user_num+1-m) == 1 %��ϵͳ��
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

