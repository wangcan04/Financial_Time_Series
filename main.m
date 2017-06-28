function result=svmlevel1_test(industry,hs300,N,M)
%全部数据做标准化，采用滑动预测的方法，设定窗口长度及预测步数
[row1,column1]=size(industry);
[row3,column3]=size(hs300);
Zindustry=zscore(industry);
Zhs300=zscore(hs300);
%N=30; %时间窗口长度
%M=10; %滑动次数
P=1; %往前预测步数
result=zeros(M,2*P);
t=cputime;
cut=1; %加cut 的目的是从序列中任一点为起点，不一定要从第一个点开始
Zindustry=Zindustry(cut:row1,:);
Zhs300=Zhs300(cut:row3,:);
for i=1:M
training_data_part1=Zindustry(i:(N+i-1),:);
training_data_part2=Zindustry((N+i):(N+P+i-1),:);
testing_data_part1=Zhs300((i+1):(N+i),:);
testing_data_part2=Zhs300((N+i+1):(N+P+i),:);
temp=zeros(21);
j=1;
for log2c = -10:10
k=1;
for log2g = -10:10
cmd=['-s 3 -q -t 2 -q -c ',num2str(2^log2c), ' -q -g ',num2str(2^log2g), '
-q -p 0.01 -q'];
model=svmtrain(testing_data_part1,training_data_part1,cmd);
[predict,mse,deci]=svmpredict(testing_data_part2,training_data_part2,model,'-b 0
-q');
temp(j,k)=norm(predict-testing_data_part2);
k=k+1;
end
j=j+1;
end
[row,column]=find(temp==min(min(temp)),1,'first');
cmd=['-s 3 -q -t 2 -q -c ',num2str(2^(row-11)), ' -q -g ',num2str(2^(column-11)), '
-q -p 0.01 -q']; %防止出现有多个最优值的情况
model=svmtrain(testing_data_part1,training_data_part1,cmd);
%model=svmtrain(testing_data_part1,training_data_part1,'-s 3 -q -t 2 -q -c 1024
-q -g 1 -q -p 0.01 -q');
[ptesting_data_part2,mse,deci]=svmpredict(testing_data_part2,training_data_part2,m
odel,'-b 0 -q');
for l=1:P
result(i,(2*l-1))=ptesting_data_part2(l,1);
result(i,(2*l))=testing_data_part2(l,1);
end
end
%[ptesting_data_part1,mse,deci]=svmpredict(testing_data_part1,training_data_part1,
model,'-b 0');
tt=cputime-t
end
