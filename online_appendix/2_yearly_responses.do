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

//==============================================================================
//==============================================================================

	// Define the years and corresponding day of release in July
	local years "2016 2017 2018 2019 2020 2021 2023"
	local days  "27    26    25    29    29    28    12"

	// Loop through each year
	forvalues i = 1/7 {
		
		// Extract year and matching day
		local year : word `i' of `years'
		local day  : word `i' of `days'

		// Display for debugging
		display "Processing year: `year', release day: `day'"

		// Import SPSS data
		import spss using "`workingdir'/`year'-july/`year'.07.`day'.release.sav", clear

		// Label handling (adapt per year if needed)
		label define awarenesslbl 3 "nothing", modify
		
		// Define question variable names per year
		if `year' == 2016 {
			local q_awareness q27
			local q_support    q28
			local q_targeted   q29
		}
		else if `year' == 2017 {
			local q_awareness q18
			local q_support    q19
			local q_targeted   q20a
		}
		else if `year' == 2018 {
			local q_awareness q28
			local q_support    q29
			local q_targeted   q30
		}
		else if `year' == 2019 {
			local q_awareness q26
			local q_support    q27
			local q_targeted   .
		}
		else if `year' == 2020 {
			local q_awareness q37
			local q_support    q38
			local q_targeted   q39
		}
		else if `year' == 2021 {
			local q_awareness q33
			local q_support    q34
			local q_targeted   q35
		}
		else if `year' == 2023 {
			local q_awareness q40
			local q_support    q41
			local q_targeted   q42
		}

		// Awareness plot
		if "`q_awareness'" != "." {
			catplot, over(`q_awareness') percent ///
				title("How much have you heard about the Cap-and-Trade program? (`year')", size(small)) ///
				ytitle("% of total respondents") ///
				note("")

			graph export "`workingdir'/plots/awareness_`year'.png", replace
		}

		// Support plot
		if "`q_support'" != "." {
			catplot, over(`q_support') percent ///
				title("Do you favor or oppose the Cap-and-Trade system? (`year')", size(small)) ///
				ytitle("% of total respondents") ///
				note("")

			graph export "`workingdir'/plots/support_`year'.png", replace
		}

		// Targeted spending plot (if available)
		if "`q_targeted'" != "." {
			catplot, over(`q_targeted') percent ///
				title("How important is disadvantaged-targeted spending? (`year')", size(small)) ///
				ytitle("% of total respondents") ///
				note("")

			graph export "`workingdir'/plots/targeted_`year'.png", replace
		}
		
		clear
	}
	


//==============================================================================
//==============================================================================

	// Define years and corresponding release day
	local years "2016 2017 2018 2019 2020 2021 2023"
	local days  "27    26    25    29    29    28    12"

	// Create a tempfile to store the combined dataset
	tempfile ppic_panel

	// Initialize panel (create empty dataset)
	clear
	save `ppic_panel', emptyok replace

	// Start loop
	forvalues i = 1/7 {

		// Get year and day
		local year : word `i' of `years'
		local day  : word `i' of `days'
		
		display "Processing year: `year'"

		// Import SPSS
		import spss using "`workingdir'/`year'-july/`year'.07.`day'.release.sav", clear

		// Define variable names per year
		if `year' == 2016 {
			local q_awareness q27
			local q_support    q28
			local q_targeted   q29
		}
		else if `year' == 2017 {
			local q_awareness q18
			local q_support    q19
			local q_targeted   q20a
		}
		else if `year' == 2018 {
			local q_awareness q28
			local q_support    q29
			local q_targeted   q30
		}
		else if `year' == 2019 {
			local q_awareness q26
			local q_support    q27
			local q_targeted   .
		}
		else if `year' == 2020 {
			local q_awareness q37
			local q_support    q38
			local q_targeted   q39
		}
		else if `year' == 2021 {
			local q_awareness q33
			local q_support    q34
			local q_targeted   q35
		}
		else if `year' == 2023 {
			local q_awareness q40
			local q_support    q41
			local q_targeted   q42
		}

		// Check and rename if the variable exists
		capture confirm variable `q_awareness'
		if !_rc rename `q_awareness' awareness

		capture confirm variable `q_support'
		if !_rc rename `q_support' support

		if "`q_targeted'" != "." {
			capture confirm variable `q_targeted'
			if !_rc rename `q_targeted' targeted
		}

		// Add year variable
		gen survey_year = `year'

		// Create list of variables to keep
		local keepvars survey_year county

		capture confirm variable awareness
		if !_rc local keepvars `keepvars' awareness

		capture confirm variable support
		if !_rc local keepvars `keepvars' support

		capture confirm variable targeted
		if !_rc local keepvars `keepvars' targeted

		keep `keepvars'

		// Append to growing panel
		append using `ppic_panel'
		save `ppic_panel', replace
	}

	// Save final panel dataset
	use `ppic_panel', clear
	save "`workingdir'/ppic_panel.dta", replace
	
//==============================================================================
//==============================================================================
use "`workingdir'/ppic_panel.dta"
// -----------------------------
// Awareness over time
// -----------------------------
replace awareness = 3 if awareness == 8

graph bar (count), over(awareness, label(angle(45))) over(survey_year, label(angle(0))) ///
    stack asyvars ///
    title("Awareness of Cap-and-Trade Over Time", size(medlarge)) ///
    ytitle("N of respondents") ///
    legend(order(1 "a lot" 2 "a little" 3 "nothing")) ///
    blabel(none)

graph export "/Users/eshavaze/Documents/ppic/plots/awareness_trend.png", replace

// -----------------------------
// Support over time
// -----------------------------
replace support = 8 if support == 998
graph bar (count), over(support, label(angle(45))) over(survey_year, label(angle(0))) ///
    stack asyvars ///
    title("Support for Cap-and-Trade Over Time", size(medlarge)) ///
    ytitle("N of respondents") ///
    legend(order(1 "favor" 2 "oppose" 3 "don't know")) ///
    blabel(none)

graph export "/Users/eshavaze/Documents/ppic/plots/support_trend.png", replace


// -----------------------------
// Targeted spending over time (skip years without it)
// -----------------------------
replace targeted = 998 if targeted == 8

capture confirm variable targeted
if !_rc {
    drop if missing(targeted)
    
    graph bar (count), over(targeted, label(angle(45))) over(survey_year, label(angle(0))) ///
        stack asyvars ///
        title("Importance of Targeted Spending Over Time", size(medlarge)) ///
        ytitle("N of respondents") ///
		legend(order(1 "very important" 2 "somewhat important" 3 "not too important" 4 "not important at all" 5 "don't know")) ///
        blabel(none)

    graph export "/Users/eshavaze/Documents/ppic/plots/targeted_trend.png", replace
}
	
