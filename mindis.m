function dis=mindis(x1,y1)
N=length(x1);
dis=zeros(N,1);
for i=1:N
    temp=zeros(1,N);
    for j=1:N
    if(i~=j)
    temp(j)=sqrt((x1(i)-x1(j))^2+(y1(i)-y1(j))^2);
    else
        temp(j)=inf;
    end
    end
dis(i)=min(temp);
end