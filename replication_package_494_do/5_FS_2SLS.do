/*==============================================================================
							5_FS_2SLS
================================================================================

	PURPOSE:
	
	1. FS, RF, 2SLS for all years 
	2. produce maps to show funding variation
		
==============================================================================*/

/*============================================================================*/
	
						// FIRST STAGE REGRESSIONS 
		
/*============================================================================*/

	use "$final_data/panel_2015_2023.dta"
	
	
	encode County, gen(county_id)  // Convert county to numeric ID
	
	// choose max instrument val for 2018 (2 vals based on ces version)
	egen max_instrument = max(instrument) if Year == 2018, by(county_id)

	// Keep only observations where instrument equals the max for each county in 2018
	keep if Year != 2018 | instrument == max_instrument

	//Drop the temporary variable
	drop max_instrument

	
	// SET PANEL 
	xtset county_id Year  // Panel setup (if county-year is panel data)
	
	// sum all funding receieved until 2023 by each county
	bysort County (Year): gen cumulative_funding = sum(TOT_funding) // where TOT_funding is sum of funding in each county 
	gen log_cumulative_funding = log(cumulative_funding)
	
	// calculate an average of instrument over the years 
	egen avg_instrument = mean(instrument), by(County Year)
	
	// label vars 
	label variable log_cumulative_funding "Log(Cumulative Funding)"
	label variable Year ""
	label variable County ""
	label variable avg_instrument Instrument
	label variable instrument Instrument
	
	save "$final_data/panel_2015_2023.dta", replace 

								// FS ESTIMATES 
	
	
	// init out table
	estimates clear
	
	// ols
	reg log_cumulative_funding instrument, vce(cluster county_id)
	est store reg1
	
	// ols + control
	reg log_cumulative_funding instrument prop_nonwhite, vce(cluster county_id)
	est store reg2
	
	//output
	outreg2 [reg1 reg2] using "$tables/fs_table.tex", replace label ///
		title("Regression Results for Log Funding") 
		
	clear
	

	
/*============================================================================*/
	
								// REDUCED FORM 
		
/*============================================================================*/
	
	use "$final_data/panel_2015_2023.dta"
	
	// define local environmental propositions only 
	local props_2018 3 6 68 72
	local props_2016 65 67
	local props_2022 30
	
	* Loop through years
	foreach year in 2016 2018 2022 {
		* Get the propositions for this year
		local props `props_`year''

		* Reset stored estimates
		estimates clear

		* Run regressions for each proposition
		local first = 1
		foreach num in `props' {
			preserve   // Prevent permanent changes

			* Run regression
			reg prop_yes_`num' instrument, vce(cluster county_id)
			est store prop_`num'

			* Append to the table instead of replacing
			if `first' == 1 {
				outreg2 using "$tables/rf_`year'.tex", replace label ///
					title("Reduced Form for `year' Propositions")
				local first = 0
			}
			else {
				outreg2 using "$tables/rf_`year'.tex", append label 
			}

			restore   // Reload full dataset for next iteration
		}

		display "Table for `year' saved successfully."
	}
	
	clear

	
/*============================================================================*/
	
								// 2SLS
		
/*============================================================================*/
	
	use "$final_data/panel_2015_2023.dta", clear

	// Define local environmental propositions only 
	local props_2018 3 6 68 72
	local props_2016 65 67
	local props_2022 30
	// placebo years 
	local props_2012 39
	local props_2014 1

	* Loop through years
	foreach year in 2012 2014 2016 2018 2022 {
		* Get the propositions for this year
		local props `props_`year''

		* Reset stored estimates
		estimates clear

		* Run regressions for each proposition
		local first = 1
		foreach num in `props' {
			preserve   // Prevent permanent changes

			* Run OLS regression
			reg prop_yes_`num' log_cumulative_funding, vce(cluster county_id)
			est store ols_prop_`num'

			* Run 2SLS (IV) regression
			ivreg2 prop_yes_`num' (log_cumulative_funding = instrument), cluster(county_id)
			est store sls_prop_`num'

			* Output both OLS and 2SLS estimates to the same table
			if `first' {
				outreg2 [ols_prop_`num' sls_prop_`num'] using "$tables/`year'_ols_2sls.tex", replace label ///
					title("OLS and 2SLS Estimates for `year'")
				local first 0
			}
			else {
				outreg2 [ols_prop_`num' sls_prop_`num'] using "$tables/`year'_ols_2sls.tex", append label
			}

			restore   // Reload full dataset for next iteration
		}

		display "Results for `year' saved successfully."
		
		
			// Build the coefplot command dynamically for all propositions in this year
			local coefplot_cmd
			foreach num in `props' {
				local coefplot_cmd "`coefplot_cmd' (sls_prop_`num', label("Prop `num'"))"
			}

			// Generate the coefplot for the year
			coefplot `coefplot_cmd', ///
				vert ///
				title("Votes in Favour (2SLS) for `year'") ///
				xlabel(, angle(360) grid) ///
				ylabel(, grid) ///
				drop(_cons) ///
				xline(0) ///
				yline(0) ///

			// Export the coefplot as an image
			graph export "$tables/`year'_2sls_coefplot.png", replace

			display "Coefplot for `year' generated successfully."

	}

	clear

/*============================================================================*/
	
						// 2SLS WITH CONTROLS 
		
/*============================================================================*/
	
	use "$final_data/panel_2015_2023.dta", clear

	// Define local environmental propositions only 
	local props_2018 3 6 68 72
	local props_2016 65 67
	local props_2022 30
	// placebo years 
	local props_2012 39
	local props_2014 1

	* Loop through years
	foreach year in 2012 2014 2016 2018 2022 {
		* Get the propositions for this year
		local props `props_`year''

		* Reset stored estimates
		estimates clear

		* Run regressions for each proposition
		local first = 1
		foreach num in `props' {
			preserve   // Prevent permanent changes

			* Run OLS regression
			reg prop_yes_`num' log_cumulative_funding prop_nonwhite, vce(cluster county_id)
			est store ols_prop_`num'

			* Run 2SLS (IV) regression
			ivreg2 prop_yes_`num' (log_cumulative_funding = instrument) prop_nonwhite, cluster(county_id)
			est store sls_prop_`num'

			* Output both OLS and 2SLS estimates to the same table
			if `first' {
				outreg2 [ols_prop_`num' sls_prop_`num'] using "$tables/`year'_ols_2sls.tex", replace label ///
					title("OLS and 2SLS Estimates for `year'")
				local first 0
			}
			else {
				outreg2 [ols_prop_`num' sls_prop_`num'] using "$tables/`year'_ols_2sls.tex", append label
			}

			restore   // Reload full dataset for next iteration
		}

		display "Results for `year' saved successfully."
		
		
			// Build the coefplot command dynamically for all propositions in this year
			local coefplot_cmd
			foreach num in `props' {
				local coefplot_cmd "`coefplot_cmd' (sls_prop_`num', label("Prop `num'"))"
			}

			// Generate the coefplot for the year
			coefplot `coefplot_cmd', ///
				vert ///
				title("Votes in Favour (2SLS) for `year'") ///
				xlabel(, angle(360) grid) ///
				ylabel(, grid) ///
				drop(_cons) ///
				xline(0) ///
				yline(0) ///

			// Export the coefplot as an image
			graph export "$tables/`year'_2sls_coefplot_wcontrols.png", replace

			display "Coefplot for `year' generated successfully."

	}

	clear
	

	
/*============================================================================*/
	
								// FIGURES
		
/*============================================================================*/
	
	use "$final_data/panel_2015_2023.dta"

/*==============================================================================
								SET SCHEME 
==============================================================================*/
	
	// SET SCHEME
	set scheme s1color
	graph set window fontface "Helvetica"  // Set font to helvetica
	
/*==============================================================================
								SUM STATS
==============================================================================*/
	
	// LOG CUML FUNDING
	histogram log_cumulative_funding, bins(15) ///
		fcolor(emerald) lcolor(white) /// Fill = emerald, outline = black
		graphregion(color(white)) 
		
	graph export "$tables/log_cuml_funding.png", replace

		
	// INSTRUMENT
	twoway (line avg_instrument county_id, by(Year) lcolor(emerald)) ///
       (scatter avg_instrument county_id, mcolor(green%50)), ///
       by(Year, legend(off)) ///
	   xlabel(none)
	   
	graph export "$tables/instrument_dist.png", replace
	
	clear
/*==============================================================================
									MAPS!!!	
==============================================================================*/
	
	shp2dta using "$raw_input_data/CA_Counties.shp", database(counties.dta) coordinates(coords.dta) genid(county_id)
	
	use "$dodir/counties.dta"
	
	replace NAME = strtrim(NAME)
	rename NAME County
	
	save "$raw_input_data/counties.dta", replace 
	clear
	
	use "$final_data/panel_2015_2023.dta"
	
	// MAKING A MAP OF FUNDING 
	merge m:1 County using "$raw_input_data/counties.dta"
	drop _merge 
	preserve 
	keep if Year == 2015
	spmap TOT_funding using "$dodir/coords.dta", id(county_id) fcolor(Greens2) 
	graph export "$tables/funding_map_2015.png", replace
	restore
	
	// now as a loop
	forval year = 2016/2023 {
		// Merge with county data
		merge m:1 County using "$raw_input_data/counties.dta"
		drop _merge 
		preserve  // Prevent permanent changes
		
		// Keep data for the current year only
		keep if Year == `year'
		
		// Create the map for the current year
		spmap TOT_funding using "$dodir/coords.dta", id(county_id) fcolor(Greens2) 
		
		// Save the map as a PNG file, with the year in the filename
		graph export "$tables/funding_map_`year'.png", replace
		
		restore  // Restore the dataset for the next iteration
}




		