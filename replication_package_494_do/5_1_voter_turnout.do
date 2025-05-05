/*==============================================================================
								VOTER_TURNOUT_2SLS
================================================================================

	PURPOSE:
	
	1. FS, RF, 2SLS for all years using VT as outcome
==============================================================================*/

/*============================================================================*/
	
									// 2022
		
/*============================================================================*/

	use "$final_data/panel_2015_2023.dta"
	
	merge m:1 County using "$intermediate_data/2022_voter_participation.dta"
	drop if _merge==2
	
		
	* OLS regression
	reg  Turnout_Eligible log_cumulative_funding, vce(cluster county_id)
	est store ols
	
	* ols controls 
	reg  Turnout_Eligible log_cumulative_funding prop_nonwhite, vce(cluster county_id)
	est store olsc
	
	* 2SLS (IV) regression
	ivreg2  Turnout_Eligible (log_cumulative_funding = avg_instrument), cluster(county_id)
	est store tsls

	* 2SLS (IV) regression controls 
	ivreg2  Turnout_Eligible (log_cumulative_funding = avg_instrument) prop_nonwhite, cluster(county_id)
	est store tslsc

	//output
	outreg2 [ols olsc tsls tslsc] using "$tables/2022_vt.tex", replace label ///
		title("Voter Turnout 2022") 
		
	clear
/*============================================================================*/
	
						// 2018
		
/*============================================================================*/
	use "$final_data/panel_2015_2023.dta"
	
	merge m:1 County using "$intermediate_data/2018_voter_participation.dta"
	drop if _merge==2
	
	
	// destring and clean outcome var 
	replace Total_Voters = subinstr(Total_Voters, ",", "", .)

	destring Total_Voters, replace 
	destring Turnout_Eligible, replace 
		
	* OLS regression
	reg  Turnout_Eligible log_cumulative_funding, vce(cluster county_id)
	est store ols
	
	* ols controls 
	reg  Turnout_Eligible log_cumulative_funding prop_nonwhite, vce(cluster county_id)
	est store olsc
	
	* 2SLS (IV) regression
	ivreg2  Turnout_Eligible (log_cumulative_funding = avg_instrument), cluster(county_id)
	est store tsls

	* 2SLS (IV) regression controls 
	ivreg2  Turnout_Eligible (log_cumulative_funding = avg_instrument) prop_nonwhite, cluster(county_id)
	est store tslsc

	//output
	outreg2 [ols olsc tsls tslsc] using "$tables/2018_vt.tex", replace label ///
		title("Voter Turnout 2018") 
		
		
	clear
	
/*============================================================================*/
	
						// 2016
		
/*============================================================================*/
	use "$final_data/panel_2015_2023.dta"
	
	merge m:1 County using "$intermediate_data/2016_voter_participation.dta"
	drop if _merge==2
	
	
	// destring and clean outcome var 
	replace Total_Voters = subinstr(Total_Voters, ",", "", .)

	destring Total_Voters, replace 
	destring Turnout_Eligible, replace 
		
	* OLS regression
	reg  Turnout_Eligible log_cumulative_funding, vce(cluster county_id)
	est store ols
	
	* ols controls 
	reg  Turnout_Eligible log_cumulative_funding prop_nonwhite, vce(cluster county_id)
	est store olsc
	
	* 2SLS (IV) regression
	ivreg2  Turnout_Eligible (log_cumulative_funding = avg_instrument), cluster(county_id)
	est store tsls

	* 2SLS (IV) regression controls 
	ivreg2  Turnout_Eligible (log_cumulative_funding = avg_instrument) prop_nonwhite, cluster(county_id)
	est store tslsc

	//output
	outreg2 [ols olsc tsls tslsc] using "$tables/2016_vt.tex", replace label ///
		title("Voter Turnout 2016") 
		
		
	clear
	
		