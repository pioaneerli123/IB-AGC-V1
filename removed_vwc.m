clear
clc
lon2=load('lon.mat');
lon=lon2.lon;
lat2=load('lat.mat');
lat=lat2.lat;
[lon1,lat1]=meshgrid(lon,lat);

load('ASC_VOD_SMOS20102023filtering.mat')

load("VIS_year_median2023.mat")
VOD_big=ASC_light_VODSMOSMAP2raw(:,:,1:14);
NDVI_big=NDVI_year(:,:,1:14);
SWC_big=SWC_year(:,:,1:14);
NDWI_big=NDWI_year(:,:,1:14);

% try z-score method
meanVOD=mean(VOD_big,3,'omitnan');
stdVOD=std(VOD_big,0,3,'omitnan');
VOD_z=(VOD_big-repmat(meanVOD,[1,1,14]))./repmat(stdVOD,[1,1,14]);

meanNDWI=mean(NDWI_big,3,'omitnan');
stdNDWI=std(NDWI_big,0,3,'omitnan');
NDWI_z=(NDWI_big-repmat(meanNDWI,[1,1,14]))./repmat(stdNDWI,[1,1,14]);

meanNDVI=mean(NDVI_big,3,'omitnan');
stdNDVI=std(NDVI_big,0,3,'omitnan');
NDVI_z=(NDVI_big-repmat(meanNDVI,[1,1,14]))./repmat(stdNDVI,[1,1,14]);

meanSWC=mean(SWC_big,3,'omitnan');
stdSWC=std(SWC_big,0,3,'omitnan');
SWC_z=(SWC_big-repmat(meanSWC,[1,1,14]))./repmat(stdSWC,[1,1,14]);


load('Yearly_ndvi_ndwi_swc_metrics_medianVODFinalAIC20102023RE07.mat','coffndwiswc','pswcndwi','rSquaredswcndwi');% Eq5. VOD=a*NDWI+b*SWC+c*NDWI*SWC+d
pcoeff=reshape(pswcndwi,1386,582);
Pcoff=nan(584,1388);
Pcoff(2:583,2:1387)=pcoeff';

Inter=reshape(coffndwiswc(:,1),1386,582);
Coeffinter=nan(584,1388);
Coeffinter(2:583,2:1387)=Inter';

ndwivalue=reshape(coffndwiswc(:,2),1386,582);
Coeffndwi=nan(584,1388);
Coeffndwi(2:583,2:1387)=ndwivalue';

swcvalue=reshape(coffndwiswc(:,3),1386,582);
Coeffswc=nan(584,1388);
Coeffswc(2:583,2:1387)=swcvalue';

ndwiswcvalue=reshape(coffndwiswc(:,4),1386,582);
Coeffndwiswc=nan(584,1388);
Coeffndwiswc(2:583,2:1387)=ndwiswcvalue';
interaction=NDWI_z.*SWC_z;

rSquaredswcndwi1=reshape(rSquaredswcndwi,1386,582);
r_swcndwi=nan(584,1388);
r_swcndwi(2:583,2:1387)=rSquaredswcndwi1';



modelVOD=Coeffndwi.*NDWI_z+Coeffswc.*SWC_z+Coeffndwiswc.*interaction;
modelVOD1=Coeffinter+Coeffndwi.*NDWI_z+Coeffswc.*SWC_z+Coeffndwiswc.*interaction;

vod_removed=VOD_z-modelVOD;

vod_removed=vod_removed.*repmat(stdVOD,[1,1,14])+repmat(meanVOD,[1,1,14]);
VOD_z=VOD_z.*repmat(stdVOD,[1,1,14])+repmat(meanVOD,[1,1,14]);

save('vod_removed_yearly_20102023.mat','vod_removed','-v7.3')

