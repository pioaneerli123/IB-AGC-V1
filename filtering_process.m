clc
clear all
% This code is used to filter the daily VOD data.

% Need prepare Input File (.mat format) for each year, and file include daily VOD data, daily RMSE-TB data and daily SF data from ascending and descending orbits
% Name of Input File: 'ASC_daily_****.mat' and 'DESC_daily_****.mat'

% Output file (.mat format) includes filtered ASC-only VOD data ('filtered_VOD_ASC'), DESC-only VOD data('filtered_VOD_DESC') and ASC&DESC VOD data('filtered_VOD_ASC_DESC'), and the number of VOD data('ASC_number','DESC_number' and 'ASC_DESC_number')
% Name of Output File: 'Filtered_8k_5k_****.mat'

for yr=2010:2022
    % load daily VOD, RMSE-TB and SF data from ascending orbit
    % ASC_VOD_daily, ASC_RMSE_daily, ASC_SF_daily: 3-D, 584x1388x365
    load(['ASC_daily_',num2str(yr),'_ICheavy.mat'],'ASC_VOD_daily','ASC_RMSE_daily','ASC_SF_daily')

    % load daily VOD, RMSE-TB and SF data from descending orbit
    % DESC_VOD_daily, DESC_RMSE_daily, DESC_SF_daily: 3-D, 584x1388x365
    load(['DESC_daily_',num2str(yr),'_ICheavy.mat'],'DESC_VOD_daily','DESC_RMSE_daily','DESC_SF_daily')

    % To keep simple, remove data of 29 Feb in leap year
    if yr==2012|yr==2016|yr==2020
    	ASC_VOD_daily(:,:,60)=[];
    	ASC_RMSE_daily(:,:,60)=[];
    	ASC_SF_daily(:,:,60)=[];

    	DESC_VOD_daily(:,:,60)=[];
    	DESC_RMSE_daily(:,:,60)=[];
    	DESC_SF_daily(:,:,60)=[];
    end

    % define the output variables
    filtered_VOD_ASC=nan(584,1388,365);   % filtered ASC-only VOD data
    filtered_VOD_DESC=nan(584,1388,365);   % filtered DESC-only VOD data
    filtered_VOD_ASC_DESC=nan(584,1388,365);   % filtered ASC&DESC-merged data

    ASC_number=nan(584,1388,4);   % The number of the filtered ASC-only VOD data for each trimester
    DESC_number=nan(584,1388,4);   % The number of the filtered DESC-only VOD data for each trimester
    ASC_DESC_number=nan(584,1388,4);   % The number of the filtered ASC&DESC VOD data for each trimester

    season_day=[1 91 182 274 366];
    for p=1:584
    	for q=1:1388
    	    for t=1:4
        		if sum(~isnan(ASC_VOD_daily(p,q,season_day(t):season_day(t+1)-1)),3)>7||sum(~isnan(DESC_VOD_daily(p,q,season_day(t):season_day(t+1)-1)),3)>7
        		    ASC_VOD=reshape(ASC_VOD_daily(p,q,season_day(t):season_day(t+1)-1),[],1);
                    DESC_VOD=reshape(DESC_VOD_daily(p,q,season_day(t):season_day(t+1)-1),[],1);

        		    ASC_RMSE=reshape(ASC_RMSE_daily(p,q,season_day(t):season_day(t+1)-1),[],1);
        		    DESC_RMSE=reshape(DESC_RMSE_daily(p,q,season_day(t):season_day(t+1)-1),[],1);

        		    ASC_SF=reshape(ASC_SF_daily(p,q,season_day(t):season_day(t+1)-1),[],1);
        		    DESC_SF=reshape(DESC_SF_daily(p,q,season_day(t):season_day(t+1)-1),[],1);

                    ASC_SF=uint8(ASC_SF);
                    DESC_SF=uint8(DESC_SF);
                    % Step(i). Filter daily data
                    % 		    ASC_VOD(ASC_RMSE>8|ASC_SF>1)=nan;
                    % 		    DESC_VOD(DESC_RMSE>8|DESC_SF>1)=nan;
                    ASC_VOD(ASC_RMSE>8|bitget(ASC_SF,3,'uint8')==1|bitget(ASC_SF,2,'uint8')==1)=nan;
        		    DESC_VOD(DESC_RMSE>8|bitget(DESC_SF,3,'uint8')==1|bitget(DESC_SF,2,'uint8')==1)=nan;

           		 % Step (ii)
                 % Calculate the averages of VOD in the trimester, and difference in average between ASC and DESC
     		    Diff=nanmean(ASC_VOD)-nanmean(DESC_VOD);

   	         % If difference > 0.05, check the average of RMSE-TB in the trimester
 		    if abs(Diff)<0.05
            else
    			ind=find(~isnan(ASC_VOD));
    			ind1=find(~isnan(DESC_VOD));

                % If RMSE-TB from ASC > 5k -> Remove all the VOD from ASC in this trimester
    			if mean(ASC_RMSE(ind))>5
    			    ASC_VOD(ind)=nan;
    			end

   		     % If RMSE-TB from DESC > 5k -> Remove all the VOD from DESC in this trimester
 			if mean(DESC_RMSE(ind1))>5
                DESC_VOD(ind1)=nan;
            end
            end

   		 % Merge the filtered ASC VOD data and DESC VOD data
         combined=nan(1,length(ASC_VOD));
         combined_rmse=nan(1,length(ASC_VOD));

         for cc=1:length(ASC_VOD)
             % There are ASC and DESC data on the same day -> keep the one with lower RMSE-TB
             if ~isnan(ASC_VOD(cc))&&~isnan(DESC_VOD(cc))
                 if ASC_RMSE(cc)<DESC_RMSE(cc)
                     combined(cc)=ASC_VOD(cc);
                     combined_rmse(cc)=ASC_RMSE(cc);
                 else
                     combined(cc)=DESC_VOD(cc);
                     combined_rmse(cc)=DESC_RMSE(cc);
                 end
             end
             % Only DESC data
             if isnan(ASC_VOD(cc))&&~isnan(DESC_VOD(cc))
                 combined(cc)=DESC_VOD(cc);
                 combined_rmse(cc)=DESC_RMSE(cc);
             end
             % Only ASC data
             if ~isnan(ASC_VOD(cc))&&isnan(DESC_VOD(cc))
                 combined(cc)=ASC_VOD(cc);
                 combined_rmse(cc)=ASC_RMSE(cc);
             end
         end

         % Step (iii)
         % ASC-only: Take off ASC VOD data outside of mean +/- 2*STD
         ind=find(ASC_VOD<(nanmean(ASC_VOD)-2*nanstd(ASC_VOD))|ASC_VOD>(nanmean(ASC_VOD)+2*nanstd(ASC_VOD)));
         if ~isempty(ind)
             ASC_VOD(ind)=nan;
         end
         % Save the filtered ASC VOD data and the number of the filtered VOD data
         filtered_VOD_ASC(p,q,season_day(t):season_day(t+1)-1)=permute(ASC_VOD,[3 2 1]);
         ASC_number(p,q,t)=sum(~isnan(ASC_VOD),1);

         % DESC-only: Take off DESC VOD data outside of mean +/- 2*STD
         ind=find(DESC_VOD<(nanmean(DESC_VOD)-2*nanstd(DESC_VOD))|DESC_VOD>(nanmean(DESC_VOD)+2*nanstd(DESC_VOD)));
         if ~isempty(ind)
             DESC_VOD(ind)=nan;
         end
         % Save the filtered DESC VOD data and the number of the filtered VOD data
         filtered_VOD_DESC(p,q,season_day(t):season_day(t+1)-1)=permute(DESC_VOD,[3 2 1]);
         DESC_number(p,q,t)=sum(~isnan(DESC_VOD),1);

         % ASC&DESC-merged: Take off data outside of mean +/- 2*STD
         ind=find(combined<(nanmean(combined)-2*nanstd(combined))|combined>(nanmean(combined)+2*nanstd(combined)));
         if ~isempty(ind)
             combined(ind)=nan;
             combined_rmse(ind)=nan;
         end
         % Save the filtered ASC&DESC VOD data and the number of the filtered VOD data
         filtered_VOD_ASC_DESC(p,q,season_day(t):season_day(t+1)-1)=permute(combined,[3 1 2]);
         ASC_DESC_number(p,q,t)=sum(~isnan(combined),2);
        		end
    	    end
    	end
    end
    save(['Filtered_8k_5k_',num2str(yr),'heavy.mat'],'filtered_VOD_ASC','filtered_VOD_DESC','filtered_VOD_ASC_DESC','ASC_number','DESC_number','ASC_DESC_number','-v7.3')
end
