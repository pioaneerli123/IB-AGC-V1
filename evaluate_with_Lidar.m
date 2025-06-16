clear
clc
% Load reference AGC data
load('Lidar_reference.mat')
% 2013, 2017, 2018
AGBall(:,:,1)=AGCmeanSLB;
AGBall(:,:,2)=AGCmeanNEON;
AGBall(:,:,3)=AGC25kmsd;
AGBmean=nanmean(AGBall,3);

VOD_AGB_all=ncread('INRAE_Bordeaux_annual_AGC_from_SMOS_IC_LVOD_V1.nc','AGC');
VOD_AGB_all=permute(VOD_AGB_all,[2,1,3]);

VOD_AGB_std=ncread('INRAE_Bordeaux_annual_AGC_from_SMOS_IC_LVOD_V1.nc','AGC_uncertainly');
VOD_AGB_std=permute(VOD_AGB_std,[2,1,3]);

vod=nanmean(VOD_AGB_all,3);
% According to the law of error propagation
vod_std_combined = sqrt(nanmean(VOD_AGB_std.^2, 3)); % Multi-year error synthesis

% Read CCI data
CCI(:,:,1)=ncread('Biomass_CCI_V501_2010_easegrid2_025.nc','agb')'.*0.5;
CCI(:,:,2)=ncread('Biomass_CCI_V501_2015_easegrid2_025.nc','agb')'.*0.5;
CCI(:,:,3)=ncread('Biomass_CCI_V501_2016_easegrid2_025.nc','agb')'.*0.5;
CCI(:,:,4)=ncread('Biomass_CCI_V501_2017_easegrid2_025.nc','agb')'.*0.5;
CCI(:,:,5)=ncread('Biomass_CCI_V501_2018_easegrid2_025.nc','agb')'.*0.5;
CCI(:,:,6)=ncread('Biomass_CCI_V501_2019_easegrid2_025.nc','agb')'.*0.5;
CCI(:,:,7)=ncread('Biomass_CCI_V501_2020_easegrid2_025.nc','agb')'.*0.5;
CCImean=nanmean(CCI,3);

% Read Xu data
load('Xu_AGB_2002_2019.mat');
XumeanAGB=nanmean(Xu_AGB(:,:,11:20),3);

mask = ~isnan(AGBmean) & ~isnan(vod) & ~isnan(vod_std_combined)  & ~isnan(CCImean) & ~isnan(XumeanAGB);
mask((vod-AGBmean)<-70)=0; % Remove large negative differences
save('Lidar_based_sites.mat','mask');

x = AGBmean(mask);
y = vod(mask);
yerr = vod_std_combined(mask);
ycci=CCImean(mask);
yxu=XumeanAGB(mask);

% --- Plot: IB L-VOD AGC ---
figure
set(gcf,'Position',[100 100 400 270]);
color_I=[0 0.4470 0.7410];
hold on
% Step 1: Plot error bars
errorbar(x, y, yerr, 'LineStyle', 'none', 'Color', [0 0.4470 0.7410 0.9], 'LineWidth', 0.6,'CapSize', 3);
xlim([-0.5 200])
ylim([-0.5 200])
% Step 2: Plot scatter points
scatter(x, y, 20, 'filled', 'MarkerFaceColor', color_I, 'MarkerFaceAlpha', 0.7);
mdl1 = fitlm(x, y);
p_value_I = mdl1.Coefficients.pValue(2);
R2_I = mdl1.Rsquared.Ordinary; 
intercept_I = mdl1.Coefficients.Estimate(1); 
slope_I     = mdl1.Coefficients.Estimate(2); 
RMSE_I = sqrt(mean((y - x).^2));
RRMSE_I= (RMSE_I /(nanmean(x))) * 100;
plot([0 200], [0 200], 'k--', 'LineWidth', 0.5);

box on
xticks(0:20:200)
yticks(0:20:200)
grid on
xticklabels({'0', '', '40', '', '80', '', '120', '', '160', '', '200'})
yticklabels({'0', '', '40', '', '80', '', '120', '', '160', '', '200'})
r = corr(x, y, 'rows', 'complete');
disp(['Correlation = ', num2str(r)])
ax = gca;
ax.XAxis.FontSize = 9;
ax.YAxis.FontSize = 9;
xtickangle(0); 
text(10, 188, sprintf('R^2 = %.2f, P = %.2f', R2_I,p_value_I), 'FontSize', 9, 'Color', color_I);
text(10, 172, sprintf('Bias = %.2f MgC ha^{-1}', mybias(y,x)), 'FontSize', 9, 'Color', color_I);
text(10, 152, sprintf('RRMSE = %.2f%%', RRMSE_I), 'FontSize', 9, 'Color', color_I);
text(-30, 210, '(a)', 'FontSize', 11, 'FontWeight', 'bold');
xlabel('Airborne LiDAR based AGC (MgC ha^{-1})', 'FontSize',9)
ylabel('IB L-VOD derived AGC (MgC ha^{-1})', 'FontSize', 9)

% --- Plot: CCI AGC ---
figure
set(gcf,'Position',[100 100 400 270]);
color_II=[0.8500 0.3250 0.0980];
hold on
xlim([-0.5 200])
ylim([-0.5 200])
scatter(x, ycci, 20, 'filled', 'MarkerFaceColor',color_II, 'MarkerFaceAlpha', 0.7);
mdl2 = fitlm(x, ycci);
p_value_II = mdl2.Coefficients.pValue(2);
R2_II = mdl2.Rsquared.Ordinary; 
intercept_II = mdl2.Coefficients.Estimate(1); 
slope_II     = mdl2.Coefficients.Estimate(2); 
RMSE_II = sqrt(mean((ycci - x).^2));
RRMSE_II= (RMSE_II /(nanmean(x))) * 100;
plot([0 200], [0 200], 'k--', 'LineWidth', 0.5);

box on
xticks(0:20:200)
yticks(0:20:200)
grid on
xticklabels({'0', '', '40', '', '80', '', '120', '', '160', '', '200'})
yticklabels({'0', '', '40', '', '80', '', '120', '', '160', '', '200'})
r = corr(x, ycci, 'rows', 'complete');
disp(['Correlation = ', num2str(r)])
ax = gca;
ax.XAxis.FontSize = 9;
ax.YAxis.FontSize = 9;
xtickangle(0); 
text(10, 188, sprintf('R^2 = %.2f, P = %.2f', R2_II,p_value_II), 'FontSize', 9, 'Color', color_II);
text(10, 172, sprintf('Bias = %.2f MgC ha^{-1}', mybias(ycci,x)), 'FontSize', 9, 'Color', color_II);
text(10, 152, sprintf('RRMSE = %.2f%%', RRMSE_II), 'FontSize', 9, 'Color', color_II);
text(-30, 210, '(b)', 'FontSize', 11, 'FontWeight', 'bold');
xlabel('Airborne LiDAR based AGC (MgC ha^{-1})', 'FontSize', 9)
ylabel('CCI AGC (MgC ha^{-1})', 'FontSize', 9)

% --- Plot: Xu AGC ---
figure
set(gcf,'Position',[100 100 400 270]);
color_III=[0.9290 0.6940 0.1250];
hold on
xlim([-0.5 200])
ylim([-0.5 200])
scatter(x, yxu, 20, 'filled', 'MarkerFaceColor',color_III, 'MarkerFaceAlpha', 0.7);
mdl3 = fitlm(x, yxu);
p_value_III = mdl3.Coefficients.pValue(2);
R2_III = mdl3.Rsquared.Ordinary; 
intercept_III = mdl3.Coefficients.Estimate(1); 
slope_III     = mdl3.Coefficients.Estimate(2); 
RMSE_III = sqrt(mean((yxu - x).^2));
RRMSE_III= (RMSE_III /(nanmean(x))) * 100;
plot([0 200], [0 200], 'k--', 'LineWidth', 0.5);

box on
xticks(0:20:200)
yticks(0:20:200)
grid on
xticklabels({'0', '', '40', '', '80', '', '120', '', '160', '', '200'})
yticklabels({'0', '', '40', '', '80', '', '120', '', '160', '', '200'})
r = corr(x, yxu, 'rows', 'complete');
disp(['Correlation = ', num2str(r)])
ax = gca;
ax.XAxis.FontSize = 9;
ax.YAxis.FontSize = 9;
xtickangle(0); 
text(10, 188, sprintf('R^2 = %.2f, P = %.2f', R2_III,p_value_III), 'FontSize', 9, 'Color', color_III);
text(10, 172, sprintf('Bias = %.2f MgC ha^{-1}', mybias(yxu,x)), 'FontSize', 9, 'Color', color_III);
text(10, 152, sprintf('RRMSE = %.2f%%', RRMSE_III), 'FontSize', 9, 'Color', color_III);
text(-30, 210, '(c)', 'FontSize', 11, 'FontWeight', 'bold');
xlabel('Airborne LiDAR based AGC (MgC ha^{-1})', 'FontSize', 9)
ylabel('Xu AGC (MgC ha^{-1})', 'FontSize', 9)
