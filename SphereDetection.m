function D=SphereDetection(FileName, Resolution, counter, fiberD)
I1=imread(FileName);
if ndims(I1)==3; I1=rgb2gray(I1(:,:,1:3)); end
% [rows, columns, numberOfColorChannels] = size(I1);
I1=I1(1:end-80,:);
I1=imadjust(I1);
if Resolution==2/213
    level=120;
elseif Resolution==5/268
    level=145;
else
    level=130;
end
seg_I=I1>level;
bw2=seg_I;
SE = strel('square',2);
N=1; %number of dilation
if fiberD>.3 && Resolution<0.02  % if figure is full of fibers then 
    N=30;                        % we have to make several times of 
end                              % dilation to account for fibers!!
if Resolution==2/213
    N=3;
end
for i=1:N
    bw2 = imerode(bw2,SE);
end
bw2=imfill(bw2,'holes');
stats = regionprops('table',bw2,'Area','Centroid','EquivDiameter',...
    'MajorAxisLength','MinorAxisLength');
cent=stats.Centroid;
area=stats.Area;
diam=stats.EquivDiameter;
minAx=stats.MinorAxisLength;
majAx=stats.MajorAxisLength;
e=majAx./minAx;
flag=[];
subplot(1,2,1)
imshow(bw2,[])
hold on
dmax=30000;
if Resolution < 0.02
    dmax=100000;
end
dmin=100;
for i=1:size(stats,1)
    if area(i)<dmax && area(i)>dmin && e(i)<4
        x=ceil(cent(i,1));
        y=ceil(cent(i,2));
        r=ceil(diam(i)/2);
        theta = 0 : (2 * pi / 10000) : (2 * pi);
        pline_x = r * cos(theta) + x;
        pline_y = r * sin(theta) + y;
        plot(pline_x, pline_y, 'r-', 'LineWidth', 2); hold on;
        text(x,y,num2str(r*Resolution),'Color','blue','FontSize',7)
    else
        flag=[flag i];
    end
end
text(2,8,[num2str(mean(mean(I1))) '-' num2str(fiberD)],'Color','blue','FontSize',14)
stats(flag',:)=[];
D=(stats.EquivDiameter)'*Resolution;
subplot(1,2,2)
imshow(I1,[])
export_fig(sprintf(['figure' num2str(counter) '.png']))
clf
subplot(1,2,1)
clf
