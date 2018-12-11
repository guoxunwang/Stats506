/*****************************************************
Stats506, F18 Problem Set 4, Question 3
This file imports Medicare_PS_PUF data from:
 ./data/Medicare_Provider_Util_Payment_PUF_CY2016.txt
https://downloads.cms.gov/files/Medicare-Physician-and-Other-Supplier-NPI-Aggregate_CY2016.zip
Then prints some basic information about the file.
Author: Xun Wang xunwang@umich.edu
Date: Dec 7, 2018
 ******************************************************/
/* 80: ************************************************************************/

/*Part a*/
/* import delimited data in a data step */
DATA Medicare_PS_PUF;
	LENGTH
		npi              					$ 10
		nppes_provider_last_org_name 		$ 70
		nppes_provider_first_name 			$ 20
		nppes_provider_mi					$ 1
		nppes_credentials 					$ 20
		nppes_provider_gender				$ 1
		nppes_entity_code 					$ 1
		nppes_provider_street1 				$ 55
		nppes_provider_street2				$ 55
		nppes_provider_city 				$ 40
		nppes_provider_zip 					$ 20
		nppes_provider_state				$ 2
		nppes_provider_country				$ 2
		provider_type 						$ 55
		medicare_participation_indicator 	$ 1
		place_of_service					$ 1
		hcpcs_code       					$ 5
		hcpcs_description 					$ 256
		hcpcs_drug_indicator				$ 1
		line_srvc_cnt      					8
		bene_unique_cnt    					8
		bene_day_srvc_cnt   				8
		average_Medicare_allowed_amt   		8
		average_submitted_chrg_amt  		8
		average_Medicare_payment_amt   		8
		average_Medicare_standard_amt		8;
	INFILE '~\data\Medicare_Provider_Util_Payment_PUF_CY2016.txt'

		lrecl=32767
		dlm='09'x
		pad missover
		firstobs = 3
		dsd
        ;

	INPUT
		npi             
		nppes_provider_last_org_name 
		nppes_provider_first_name 
		nppes_provider_mi 
		nppes_credentials 
		nppes_provider_gender 
		nppes_entity_code 
		nppes_provider_street1 
		nppes_provider_street2 
		nppes_provider_city 
		nppes_provider_zip 
		nppes_provider_state 
		nppes_provider_country 
		provider_type 
		medicare_participation_indicator 
		place_of_service 
		hcpcs_code       
		hcpcs_description 
		hcpcs_drug_indicator
		line_srvc_cnt    
		bene_unique_cnt  
		bene_day_srvc_cnt 
		average_Medicare_allowed_amt 
		average_submitted_chrg_amt 
		average_Medicare_payment_amt
		average_Medicare_standard_amt;

	LABEL
		npi     							= "National Provider Identifier"       
		nppes_provider_last_org_name 		= "Last Name/Organization Name of the Provider"
		nppes_provider_first_name 			= "First Name of the Provider"
		nppes_provider_mi					= "Middle Initial of the Provider"
		nppes_credentials 					= "Credentials of the Provider"
		nppes_provider_gender 				= "Gender of the Provider"
		nppes_entity_code 					= "Entity Type of the Provider"
		nppes_provider_street1 				= "Street Address 1 of the Provider"
		nppes_provider_street2 				= "Street Address 2 of the Provider"
		nppes_provider_city 				= "City of the Provider"
		nppes_provider_zip 					= "Zip Code of the Provider"
		nppes_provider_state 				= "State Code of the Provider"
		nppes_provider_country 				= "Country Code of the Provider"
		provider_type	 					= "Provider Type of the Provider"
		medicare_participation_indicator 	= "Medicare Participation Indicator"
		place_of_service 					= "Place of Service"
		hcpcs_code       					= "HCPCS Code"
		hcpcs_description 					= "HCPCS Description"
		hcpcs_drug_indicator				= "Identifies HCPCS As Drug Included in the ASP Drug List"
		line_srvc_cnt    					= "Number of Services"
		bene_unique_cnt  					= "Number of Medicare Beneficiaries"
		bene_day_srvc_cnt 					= "Number of Distinct Medicare Beneficiary/Per Day Services"
		average_Medicare_allowed_amt 		= "Average Medicare Allowed Amount"
		average_submitted_chrg_amt 			= "Average Submitted Charge Amount"
		average_Medicare_payment_amt 		= "Average Medicare Payment Amount"
		average_Medicare_standard_amt		= "Average Medicare Standardized Payment Amount";

RUN;

/*Part b*/
/*subsetting*/
data mri;
 set Medicare_PS_PUF;
where prxmatch('/(MRI)./',hcpcs_description);
data mri_7;
 set mri;
where prxmatch('/^7/',hcpcs_code);
run;

/*Part c*/
/*data summary*/
data mri_7_total;
 set mri_7;
 total_Medicare_payment_amt=line_srvc_cnt*average_Medicare_payment_amt;
proc sort data=mri_7_total;
       by hcpcs_code;
proc summary data=mri_7_total;
          by hcpcs_code;
output out=mri_7_sum
       sum(line_srvc_cnt)=volume
       sum(total_Medicare_payment_amt)=total_payment;
data mri_7_average;
set mri_7_sum;
average_payment=total_payment/volume;

/*highest volume*/
proc summary data=mri_7_average;
output out=volume_max
       max(volume)=volume;
proc sort data=mri_7_average;
       by volume;
proc sort data=volume_max;
       by volume;
data volume_maxi;
drop  _TYPE_ _FREQ_;
merge mri_7_average volume_max(IN=IN2);
   by volume;
   if IN2;

/*highest average payment*/
proc summary data=mri_7_average;
output out=average_max
       max(average_payment)=average_payment;
proc sort data=mri_7_average;
       by average_payment;
proc sort data=average_max;
       by average_payment;
data average_maxi;
drop  _TYPE_ _FREQ_;
merge mri_7_average average_max(IN=IN2);
   by average_payment;
   if IN2;

/*highest total payment*/
proc summary data=mri_7_average;
output out=total_max
       max(total_payment)=total_payment;
proc sort data=mri_7_average;
       by total_payment;
proc sort data=total_max;
       by total_payment;
data total_maxi;
drop  _TYPE_ _FREQ_;
merge mri_7_average total_max(IN=IN2);
   by total_payment;
   if IN2;

/*combine up*/
data maxi;
set volume_maxi average_maxi total_maxi;
proc sort data=maxi nodupkey;
by hcpcs_code;
run;


/*Part d*/
/*subsetting*/  
proc sql;
     create table mri_sql as
	 select *
	 from Medicare_PS_PUF
	 where prxmatch('/(MRI)./',hcpcs_description) and prxmatch('/^7/',hcpcs_code);

	 create table mri_7_sql as
	 select hcpcs_code,sum(line_srvc_cnt) as volume,
            sum(average_Medicare_payment_amt*line_srvc_cnt) as total_payment,
            sum(average_Medicare_payment_amt*line_srvc_cnt)/sum(line_srvc_cnt) as average_payment
	 from mri_sql
     group by hcpcs_code;

/*highest volume, average payment and total payment*/
	 create table maxi_sql as
	 select *
	 from mri_7_sql
	 having volume=max(volume)
            or average_payment=max(average_payment)
	        or total_payment=max(total_payment);

quit;
run;

/*Part e*/
proc export data=maxi
  outfile = 'ps4_q3c.csv'
  dbms=dlm replace; 
  delimiter  = ",";
run; 
proc export data=maxi_sql
  outfile = 'ps4_q3d.csv'
  dbms=dlm replace; 
  delimiter  = ",";
run; 
proc sort data=maxi_sql;
by hcpcs_code;
proc compare base=maxi
             compare=maxi_sql 
             briefsummary
             method=relative;
run;

/* 80: ************************************************************************/

