/*==============================================================================
							VOTER_PARTICIPATION_IMPORTS
================================================================================

	PURPOSE:
	
		1. process voter turnout data
	
	
		
==============================================================================*/

/*==============================================================================
									2022
==============================================================================*/	
	import excel "$raw_input_data/ballots/2022_voter_participation.xlsx", sheet("Table 2") firstrow clear
	// we will now split these by ballot 
	

	rename NumberofPrecincts Number_of_Precincts
	rename EligibletoRegister Eligible_to_Register
	rename RegisteredVoters1 Registered_Voters
	rename PrecinctVoters Precinct_Voters
	rename VoteByMailVoters Vote_By_Mail_Voters
	rename TotalVoters Total_Voters
	rename PercentofVoteByMailVoters Percent_Vote_By_Mail
	rename TurnoutRegistered Turnout_Registered
	rename TurnoutEligible Turnout_Eligible

	// remove stars 
	foreach var of varlist County {
    replace `var' = subinstr(`var', "*", "", .)  // Remove all asterisks
}
	// drop last 2 rows
	drop in 59/60
	
	save "$intermediate_data/2022_voter_participation.dta", replace 
	
/*==============================================================================
									2018 
==============================================================================*/	
	
	
	import excel "$raw_input_data/ballots/2018_voter_participation.xlsx", sheet("Worksheet") firstrow clear
	// we will now split these by ballot 
	
	drop in 1/2
	// rename columns 
	rename VOTERPARTICIPATIONSTATISTICSB County
	rename B Number_of_Precincts
	rename C Eligible_to_Register
	rename D Registered_Voters
	rename E Precinct_Voters
	rename F Vote_By_Mail_Voters
	rename G Total_Voters
	rename H Percent_Vote_By_Mail
	rename I Turnout_Registered
	rename J Turnout_Eligible
	drop K
	
	drop in 1/3
	
	// drop empty rows
	replace County="." if County==""
	drop if County=="."
	
	gen rownum = _n  // Create a row number variable
	drop if mod(rownum, 2) == 0  // Drop even-numbered rows
	drop if rownum == 117 
	drop if rownum == 119 
	
	drop rownum  // Remove the temporary row number variable

	// remove stars 
	foreach var of varlist County Number_of_Precincts Eligible_to_Register Registered_Voters Precinct_Voters {
    replace `var' = subinstr(`var', "*", "", .)  // Remove all asterisks
}
	
	// remove percent sign 
	foreach var of varlist Percent_Vote_By_Mail Turnout_Registered Turnout_Eligible {
    replace `var' = subinstr(`var', "%", "", .)  // Remove the percent sign
    destring `var', replace force  // Convert to numeric format
    replace `var' = `var' / 100  // Divide by 100 to convert to decimal
}

	save "$intermediate_data/2018_voter_participation.dta", replace 
	
/*==============================================================================
									2016 
==============================================================================*/	
	
	
	import excel "$raw_input_data/ballots/2016_voter_participation.xlsx", sheet("Worksheet") firstrow clear
	// we will now split these by ballot 

	drop in 1/2
	// rename columns 
	rename VOTERPARTICIPATIONSTATISTICSB County
	rename B Number_of_Precincts
	rename C Eligible_to_Register
	rename D Registered_Voters
	rename E Precinct_Voters
	rename F Vote_By_Mail_Voters
	rename G Total_Voters
	rename H Percent_Vote_By_Mail
	rename I Turnout_Registered
	rename J Turnout_Eligible
	drop K
	
	// remove stars 
	foreach var of varlist County Number_of_Precincts Eligible_to_Register Registered_Voters Precinct_Voters {
    replace `var' = subinstr(`var', "*", "", .)  // Remove all asterisks
}
	
	// remove percent sign 
	foreach var of varlist Percent_Vote_By_Mail Turnout_Registered Turnout_Eligible {
    replace `var' = subinstr(`var', "%", "", .)  // Remove the percent sign
    destring `var', replace force  // Convert to numeric format
    replace `var' = `var' / 100  // Divide by 100 to convert to decimal
}

	drop in 59/60
	
	save "$intermediate_data/2016_voter_participation.dta", replace 
	