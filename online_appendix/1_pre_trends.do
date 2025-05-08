/*==============================================================================
									PPIC DATA
					
================================================================================

	1. Online appendix analysis 


################################################################################
################################################################################


==============================================================================*/

	// SET SCHEME
	set scheme white_tableau
	graph set window fontface "andale mono"  // Set font 	


/*##############################################################################

								2014: pre-trends

##############################################################################*/


	import spss using "`workingdir'/2014_July/2014.07.23.release.sav"
	
		
	// change labels
	label define labels39 3 "nothing", modify
	label values q33 labels39
	

// make one master graph for all repsonses, not disaggregated by county ========
	
	// PRETREND IS PINK 
	// Q33
	catplot, over(q33) percent ///
		title("How much have you heard about the Cap-and-Trade program?", size(small)) ///
		note("") ///
		ytitle("% of total respondents")

	graph export "`workingdir'/plots/q33_total.png", replace


	// Q34
	catplot, over(q34) percent ///
		title("Do you favor or oppose the Cap-and-Trade system?", size(small)) ///
		note("") ///
		ytitle("% of total respondents")

	graph export "`workingdir'/plots/q34_total.png", replace


	// Q35
	catplot, over(q35) percent ///
		title("Do you favor or oppose the Cap-and-Trade spending plan?", size(small)) ///
		note("") ///
		ytitle("% of total respondents")

	graph export "`workingdir'/plots/q35_total.png", replace
	
	// RACIAL TRENDS?
	gen racialized = 0
	replace racialized = 1 if d8com == 2| d8com ==3 | d8com== 5| d8com ==6
	
	preserve 
	
	keep if racialized == 1
	
	
	// Q33
	catplot, over(q33) percent ///
		title("How much have you heard about the Cap-and-Trade program?", size(small)) ///
		note("") ///
		ytitle("% of total respondents")

	graph export "`workingdir'/plots/q33_total_race.png", replace


	// Q34
	catplot, over(q34) percent ///
		title("Do you favor or oppose the Cap-and-Trade system?", size(small)) ///
		note("") ///
		ytitle("% of total respondents")

	graph export "`workingdir'/plots/q34_total_race.png", replace


	// Q35
	catplot, over(q35) percent ///
		title("Do you favor or oppose the Cap-and-Trade spending plan?", size(small)) ///
		note("") ///
		ytitle("% of total respondents")

	graph export "`workingdir'/plots/q35_total_race.png", replace
	
	restore
		


//******************************************************************************	
	// dropping if county appears infrequently, for visualization
	bysort county: gen freq = _N
	drop if freq < 50
	
//******************************************************************************	

	// q33 	//xtitle("How much have you heard about the Cap-and-Trade program?")
	preserve 

	// drop don't know responses
	drop if q33 == 8| q33 == 9
	
	catplot, over(q33) by(county, title("How much have you heard about the Cap-and-Trade program?", size(small)) note("")) percent(county) ///
	ytitle("% of county respondents") 
	
	graph export "`workingdir'/plots/q33.png", replace 

	restore
	
//******************************************************************************	
	// q34	Do you favor or oppose the cap-and-trade system?
	preserve 

	// drop don't know responses
	drop if q34 == 8| q34 == 9
	
	catplot, over(q34) by(county, title("Do you favor or oppose the Cap-and-Trade system?", size(small)) note("")) percent(county) ///
	ytitle("% of county respondents") ///

	graph export "`workingdir'/plots/q34.png", replace 

	restore
//******************************************************************************	
	
	// q35	Do you favor or oppose the cap-and-trade spending plan 
	preserve 

	// drop don't know response
	drop if q35 == 8| q35 == 9
	
	catplot, over(q35) by(county, title("Do you favor or oppose the Cap-and-Trade spending plan ?", size(small)) note("")) percent(county) ///
	ytitle("% of county respondents") ///

	graph export "`workingdir'/plots/q35.png", replace 

	restore
	
//==============================================================================
// check if the same patterns hold of we restrict sample to non-white people?
	
	keep if racialized == 1
	
	// q33 How much have you heard about the Cap-and-Trade program?
	preserve 

	// drop don't know responses
	drop if q33 == 8| q33 == 9
	
	catplot, over(q33) by(county, title("How much have you heard about the Cap-and-Trade program?", size(small)) note("")) percent(county) ///
	bar(1, color(purple)) ///
	ytitle("% of non-white county respondents") 
	
	graph export "`workingdir'/plots/q33_race.png", replace 

	restore
//******************************************************************************		
	
	// q34	Do you favor or oppose the cap-and-trade system?
	preserve 

	// drop don't know responses
	drop if q34 == 8| q34 == 9
	
	catplot, over(q34) by(county, title("Do you favor or oppose the Cap-and-Trade system?", size(small)) note("")) percent(county) ///
	bar(1, color(purple)) ///
	ytitle("% of non-white county respondents") ///

	graph export "`workingdir'/plots/q34_race.png", replace 

	restore
//******************************************************************************		
	// q35	Do you favor or oppose the cap-and-trade spending plan 
	preserve 
	
	// drop don't know response
	drop if q35 == 8| q35 == 9
	
	catplot, over(q35) by(county, title("Do you favor or oppose the Cap-and-Trade spending plan?", size(small)) note("")) percent(county) ///
	bar(1, color(purple)) ///
	ytitle("% of non-white county respondents") ///

	graph export "`workingdir'/plots/q35_race.png", replace 

	restore
	
	
	clear 
	
	
	