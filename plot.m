x = 1:100;
figure;
plot(x,average0,'*r',x,waiting_queue,'*b'),title('平均队列长度Lq');
ylim([1.5 3]);
figure;
plot(x,average0+average1,'*r',x,all_queue,'*b'),title('总队列长度L');
ylim([3 6]);
figure;
plot(x,average2,'*r',x,waiting_time,'*b'),title('平均等待时间Wq');
ylim([1.5 3]);
figure;
plot(x,average3,'*r',x,stop_time,'*b'),title('平均逗留时间W');
ylim([3 6]);

