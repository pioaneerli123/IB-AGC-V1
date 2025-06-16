clear
clc

load('vod_removed_yearly_20102023.mat');
% Notably, the year of L-VOD used for the calibration has a very little 
% impact on the final result as evidenced in Fan et al. (2023)
% Here, we used the annual L-VOD from 2011 for calibration.

vod_ib=vod_removed(:,:,2);
vod_ib(vod_ib<0)=nan;
vod_ib(vod_ib>2)=nan;
lon2=load('lon.mat');
lon=lon2.lon;
lat2=load('lat.mat');
lat=lat2.lat;
[lon1,lat1]=meshgrid(lon,lat);
vod_ib(lat1>30)=nan;

data_biomass25=importdata('GlobalBiomass25.mat');
bio_big=flipud(data_biomass25.Biomass_25);
%convert to AGC
bio_big=bio_big./2;


data_biomass25Gagb=importdata('GlbalBiomass25-global-biomss.mat');
bio_big_Gagb=flipud(data_biomass25Gagb.Biomass_25);
Gagb_qf=importdata('GlbalBiomass25Error-global-biomass.mat');
Gagb_qf=flipud(Gagb_qf);
bio_big_Gagb=bio_big_Gagb./2;


% avitabile
[data_biomass25CCI,geo]=geotiffread('D:\My_research\data\Biomass_and_inivod\tropic AGB\Avitabile2016\Avitabile_AGB_EASE25.tiff');
bio_big_CCI=flipud(data_biomass25CCI);
bio_big_CCI=bio_big_CCI./2;
bio_big_CCI(bio_big_CCI==0)=nan;


% baccini
[data_biomass25bacciam,geo]=geotiffread('D:\My_research\data\Biomass_and_inivod\tropic AGB\Baccini2012\baccini_af_am_AGB_EASE25.tiff');
bio_big_bacciam=flipud(data_biomass25bacciam);
[data_biomass25bacciaf,geo]=geotiffread('D:\My_research\data\Biomass_and_inivod\tropic AGB\Baccini2012\baccini_af_as_AGB_EASE25.tiff');
bio_big_bacciaf=flipud(data_biomass25bacciaf);
bio_big_bacci=bio_big_bacciaf;
bio_big_bacci(bio_big_bacci==0 & lon1<-20)=bio_big_bacciam(bio_big_bacci==0 & lon1<-20);
bio_big_bacci=bio_big_bacci./2;
bio_big_bacci(bio_big_bacci==0)=nan;

% read Spawn biomass data
load('AGB_25km_ease2.mat')
Spawnagbmap=AGB;
Spawnagbmap(Spawnagbmap<=0)=nan;

% keep same pixels for each biomass and VOD datasets
maskAGBVOD3=nan(584,1388,2);
maskAGBVOD3(:,:,1)=vod_ib;
maskAGBVOD3(:,:,2)=Spawnagbmap;
vodAGBmaskresult3=intermaskVODAGB(maskAGBVOD3);
vod_ibbaSPA=vodAGBmaskresult3(:,:,1);
bio_big_baSPA=vodAGBmaskresult3(:,:,2);


gediAGC=ncread('Biomass_GEDI_2020_easegrid2_025.nc','agb')';
gediAGC=gediAGC./2;
gediAGC(gediAGC<0)=nan;
maskAGBVOD4=nan(584,1388,2);
maskAGBVOD4(:,:,1)=vod_ib;
maskAGBVOD4(:,:,2)=gediAGC;
vodAGBmaskresult4=intermaskVODAGB(maskAGBVOD4);
vod_ibGEDI=vodAGBmaskresult4(:,:,1);
bio_big_GEDI=vodAGBmaskresult4(:,:,2);

maskAGBVOD=nan(584,1388,2);
maskAGBVOD(:,:,1)=vod_ib;
maskAGBVOD(:,:,2)=bio_big;
vodAGBmaskresult=intermaskVODAGB(maskAGBVOD);
vod_ibsaatchi=vodAGBmaskresult(:,:,1);
bio_big=vodAGBmaskresult(:,:,2);


maskAGBVOD1=nan(584,1388,2);
maskAGBVOD1(:,:,1)=vod_ib;
maskAGBVOD1(:,:,2)=bio_big_Gagb;
vodAGBmaskresult1=intermaskVODAGB(maskAGBVOD1);
vod_ibGlobbiomass=vodAGBmaskresult1(:,:,1);
bio_big_Gagb=vodAGBmaskresult1(:,:,2);


maskAGBVOD2=nan(584,1388,2);
maskAGBVOD2(:,:,1)=vod_ib;
maskAGBVOD2(:,:,2)=bio_big_CCI;
vodAGBmaskresult2=intermaskVODAGB(maskAGBVOD2);
vod_ibCCI=vodAGBmaskresult2(:,:,1);
bio_big_CCI=vodAGBmaskresult2(:,:,2);



maskAGBVOD2=nan(584,1388,2);
maskAGBVOD2(:,:,1)=vod_ib;
maskAGBVOD2(:,:,2)=bio_big_bacci;
vodAGBmaskresult3=intermaskVODAGB(maskAGBVOD2);
vod_ibbacci=vodAGBmaskresult3(:,:,1);
bio_big_bacci=vodAGBmaskresult3(:,:,2);


% try build the relationship between VOD and benchmap AGB

Step_size_x=(0:0.025:1.5);
Step_size_y=(0:5:200);
Step_size_x1=(0:0.025:1.475);
Step_size_y1=(0:5:195);
color_map=load('D:\My_research\results\vod_compare_colormap.mat');   % load the colormap
mycmap=color_map.mycmap;


a = reshape(vod_ibsaatchi,584*1388,1);
b=reshape(bio_big,584*1388,1);

b=b(~isnan(a));
a=a(~isnan(a));
[a,indexvod]=sort(a);
b=b(indexvod);
w=1;
for i=1:250:length(a);
    row1=i;
    row2=i+249;
    if row2>length(a)
       row2=length(a);
    end
    vod_average(w)=mean(a(row1:row2));
    biomass_average(w)=mean(b(row1:row2));
    w=w+1;
    clearvars num num1 biomass_rank vod_rank
end

mymodelfun = @(beta,x) beta(1).*(atan(beta(2).*(x-beta(3)))-atan(-beta(2)*beta(3)))./(atan(10^10)-atan(-beta(2)*beta(3)))+beta(4);
beta0=[183.64,2.82,0.72,-1.11];
R_total=corr(a,b);

opts = statset('Display','iter','TolFun',1e-10);
mdl = fitnlm(vod_average,biomass_average,mymodelfun,beta0,'Options',opts)
beta1 = mdl.Coefficients.Estimate;

save('beta1_coeeficient_saatchitropics','beta1','-v7.3')
