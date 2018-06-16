a='keble_a.jpg';
b='keble_b.jpg';
c='keble_c.jpg';
Ia=imread(a);
Ib=imread(b);
Ic=imread(c);
[x1 y1 v1]=harris(Ia)
[x2 y2 v2]=harris(Ib)
[x3 y3 v3]=harris(Ic)
p1=find(v1>0.001)
x1=x1(p1);
y1=y1(p1);
p2=find(v2>0.001);
x2=x2(p2);
y2=y2(p2);
p3=find(v3>0.001);
x3=x3(p3);
y3=y3(p3);
r1=mindis(x1,y1)
r2=mindis(x2,y2)
r3=mindis(x3,y3)
%display filtered corner interest points
imagesc(Ia);
colormap(gray);
hold on;
plot(x1,y1,'r.');    
figure(3),
imagesc(Ic);
colormap(gray);
hold on;
plot(x3,y3,'r.');   
%x12sq=dist2(x1,x2)
%y12sq=dist2(y1,y2)
%circles1=[x1 y1 v1]
%circles2=[x2 y2 v2]
%circles3=[x3 y3 r3]
circles1=[x1 y1 r1]
circles2=[x2 y2 r2]
circles3=[x3 y3 r3]
sift_arr1 = find_sift(Ia, circles1, 1.5)
sift_arr2 = find_sift(Ib, circles2, 1.5)
sift_arr3 = find_sift(Ic, circles3, 1.5)
dis12=dist2(sift_arr1,sift_arr2)
dis32=dist2(sift_arr3,sift_arr2)


%thresholding 

sort_dis12=sort(dis12)
sort_dis32=sort(dis32)
thres12=sum(sort_dis12(1,:).^2)/sum(sort_dis12(2,:).^2)
thres32=sum(sort_dis32(1,:).^2)/sum(sort_dis32(2,:).^2)
[m1,m2,~]=find(dis12<thres12/5)
[m32,m23,~]=find(dis32<thres32/5)

%idx=dis12<thres

%[M,N]=size(dis12)
%[im1idx im2idx]=find(idx==1)     %%too many indices

%im1mt=[x1';y1']
%im1mt(:,im1idx)

%choose smallest points
%{
[smallestNElements,smallestNIdx] = getNElements(dis12, 900)
siz=size(dis12)
[m1,m2] = ind2sub(siz,smallestNIdx)
%}

im1_pts=[x1(m1)';y1(m1)']
im2_pts=[x2(m2)';y2(m2)']



im23_pts=[x2(m23)';y2(m23)']
im32_pts=[x3(m32)';y3(m32)']
figure(1) ;clf; imagesc(Ia); hold on;
title('tentative correspondence 12')
plot(im1_pts(1,:),im1_pts(2,:),'+g')
line([im1_pts(1,:);im2_pts(1,:)],[im1_pts(2,:);im2_pts(2,:)],'color','y')

figure(2) ;clf; imagesc(Ib); hold on;
title('tentative correspondence 23')
plot(im23_pts(1,:),im23_pts(2,:),'+g')
line([im23_pts(1,:);im32_pts(1,:)],[im23_pts(2,:);im32_pts(2,:)],'color','y')

%H=computeH(im1_pts,im2_pts)
[op_H12,op_inliers12]=RANSAC(im1_pts,im2_pts,m1,1000,10)
[op_H32,op_inliers32]=RANSAC(im32_pts,im23_pts,m32,1000,10)

figure(7),
title('inliers between im1 and im2')
subplot(1,2,1), imshow(Ia);hold on
plot(im1_pts(1,op_inliers12),im1_pts(2,op_inliers12),'r.');
title('inliers in im1')
subplot(1,2,2), imshow(Ib);hold on
plot(im2_pts(1,op_inliers12),im2_pts(2,op_inliers12),'r.');
title('inliers in im2')
figure(8),

subplot(1,2,1), imshow(Ib);hold on
plot(im23_pts(1,op_inliers32),im23_pts(2,op_inliers32),'r.');
title('inliers in im2')
subplot(1,2,2), imshow(Ic);hold on
plot(im32_pts(1,op_inliers32),im32_pts(2,op_inliers32),'r.');
title('inliers in im3')

H12=computeH(im1_pts(:,op_inliers12),im2_pts(:,op_inliers12))
H32=computeH(im32_pts(:,op_inliers32),im23_pts(:,op_inliers32))
bbox=[-400 1200 -200 700]
Im2w=vgg_warp_H(double(Ib),eye(3),'linear',bbox);
Im1w=vgg_warp_H(double(Ia),H12,'linear',bbox);
Im3w=vgg_warp_H(double(Ic),H32,'linear',bbox);
imgw=max(Im1w,Im2w)
imgw=max(imgw,Im3w)
figure(9),imshow(uint8(imgw));