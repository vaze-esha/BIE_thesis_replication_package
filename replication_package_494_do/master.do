/*==============================================================================
									MASTER
==============================================================================*/	

	/*
	
	  Replace USER/PATH/TO/REPO/BIE_thesis_replication_package
	  with the path on your machine where `BIE_thesis_replication_package` 
	  is cloned
	
	*/
	
	
	* ADD PATH TO REPLICATION REPO HERE 

	global user_machine "USER/PATH/TO/REPO/BIE_thesis_replication_package"
	
********************************************************************************
********************************************************************************

	global workingdir "$user_machine/replication_package_494"
	di "$workingdir"
	
	global dodir "$user_machine/replication_package_494_do"
	di "$dodir"
	
********************************************************************************	
********************************************************************************

	
	* raw input dir
	global raw_input_data "$workingdir/0_raw_input"
	di "$raw_input_data"

	* intermediate processed data 
	global intermediate_data "$workingdir/1_intermediate"
	di "$intermediate_data"
	
	
	* final datasets
	global final_data "$workingdir/2_final"
	di "$final_data"

	* tables 
	global tables "$workingdir/3_tables"
	di "$tables"
	
********************************************************************************

	// DATA PROCESSING FILES 
	do "$dodir/1_import_pre_process.do"
	
	
	// BALLOT DATA 
	do "$dodir/2_ballot_imports/2_0_2012_ballot.do"
	do "$dodir/2_ballot_imports/2_0_2014_ballot.do"
	do "$dodir/2_ballot_imports/2_1_2016_ballot.do"
	do "$dodir/2_ballot_imports/2_2_2018_ballot.do"
	do "$dodir/2_ballot_imports/2_3_2020_ballot.do"
	do "$dodir/2_ballot_imports/2_4_2022_ballot.do"
	do "$dodir/2_ballot_imports/2_5_voter_particpation.do"
	
	
	// DATA PROCESSING FILES 
	do "$dodir/3_process_covariates.do" 
	do "$dodir/4_merge_covariates_with_outcomes.do"

	
	// DATA ANALYSIS FILES 
	do "$dodir/5_FS_2SLS.do"
