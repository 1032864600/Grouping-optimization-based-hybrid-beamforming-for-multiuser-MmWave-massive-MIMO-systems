clc;
close all;
clear all;
N=1e2;
N_cl = 8;                   % �ռ��дص��ܸ��� 
N_ray = 10;                   % ÿ���������ߵĸ���
Nr = 64;                     % ��վ�����ߵĸ���
N_rf = 8;                    % ��վ����Ƶ���ĸ���
K=8;                         %�û���
col=Nr;
group=cell(K/2,1);      %%%% ���K/2�顣
SNR_db = -20:10:20;              %����ȵ�����
SNR = 10.^(SNR_db./10);
Loop = 1:length(SNR_db);         % Loop��ʼ�� length�������ĳ���
rate_group = zeros(length(SNR_db), 1);
rate_zf = zeros(length(SNR_db), 1); 
rate_gre=zeros(length(SNR_db), 1); 
rate_ma=zeros(length(SNR_db), 1);
rate_hunhe = zeros(length(SNR_db), 1);
for Loop = 1:length(SNR_db) %�����ѭ��
    for Loop_1 = 1 : N %ѭ������
        %%%%%%%%    �ŵ��Ľ���
        fai = zeros(K,N_cl*N_ray);  %%%% �ǶȾ���
        for kk=1:K
            fai_1=2*pi*rand(N_cl,1);
            for ii=1:N_cl
                mu=fai_1(ii,1); %��ֵ
                sigma=0.1; %��׼�����Ŀ�ƽ��
                b=sigma/sqrt(2); %���ݱ�׼������Ӧ��b
                a=rand(N_ray,1)-0.5; 
                x=b*sign(a).*log(1-2*abs(a)); %���ɷ���������˹�ֲ����������
                for jj=1:N_ray
                    fai(kk,(ii-1)*N_ray+jj)=fai_1(ii,1)-x(jj,1);
                end
            end
        end
        H = zeros(Nr,K);
        H1= zeros(Nr,K*N_cl);
        r = sqrt(( Nr) / (N_cl * N_ray));  % ��һ��һ����
        airfa = (randn(N_cl * N_ray, 1) + sqrt(-1)*randn(N_cl * N_ray, 1)) / sqrt(2); % ÿ��·��������            
        for kk=1:K
            for nn = 1 : N_cl * N_ray
                H(:,kk) =H(:,kk)+r*airfa(nn,1)*exp(sqrt(-1) * pi * (0:1:Nr-1) * sin(fai(kk,nn)))'/sqrt(Nr); 
            end
        end
        %%% H1 ��������Ϊ�����Ӧ�û����뱾�� ÿһ�صĶ���ŵ����һ����ʵ���ŵ�Ϊ����ع�ͬ���
        for kk=1:K
            for n1=1:N_cl
                for n2=1:N_ray
                    H1(:,(kk-1)*N_cl+n1)=H1(:,(kk-1)*N_cl+n1)+ r*airfa((n1-1)*N_ray+n2,1)*exp(sqrt(-1) * pi * (0:1:Nr-1) * sin(fai(kk,(n1-1)*N_ray+n2)))'/sqrt(Nr);
                end
            end
        end
        %%%%%%%%%%%%  �ŵ�������Եļ���
        comp=zeros(K,K);
        pst=zeros(K,K);
        for ii=1:K
            for jj=1:K
                if ii~=jj 
                    comp(ii,jj)=abs(H(:,ii)'*H(:,jj))^2;
                    if ii > jj
                        pst(ii,jj)=abs(H(:,ii)'*H(:,jj))^2;
                    else
                    end
                else
                end
            end
        end
        %%%%%%%%  ���ݸ�������Է��� ��һ�� �ķ������
        c_group=0;
        KK=K;
        B=zeros(K,1);
        ind_shu=zeros(K/2,1); % ��Ӧ����Ԫ����
        for ii=1:K/2
            group{ii,1}=zeros(K,1);
            if KK>=3
                c_group=c_group+1;        %��������
                [x_1,x_2]=find(pst==max(max(pst)));
                ind_shu(ii,1)=ind_shu(ii,1)+1;
                group{ii,1}(ind_shu(ii,1),1)=x_1;
                ind_shu(ii,1)=ind_shu(ii,1)+1;
                group{ii,1}(ind_shu(ii,1),1)=x_2;    
                avg_1=mean(comp(:,x_1))*K/KK;%%% ��comp��Ԫ�ز��ϼ�С����ֵӦΪ�ܺͳ�KK
                avg_2=mean(comp(:,x_2))*K/KK;
                counter_1=0;  %��һ����������ε�����
                temp_1=zeros(K,1);
                for kk=1:K
                    if comp(kk,x_1)>avg_1 && comp(kk,x_2)>avg_2
                        counter_1=counter_1+1;
                        temp_1(counter_1,1)=kk;
                    else
                    end
                end
                avg_zz = zeros(counter_1+1, 1);
                avg_zz(1:2,1) = [avg_1; avg_2;];
                if counter_1==1
                    ind_shu(ii,1)=ind_shu(ii,1)+1;
                    group{ii,1}(ind_shu(ii,1),1)= temp_1(counter_1,1);
                    x_3=group{ii,1}(ind_shu(ii,1),1);
                else
                    if counter_1>1
                        num=zeros(counter_1,1);
                        for kk=1:counter_1
                            num(kk,1)=comp(temp_1(kk,1),x_1)+comp(temp_1(kk,1),x_2);
                        end
                        [~,qq]=max(num);
                        ind_shu(ii,1)=ind_shu(ii,1)+1;
                        group{ii,1}(ind_shu(ii,1),1)= temp_1(qq,1);
                        x_3 = group{ii,1}(ind_shu(ii,1),1);
                        avg_3=mean(comp(:,x_3))*K/KK;
                        avg_zz(3, 1) = avg_3;
                    else
                    end
                end
                user_c = 3;
                counter_1 = counter_1 - 1;
                while counter_1>0
                    counter_2=0;
                    temp_2=zeros(K,1);
                    for kk=1:K
                        flag_t = 0;
                        for kkxx = 1 : user_c
                            if comp(kk,group{ii,1}(kkxx,1))>avg_zz(kkxx, 1)
                            else
                                flag_t = 1;
                                break;
                            end
                        end
                        if flag_t < 1
                            counter_2=counter_2+1;
                            temp_2(counter_2,1)=kk;
                        else
                        end
                    end
                    if counter_2==1
                        ind_shu(ii,1)=ind_shu(ii,1)+1;
                        group{ii,1}(ind_shu(ii,1),1)= temp_2(counter_2,1);
                        x_4=group{ii,1}(ind_shu(ii,1),1);
                    end
                    if counter_2>1
                        num=zeros(counter_2,1);
                        for kk=1:counter_2
                            num(kk,1)=comp(temp_2(kk,1),x_1)+comp(temp_2(kk,1),x_2)+comp(temp_2(kk,1),x_3);
                        end
                        [~,qq]=max(num);
                        ind_shu(ii,1)=ind_shu(ii,1)+1;
                        group{ii,1}(ind_shu(ii,1),1)= temp_2(qq,1);
                        x_4=group{ii,1}(ind_shu(ii,1),1);
                    end
                    if counter_2 > 0
                        user_c = user_c + 1;
                        avg_zz(user_c, 1)=mean(comp(:,x_4))*K/KK;
                    else
                    end
                    counter_1 = counter_1 - 1;
                end
            end
            if KK==2
                c_group=c_group+1;
                [x_1,x_2]=find(pst==max(max(pst)));
                ind_shu(ii,1)=ind_shu(ii,1)+1;
                group{ii,1}(ind_shu(ii,1),1)=x_1;
                ind_shu(ii,1)=ind_shu(ii,1)+1;
                group{ii,1}(ind_shu(ii,1),1)=x_2;
            end
            B=union(B,group{ii,1});
            if KK==1   
                A=(1:K);
                D=setxor(A,B);
                c_group=c_group+1;
                ind_shu(ii,1)=ind_shu(ii,1)+1;
                group{ii,1}(ind_shu(ii,1),1)=D(D~=0);
            end
            KK=KK-ind_shu(ii,1);
            for kk=1:ind_shu(c_group,1)
                comp(:,group{c_group,1}(kk,1))=0;
                comp(group{c_group,1}(kk,1),:)=0;
                pst(:,group{c_group,1}(kk,1))=0;
                pst(group{c_group,1}(kk,1),:)=0;
            end
        end
        %%%%%% �뱾�����ã�-pi/2��pi/2
        F=zeros(Nr,col);
        for kk=1:col
            F(:,kk)=(exp(1j * pi * (0:1:Nr-1) * sin(pi*(kk-1-col/2)/col))/sqrt(Nr))';
        end
        %%%%%%�㷨����
        number=zeros(col,1);
        ttt=0; %Hh�ĵ�������
        Wrf_ben=zeros(Nr,K);
        qqq=0;
        www=0;
        for ii=1:c_group   %����㣬��ѭ��
            ind_1=cell(ind_shu(ii,1),1);
            for jj=1:ind_shu(ii,1)  %Ԥѡ�뱾����
                ind_1{jj,1}=zeros(N_cl,1);
                for kk=1:col
                    number(kk,1)=abs(H(:,group{ii,1}(jj,1))'*F(:,kk));%�ҳ�����ÿ���û���Ԥѡ�뱾
                end
                for k1=1:N_cl
                    [~,ind_1{jj,1}(k1,1)]=max(number);
                    number(ind_1{jj,1}(k1,1),1)=0;
                end
            end
            qqq=qqq+ind_shu(ii,1);
            www=qqq-ind_shu(ii,1);
            Hh=zeros(Nr,qqq);
            Wrf_dd=zeros(Nr,qqq);
            if ii>1
                Hh(:,1:www)=HHh(:,1:www);
                Wrf_dd(:,1:www)=Wrf_ben(:,1:www);
            end
            for jj=1:ind_shu(ii,1) %  H ��������Ϊ Hh 
                ttt=ttt+1;
                Hh(:,ttt) = H(:,group{ii,1}(jj,1)); 
            end
            HHh=Hh;
            if ind_shu(ii,1)==6  %%%%������6���û����
                [~,nn]=size(Hh);%%���ʱ���������û���
                rate_1=zeros(N_cl^6,1);
                for iii=1:N_cl
                    Wrf_dd(:,nn-5)=F(:,ind_1{1,1}(iii,1));
                    for zzz=1:N_cl
                        Wrf_dd(:,nn-4)=F(:,ind_1{2,1}(zzz,1));
                        for xxx=1:N_cl
                            Wrf_dd(:,nn-3)=F(:,ind_1{3,1}(xxx,1));
                            for ccc=1:N_cl
                                Wrf_dd(:,nn-2)=F(:,ind_1{4,1}(ccc,1));
                                for vvv=1:N_cl
                                    Wrf_dd(:,nn-1)=F(:,ind_1{5,1}(vvv,1));
                                    for bbb=1:N_cl
                                        Wrf_dd(:,nn)=F(:,ind_1{6,1}(bbb,1));
                                        Hx=Wrf_dd'*Hh;
                                        Wbb_dd=Hx/(Hx'*Hx+eye(nn));
                                        HHH=Wrf_dd*Wbb_dd; 
                                        power_dd=zeros(nn,1);
                                        rao_dd=zeros(nn,1);
                                        zao_dd=zeros(nn,1);
                                        for jjj=1:nn
                                            power_dd(jjj,1)=(abs(HHH(:,jjj)'*Hh(:,jjj)))^2;
                                            for kkk = 1 : nn
                                                if jjj == kkk
                                                    continue;
                                                else
                                                    rao_dd(jjj,1)= rao_dd(jjj,1) + (abs(HHH(:,jjj)'*Hh(:,kkk)))^2;
                                                end
                                            end
                                            zao_dd(jjj,1)=(norm(HHH(:,jjj),2))^2;
                                            tt=bbb+(vvv-1)*N_cl+(ccc-1)*N_cl^2+(xxx-1)*N_cl^3+(zzz-1)*N_cl^4+(iii-1)*N_cl^5;
                                            rate_1(tt,1)=rate_1(tt,1)+log2(1+power_dd(jjj,1)/(rao_dd(jjj,1)+zao_dd(jjj,1)/SNR(Loop)));
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                [~,mm]=max(rate_1);
                flag1=0;
                for iii=1:N_cl
                    for zzz = 1 : N_cl
                        for xxx=1:N_cl
                            for ccc=1:N_cl
                                for vvv=1:N_cl
                                    for bbb=1:N_cl
                                        if mm==bbb+(vvv-1)*N_cl+(ccc-1)*N_cl^2+(xxx-1)*N_cl^3+(zzz-1)*N_cl^4+(iii-1)*N_cl^5;
                                            z1=iii;
                                            z2=zzz;
                                            z3=xxx;
                                            z4=ccc;
                                            z5=vvv;
                                            z6=bbb;
                                            flag1=1;
                                            break
                                        end
                                    end
                                    if flag1==1
                                        break
                                    end
                                end
                                if flag1==1
                                    break
                                end
                            end
                            if flag1==1
                                break
                            end
                        end
                        if flag1==1
                            break
                        end
                    end
                    if flag1==1
                        break
                    end
                end
                Wrf_ben(:,nn-5)=F(:,ind_1{1,1}(z1,1));
                Wrf_ben(:,nn-4)=F(:,ind_1{2,1}(z2,1));
                Wrf_ben(:,nn-3)=F(:,ind_1{3,1}(z3,1));
                Wrf_ben(:,nn-2)=F(:,ind_1{4,1}(z4,1));
                Wrf_ben(:,nn-1)=F(:,ind_1{5,1}(z5,1));
                Wrf_ben(:,nn)=F(:,ind_1{6,1}(z6,1));
            end
            if ind_shu(ii,1)==5  %%%%������5���û����
                [~,nn]=size(Hh); %%���ʱ���������û���
                rate_1=zeros(N_cl^5,1);
                for iii=1:N_cl
                    Wrf_dd(:,nn-4)=F(:,ind_1{1,1}(iii,1));
                    for zzz=1:N_cl
                        Wrf_dd(:,nn-3)=F(:,ind_1{2,1}(zzz,1));
                        for xxx=1:N_cl
                            Wrf_dd(:,nn-2)=F(:,ind_1{3,1}(xxx,1));
                            for ccc=1:N_cl
                                Wrf_dd(:,nn-1)=F(:,ind_1{4,1}(ccc,1));
                                for vvv=1:N_cl
                                    Wrf_dd(:,nn)=F(:,ind_1{5,1}(vvv,1));
                                    Hx=Wrf_dd'*Hh;
                                    Wbb_dd=Hx/(Hx'*Hx+eye(nn));
                                    HHH=Wrf_dd*Wbb_dd;
                                    power_dd=zeros(nn,1);
                                    rao_dd=zeros(nn,1);
                                    zao_dd=zeros(nn,1);
                                    for jjj=1:nn
                                        power_dd(jjj,1)=(abs(HHH(:,jjj)'*Hh(:,jjj)))^2;
                                        for kkk = 1 : nn
                                            if jjj == kkk
                                                continue;
                                            else
                                                rao_dd(jjj,1)= rao_dd(jjj,1) + (abs(HHH(:,jjj)'*Hh(:,kkk)))^2;
                                            end
                                        end
                                        zao_dd(jjj,1)=(norm(HHH(:,jjj),2))^2;
                                        tt=vvv+(ccc-1)*N_cl+(xxx-1)*N_cl^2+(zzz-1)*N_cl^3+(iii-1)*N_cl^4;
                                        rate_1(tt,1)=rate_1(tt,1)+log2(1+power_dd(jjj,1)/(rao_dd(jjj,1)+zao_dd(jjj,1)/SNR(Loop)));
                                    end
                                end
                            end
                        end
                    end
                end
                [~,mm]=max(rate_1);
                flag1=0;
                for iii=1:N_cl
                    for zzz = 1 : N_cl
                        for xxx=1:N_cl
                            for ccc=1:N_cl
                                for vvv=1:N_cl
                                    if mm==vvv+(ccc-1)*N_cl+(xxx-1)*N_cl^2+(zzz-1)*N_cl^3+(iii-1)*N_cl^4;
                                        z1=iii;
                                        z2=zzz;
                                        z3=xxx;
                                        z4=ccc;
                                        z5=vvv;
                                        flag1=1;
                                        break
                                    end
                                end
                                if flag1==1
                                    break
                                end
                            end
                            if flag1==1
                                break
                            end
                        end
                        if flag1==1
                            break
                        end
                    end
                    if flag1==1
                        break
                    end
                end
                Wrf_ben(:,nn-4)=F(:,ind_1{1,1}(z1,1));
                Wrf_ben(:,nn-3)=F(:,ind_1{2,1}(z2,1));
                Wrf_ben(:,nn-2)=F(:,ind_1{3,1}(z3,1));
                Wrf_ben(:,nn-1)=F(:,ind_1{4,1}(z4,1));
                Wrf_ben(:,nn)=F(:,ind_1{5,1}(z5,1));
            end
            if ind_shu(ii,1)==4  %%%%������4���û����
                [~,nn]=size(Hh);%%���ʱ���������û���
                rate_1=zeros(N_cl^4,1);
                for iii=1:N_cl
                    Wrf_dd(:,nn-3)=F(:,ind_1{1,1}(iii,1));
                    for zzz=1:N_cl
                        Wrf_dd(:,nn-2)=F(:,ind_1{2,1}(zzz,1));
                        for xxx=1:N_cl
                            Wrf_dd(:,nn-1)=F(:,ind_1{3,1}(xxx,1));
                            for ccc=1:N_cl
                                Wrf_dd(:,nn)=F(:,ind_1{4,1}(ccc,1));
                                Hx=Wrf_dd'*Hh;
                                Wbb_dd=Hx/(Hx'*Hx+eye(nn));
                                HHH=Wrf_dd*Wbb_dd;
                                power_dd=zeros(nn,1);
                                rao_dd=zeros(nn,1);
                                zao_dd=zeros(nn,1);
                                for jjj=1:nn
                                    power_dd(jjj,1)=(abs(HHH(:,jjj)'*Hh(:,jjj)))^2;
                                    for kkk = 1 : nn
                                        if jjj == kkk
                                            continue;
                                        else
                                            rao_dd(jjj,1)= rao_dd(jjj,1) + (abs(HHH(:,jjj)'*Hh(:,kkk)))^2;
                                        end
                                    end
                                    zao_dd(jjj,1)=(norm(HHH(:,jjj),2))^2;
                                    tt=ccc+(xxx-1)*N_cl+(zzz-1)*N_cl^2+(iii-1)*N_cl^3;
                                    rate_1(tt,1)=rate_1(tt,1)+log2(1+power_dd(jjj,1)/(rao_dd(jjj,1)+zao_dd(jjj,1)/SNR(Loop)));
                                end
                            end
                        end
                    end
                end
                [~,mm]=max(rate_1);
                flag1=0;
                for iii=1:N_cl
                    for zzz = 1 : N_cl
                        for xxx=1:N_cl
                            for ccc=1:N_cl
                                if mm==ccc+(xxx-1)*N_cl+(zzz-1)*N_cl^2+(iii-1)*N_cl^3
                                    z1=iii;
                                    z2=zzz;
                                    z3=xxx;
                                    z4=ccc;
                                    flag1=1;
                                    break
                                end
                            end
                            if flag1==1
                                break
                            end
                        end
                        if flag1==1
                            break
                        end
                    end
                    if flag1==1
                        break
                    end
                end
                Wrf_ben(:,nn-3)=F(:,ind_1{1,1}(z1,1));
                Wrf_ben(:,nn-2)=F(:,ind_1{2,1}(z2,1));
                Wrf_ben(:,nn-1)=F(:,ind_1{3,1}(z3,1));
                Wrf_ben(:,nn)=F(:,ind_1{4,1}(z4,1));
            end
            if ind_shu(ii,1)==3  %%%%�����������û����
                [~,nn]=size(Hh); %%���ʱ���������û���
                rate_1=zeros(N_cl^3,1);
                for iii=1:N_cl
                    Wrf_dd(:,nn-2)=F(:,ind_1{1,1}(iii,1));
                    for zzz=1:N_cl
                        Wrf_dd(:,nn-1)=F(:,ind_1{2,1}(zzz,1));
                        for xxx=1:N_cl
                            Wrf_dd(:,nn)=F(:,ind_1{3,1}(xxx,1));
                            Hx=Wrf_dd'*Hh;
                            Wbb_dd=Hx/(Hx'*Hx+eye(nn));
                            HHH=Wrf_dd*Wbb_dd;
                            power_dd=zeros(nn,1);
                            rao_dd=zeros(nn,1);
                            zao_dd=zeros(nn,1);
                            for jjj=1:nn
                                power_dd(jjj,1)=(abs(HHH(:,jjj)'*Hh(:,jjj)))^2;
                                for kkk = 1 : nn
                                    if jjj == kkk
                                        continue;
                                    else
                                        rao_dd(jjj,1)= rao_dd(jjj,1) + (abs(HHH(:,jjj)'*Hh(:,kkk)))^2;
                                    end
                                end
                                zao_dd(jjj,1)=(norm(HHH(:,jjj),2))^2;
                                tt=xxx+(zzz-1)*N_cl+(iii-1)*N_cl^2;
                                rate_1(tt,1)=rate_1(tt,1)+log2(1+power_dd(jjj,1)/(rao_dd(jjj,1)+zao_dd(jjj,1)/SNR(Loop)));
                            end
                        end
                    end
                end
                [~,mm]=max(rate_1);
                flag1=0;
                for iii=1:N_cl
                    for zzz = 1 : N_cl
                        for xxx=1:N_cl
                            if mm==xxx+(zzz-1)*N_cl+(iii-1)*N_cl^2
                                z1=iii;
                                z2=zzz;
                                z3=xxx;
                                flag1=1;
                                break
                            end
                        end
                        if flag1==1
                            break
                        end
                    end
                    if flag1==1
                        break
                    end
                end
                Wrf_ben(:,nn-2)=F(:,ind_1{1,1}(z1,1));
                Wrf_ben(:,nn-1)=F(:,ind_1{2,1}(z2,1));
                Wrf_ben(:,nn)=F(:,ind_1{3,1}(z3,1));
            end
            if ind_shu(ii,1)==2  %%%%�����������û����
                [~,nn]=size(Hh);%%���ʱ���������û���
                rate_1=zeros(N_cl^2,1);
                for iii=1:N_cl
                    Wrf_dd(:,nn-1)=F(:,ind_1{1,1}(iii,1));
                    for zzz=1:N_cl
                        Wrf_dd(:,nn)=F(:,ind_1{2,1}(zzz,1));
                        Hx=Wrf_dd'*Hh;%%�ܷ�֤�û��Ƕ�Ӧ�ġ�
                        Wbb_dd=Hx/(Hx'*Hx+eye(nn));
                        HHH=Wrf_dd*Wbb_dd;
                        power_dd=zeros(nn,1);
                        rao_dd=zeros(nn,1);
                        zao_dd=zeros(nn,1);
                        for jjj=1:nn
                            power_dd(jjj,1)=(abs(HHH(:,jjj)'*Hh(:,jjj)))^2;
                            for kkk = 1 : nn
                                if jjj == kkk
                                    continue;
                                else
                                    rao_dd(jjj,1)= rao_dd(jjj,1) + (abs(HHH(:,jjj)'*Hh(:,kkk)))^2;
                                end
                            end
                            zao_dd(jjj,1)=(norm(HHH(:,jjj),2))^2;
                            tt=zzz+(iii-1)*N_cl;
                            rate_1(tt,1)=rate_1(tt,1)+log2(1+power_dd(jjj,1)/(rao_dd(jjj,1)+zao_dd(jjj,1)/SNR(Loop)));
                        end
                    end
                end
                [~,mm]=max(rate_1);
                flag1=0;
                for iii=1:N_cl
                    for zzz = 1 : N_cl
                        if mm==zzz+(iii-1)*N_cl
                            z1=iii;
                            z2=zzz;
                            flag1=1;
                            break
                        end
                    end
                    if flag1==1
                        break
                    end
                end
                Wrf_ben(:,nn-1)=F(:,ind_1{1,1}(z1,1));
                Wrf_ben(:,nn)=F(:,ind_1{2,1}(z2,1));
            end
            if ind_shu(ii,1)==1 %%����ֻ��һ���û����
                [~,nn]=size(Hh);%%���ʱ���������û���
                rate_1=zeros(N_cl,1);
                for iii=1:N_cl
                    Wrf_dd(:,nn)=F(:,ind_1{1,1}(iii,1));
                    Hx=Wrf_dd'*Hh;
                    Wbb_dd=Hx/(Hx'*Hx+eye(nn));
                    HHH=Wrf_dd*Wbb_dd;
                    power_dd=zeros(nn,1);
                    rao_dd=zeros(nn,1);
                    zao_dd=zeros(nn,1);
                    for jjj=1:nn
                        power_dd(jjj,1)=(abs(HHH(:,jjj)'*Hh(:,jjj)))^2;
                        for kkk = 1 : nn
                            if jjj == kkk
                                continue;
                            else
                                rao_dd(jjj,1)= rao_dd(jjj,1) + (abs(HHH(:,jjj)'*Hh(:,kkk)))^2;
                            end
                        end
                        zao_dd(jjj,1)=(norm(HHH(:,jjj),2))^2;
                        rate_1(iii,1)=rate_1(iii,1)+log2(1+power_dd(jjj,1)/(rao_dd(jjj,1)+zao_dd(jjj,1)/SNR(Loop)));
                    end
                end
                [~,mm]=max(rate_1);
                Wrf_ben(:,nn)=F(:,ind_1{1,1}(mm,1));
            end
        end
        %%������㷨���ܼ���
        Hx=Wrf_ben'*Hh;
        Wbb_ben=Hx/(Hx'*Hx+eye(K));
        HHH=Wrf_ben*Wbb_ben;
        rao_ben = zeros(K, 1);
        power_ben = zeros(K, 1);
        zao_ben = zeros(K, 1);
        for ii=1:K
            power_ben(ii,1)=(abs(HHH(:,ii)'*Hh(:,ii)))^2; %%��Ϊ�û�˳��ı䣬��Ӧ�ŵ�����Ӧ����
            for kk = 1 : K
                if ii == kk
                    continue;
                else
                    rao_ben(ii,1)= rao_ben(ii,1) + (abs(HHH(:,ii)'*Hh(:,kk)))^2;
                end
            end
            zao_ben(ii,1)=(norm(HHH(:,ii),2))^2;
            rate_group(Loop, 1)=rate_group(Loop, 1)+log2(1+power_ben(ii,1)/(rao_ben(ii,1)+zao_ben(ii,1)/SNR(Loop)));
        end
        %%% ZF �㷨
        W_zf = ((H'*H)\H')';
        rao_zf = zeros(K, 1);
        power_zf = zeros(K, 1);
        zao_zf = zeros(K, 1);
        for ii=1:K
            power_zf(ii,1)=(abs(W_zf(:,ii)'*H(:,ii)))^2;
            for kk = 1 : K
                if ii == kk
                    continue;
                else
                    rao_zf(ii,1)= rao_zf(ii,1) + (abs(W_zf(:,ii)'*H(:,kk)))^2;
                end
            end
            zao_zf(ii,1)=(norm(W_zf(:,ii),2))^2;
            rate_zf(Loop, 1)=rate_zf(Loop, 1)+log2(1+power_zf(ii,1)/(rao_zf(ii,1)+zao_zf(ii,1)/SNR(Loop)));
        end
        %����㷨��ʹ�û�Ϸ��ƽ�zf�㷨
        Wrf_zf=zeros(Nr,K);
        for kk=1:K
            for ii=1:col
                mm(ii)=abs(W_zf(:,kk)'*F(:,ii));
            end
            [~,po]=max(mm);
            Wrf_zf(:,kk)=F(:,po);
        end
        Hx=Wrf_zf'*H;
        Wbb_zf=Hx/(Hx'*Hx+eye(K));
        HH_zf=Wrf_zf*Wbb_zf;
        rao_hunhe = zeros(K, 1);
        power_hunhe = zeros(K, 1);
        zao_hunhe = zeros(K, 1);
        for ii=1:K
            power_hunhe(ii,1)=(abs(HH_zf(:,ii)'*H(:,ii)))^2;
            for kk = 1 : K
                if ii == kk
                    continue;
                else
                    rao_hunhe(ii,1)= rao_hunhe(ii,1) + (abs(HH_zf(:,ii)'*H(:,kk)))^2;
                end
            end
            zao_hunhe(ii,1)=(norm(HH_zf(:,ii),2))^2;
            rate_hunhe(Loop, 1)=rate_hunhe(Loop, 1)+log2(1+power_hunhe(ii,1)/(rao_hunhe(ii,1)+zao_hunhe(ii,1)/SNR(Loop)));
        end
        %̰����������㷨
        ind_gre=zeros(K,N_cl);
        num_gre=zeros(Nr,1);
        for jj=1:K  %Ԥѡ�뱾����
            for kk=1:col
                num_gre(kk,1)=abs(H1(:,(jj-1)*N_cl+n1)'*F(:,kk));%�ҳ�����ÿ���û���Ԥѡ�뱾
            end
            for n1=1:N_cl
                [~,ind_gre(jj,n1)]=max(num_gre);
                num_gre(ind_gre(jj,n1),1)=0;
            end
        end
        rate_2=zeros(N_cl,1);
        Wrf_gre=zeros(Nr,K);
        for jj=1:K
            Wrf_gg=zeros(Nr,jj);
            if jj>1
                Wrf_gg(:,1:jj-1)= Wrf_gre(:,1:jj-1);
            end
            for iii=1:N_cl
                Wrf_gg(:,jj)=F(:,ind_gre(jj,iii));
                Hx=Wrf_gg'*H(:,1:jj);
                Wbb_gg=Hx/(Hx'*Hx+eye(jj));
                HH_gg=Wrf_gg*Wbb_gg;
                power_gg=zeros(jj,1);
                rao_gg=zeros(jj,1);
                zao_gg=zeros(jj,1);
                if jj==1
                    power_gg(jj,1)=(abs(HH_gg(:,jj)'*H(:,jj)))^2;
                    zao_gg(jj,1)=(norm(HH_gg(:,jj),2))^2;
                    rao_gg(jj,1)=0;
                    rate_2(iii,1)=rate_2(iii,1)+log2(1+power_gg(jj,1)/(rao_gg(jj,1)+zao_gg(jj,1)/SNR(Loop)));
                else
                    for jjj=1:jj
                        power_gg(jjj,1)=(abs(HH_gg(:,jjj)'*H(:,jjj)))^2;
                        for kkk = 1 : jj
                            if jjj == kkk
                                continue;
                            else
                                rao_gg(jjj,1)= rao_gg(jjj,1) + (abs(HH_gg(:,jjj)'*H(:,kkk)))^2;
                            end
                        end
                        zao_gg(jjj,1)=(norm(HH_gg(:,jjj),2))^2;
                        rate_2(iii,1)=rate_2(iii,1)+log2(1+power_gg(jjj,1)/(rao_gg(jjj,1)+zao_gg(jjj,1)/SNR(Loop)));
                    end
                end
            end
            [~,mm]=max(rate_2);
            Wrf_gre(:,jj)=F(:,ind_gre(jj,mm));
        end
        power_gre=zeros(K,1);
        rao_gre=zeros(K,1);
        zao_gre=zeros(K,1);
        Hx=Wrf_gre'*H;
        Wbb_gre=Hx/(Hx'*Hx+eye(K));
        HH_gre=Wrf_gre*Wbb_gre;
        for jjj=1:K
            power_gre(jjj,1)=(abs(HH_gre(:,jjj)'*H(:,jjj)))^2;
            for kkk = 1 : K
                if jjj == kkk
                else
                    rao_gre(jjj,1)= rao_gre(jjj,1) + (abs(HH_gre(:,jjj)'*H(:,kkk)))^2;
                end
            end
            zao_gre(jjj,1)=(norm(HH_gre(:,jjj),2))^2;
            rate_gre(Loop, 1)=rate_gre(Loop, 1)+log2(1+power_gre(jjj,1)/(rao_gre(jjj,1)+zao_gre(jjj,1)/SNR(Loop)));
        end
        %��ͨ�뱾�㷨
        Wrf_ma=zeros(Nr,K);
        for kk=1:K
            for ii=1:col
                mm(ii)=abs(H(:,kk)'*F(:,ii));
            end
            [~,po]=max(mm);
            Wrf_ma(:,kk)=F(:,po);
        end
        Hx=Wrf_ma'*H;
        Wbb_ma=Hx/(Hx'*Hx+eye(K));
        H_ma=Wrf_ma*Wbb_ma;
        power_ma=zeros(K,1);
        rao_ma=zeros(K,1);
        zao_ma=zeros(K,1);
        for jjj=1:K
            power_ma(jjj,1)=(abs(H_ma(:,jjj)'*H(:,jjj)))^2;
            for kkk = 1 : K
                if jjj == kkk
                    continue;
                else
                    rao_ma(jjj,1)= rao_ma(jjj,1) + (abs(H_ma(:,jjj)'*H(:,kkk)))^2;
                end
            end
            zao_ma(jjj,1)=(norm(H_ma(:,jjj),2))^2;
            rate_ma(Loop, 1)=rate_ma(Loop, 1)+log2(1+power_ma(jjj,1)/(rao_ma(jjj,1)+zao_ma(jjj,1)/SNR(Loop)));
        end
        disp([Loop, Loop_1])
    end
    
end           
rate_group = rate_group / N;
rate_zf = rate_zf / N;
rate_gre=rate_gre/N;
rate_ma=rate_ma/N;
rate_hunhe=rate_hunhe/N;
plot(SNR_db,rate_zf,'-ko');
hold on
plot(SNR_db ,rate_group,'-k*');
% plot(SNR_db ,rate_hunhe,'-k<');
plot(SNR_db ,rate_gre,'--bs');  
plot(SNR_db ,rate_ma,'--bv');  
grid on
xlabel('SNR/dB');
ylabel('sum rate[bit/s/Hz]');
legend('Full digital','Proposed algorithm','Greedy algorithm[10]','Beam control[9]');










