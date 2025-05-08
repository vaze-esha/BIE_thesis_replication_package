/*==============================================================================
									PPIC DATA
					
================================================================================

################################################################################
################################################################################


==============================================================================*/

	
	// SET SCHEME
	set scheme white_tableau
	graph set window fontface "andale mono"  // Set font 	


/*##############################################################################

								race patterns 

##############################################################################*/

/*##############################################################################
								2018
##############################################################################*/

	import spss using "`workingdir'/2018-July/2018.07.25.release.sav"
	
	// 28 29 30
		
	// change labels
	label define labels28 3 "nothing" 2 "a little" 1 "a lot", modify
	label values q28 labels28
	
	gen racialized = 0
	replace racialized = 1 if d8com == 2| d8com ==3 | d8com== 5| d8com ==6
	
	
	keep if racialized == 1
	
	
	// Q33
	catplot, over(q28) percent ///
		title("How much have you heard about the Cap-and-Trade program?", size(small)) ///
		note("") ///
		ytitle("% of total respondents")

	graph export "`workingdir'/plots/2018_race_aware.png", replace


	// Q34
	catplot, over(q29) percent ///
		title("Do you favor or oppose the Cap-and-Trade system?", size(small)) ///
		note("") ///
		ytitle("% of total respondents")

	graph export "`workingdir'/plots/2018_race_support.png", replace


	// Q35
	catplot, over(q30) percent ///
		title("How important is disadvantaged-targeted spending?", size(small)) ///
		note("") ///
		ytitle("% of total respondents")

	graph export "`workingdir'/plots/2018_race_targeted.png", replace
	
	clear
/*##############################################################################
								2023
##############################################################################*/

	import spss using "`workingdir'/2023-july/2023.07.12.release.sav"
	
	// 28 29 30
		
	// change labels
	label define labels40 3 "nothing", modify
	label values q40 labels40
	
	gen racialized = 0
	replace racialized = 1 if d8com == 2| d8com ==3 | d8com== 5| d8com ==6
	
	
	keep if racialized == 1
	
	
	// Q33
	catplot, over(q40) percent ///
		title("How much have you heard about the Cap-and-Trade program?", size(small)) ///
		note("") ///
		ytitle("% of total respondents")

	graph export "`workingdir'/plots/2023_race_aware.png", replace


	// Q34
	catplot, over(q41) percent ///
		title("Do you favor or oppose the Cap-and-Trade system?", size(small)) ///
		note("") ///
		ytitle("% of total respondents")

	graph export "`workingdir'/plots/2023_race_support.png", replace


	// Q35
	catplot, over(q42) percent ///
		title("How important is disadvantaged-targeted spending?", size(small)) ///
		note("") ///
		ytitle("% of total respondents")

	graph export "`workingdir'/plots/2023_race_targeted.png", replace
	
		
