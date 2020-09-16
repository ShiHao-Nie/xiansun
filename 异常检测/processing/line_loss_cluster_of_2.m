clear all
data=load('Line_Loss_data2.csv')
data=data(1:end-1,:);%������1001�����ݣ�Ϊ�˺ÿ�����1000�����ݣ�Ҳ���Ը�matpower���������ɵĳ���
ADLabel=data(:,end);
Data=data(:,1:end-1);

idx=kmeans(Data,2);

data1=data(find(idx==1),:);
data2=data(find(idx==2),:);
disp('�쳣����  �����')
disp([find(ADLabel==1),idx(find(ADLabel==1))]);%�쳣�ڵ���š����

%--------ֱ��isolationɭ��
figure
Score_N=iforest(data);%������ֱ�ӹ���ɭ�ֵõ����쳣����
Score_N=mapminmax(Score_N',0,1)';%��һ����[0,1]
figure
plot(Score_N,'b*')
hold on
plot(find(ADLabel==1),Score_N(find(ADLabel==1)),'ro')
title('������������ɭ�ֵĽ��')


%-------�Ⱦ�����isolationɭ��
figure
Score1=iforest(data1);
Score2=iforest(data2);
Score=zeros(size(data,1),1);
j=1;k=1;
for i=1:size(data,1)
    if idx(i)==1
        Score(i)=Score1(j);
        j=j+1;
    else
        Score(i)=Score2(k);
        k=k+1;
    end
end

%---------------�쳣������һ��
Score_01=mapminmax(Score',0,1)';%��һ���Ƕ����������е�,01�����һ����10��������
figure
plot(Score_01,'b*')
hold on
plot(find(ADLabel==1),Score_01(find(ADLabel==1)),'ro')
title('����֮��������ɭ�ֵ��쳣����')
%----------��������ʾ��ͼ
[~,x1]=sort(Score1);
[~,x2]=sort(Score2);
[~,X]=sort(Score);

figure
    subplot(1,3,1)
    plot(data1(:,1),data1(:,2),'k*')
    hold on
    plot(data2(:,1),data2(:,2),'b*')
    plot(data(find(ADLabel==1),1),data(find(ADLabel==1),2),'ro')

    subplot(1,3,2)
    plot(data1(:,1),data1(:,2),'k*')
    hold on
    plot(data2(:,1),data2(:,2),'b*')
    plot(data(X(end-5:end),1),data(X(end-5:end),2),'ro')


    subplot(1,3,3)
    plot(data1(:,1),data1(:,2),'k*')
    hold on
    plot(data2(:,1),data2(:,2),'b*')
    plot(data(X(end-10:end),1),data(X(end-10:end),2),'ro')


%-----------------------�������е�һ��ͼ��Ҳ������ͼ�е�subplot(1,3,3)
figure
clf
plot(data1(:,1),data1(:,2),'ko','MarkerSize',4,'LineWidth',0.0001,'MarkerFaceColor','b')
hold on
plot(data2(:,1),data2(:,2),'ko','MarkerSize',4,'LineWidth',0.0001,'MarkerFaceColor','y')

plot(data(X(end-11:end),1),data(X(end-11:end),2),'ro','MarkerSize',10)
xlabel('Gen power')
ylabel('line loss')
title('isolation forest data')



%------------�������еڶ���ͼ��ROC������AUC������Ҫ�ˣ�������
%�õ����еĺ�������Ҫ����score����Ҫ��ifrest�е�Score������ֻ�������һ��ѭ����score
Score1_10=iforest_Score10(data1);
Score2_10=iforest_Score10(data2);
Score_10=zeros(size(data,1),10);
j=1;k=1;
for i=1:size(data,1)
    if idx(i)==1
        Score_10(i,:)=Score1_10(j,:);
        j=j+1;
    else
        Score_10(i,:)=Score2_10(k,:);
        k=k+1;
    end
end
Score_10=mapminmax(Score_10',0,1)';%��һ��
figure
for r=1:10
    hold on
    [Xlog,Ylog,Tlog,AUClog] = perfcurve(logical(ADLabel),Score_10(:,r),'true');
    plot(Xlog,Ylog)
    xlabel('False positive rate'); ylabel('True positive rate');
    title('AUC')
end
axis([-0.2,1,-0.2,1])

%����AUC����ֻ��һ��������⣬����MATLAB�Դ���
%-------AUC���߲��ʺ���������⣬�ĳ�PR���ߣ�ת��plot_PR
