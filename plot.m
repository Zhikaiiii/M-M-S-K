x = 1:100;
figure;
plot(x,average0,'*r',x,waiting_queue,'*b'),title('ƽ�����г���Lq');
ylim([1.5 3]);
figure;
plot(x,average0+average1,'*r',x,all_queue,'*b'),title('�ܶ��г���L');
ylim([3 6]);
figure;
plot(x,average2,'*r',x,waiting_time,'*b'),title('ƽ���ȴ�ʱ��Wq');
ylim([1.5 3]);
figure;
plot(x,average3,'*r',x,stop_time,'*b'),title('ƽ������ʱ��W');
ylim([3 6]);

