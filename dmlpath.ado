*!TITLE: DMLPATH - path-specific effects using de-biased machine learning
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1 
*!

program define dmlpath, rclass
	
	version 15	

	syntax varlist(min=2 numeric) [if][in], ///
		model(string) ///
		dvar(varname numeric) ///
		d(real) ///
		dstar(real) ///
		[ cvars(varlist numeric) ///
		xfits(integer 5) ///
		seed(integer 12345) ///
		censor(numlist min=2 max=2) * ] 
		
	qui {
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000
		local N = r(N)
	}
			
	gettoken yvar mvars : varlist
	
	local num_mvars = wordcount("`mvars'")

	if (`num_mvars' > 5) {
		display as error "dmlpath only supports a maximum of 5 mvars"
		error 198
	}
	
	local i = 1
	foreach v of local mvars {
		local mvar`i' `v'
		local ++i
	}
	
	local modeltypes rforest lasso
	local nmodeltype : list posof "`model'" in modeltypes
	if !`nmodeltype' {
		display as error "Error: model must be chosen from: `modeltypes'."
		error 198		
	}

	confirm variable `dvar'
	qui levelsof `dvar', local(levels)
	if "`levels'" != "0 1" & "`levels'" != "1 0" {
		display as error "The variable `dvar' is not binary and coded 0/1"
		error 198
	}
	
	if ("`model'"=="rforest") {
		capture which rforest
		if _rc {
			display as error "{p 0 0 5 0} A required package is not installed."
			display as error "This module depends on rforest."
			display as error "Install using -ssc install rforest-"
			exit 198
		}
	}
	
	if ("`model'"=="lasso") {
		capture which lasso2
		if _rc {
			display as error "{p 0 0 5 0} A required package is not installed."
			display as error "This module depends on lasso2."
			display as error "Install using -ssc install lassopack-"
			exit 198
		}

		capture which lassologit
		if _rc {
			display as error "{p 0 0 5 0} A required package is not installed."
			display as error "This module depends on lassologit."
			display as error "Install using -ssc install lassopack-"
			exit 198
		}
	}	
	
	if ("`censor'" != "") {
		local censor1: word 1 of `censor'
		local censor2: word 2 of `censor'

		if (`censor1' >= `censor2') {
			di as error "The first number in the censor() option must be less than the second."
			error 198
		}

		if (`censor1' < 1 | `censor1' > 49) {
			di as error "The first number in the censor() option must be between 1 and 49."
			error 198
		}

		if (`censor2' < 51 | `censor2' > 99) {
			di as error "The second number in the censor() option must be between 51 and 99."
			error 198
		}
	}
	
	if (`num_mvars' == 1) {
	
		dmlmne `yvar' `mvars' if `touse', ///
			model(`model') xfits(`xfits') seed(`seed') ///
			dvar(`dvar') d(`d') dstar(`dstar') cvars(`cvars') censor(`censor') `options'
	
		qui mean eifATE_r001_1 eifNDE_r001_1 eifNIE_r001_1 if `touse'

		scalar ate = _b[eifATE_r001_1]
		scalar nde = _b[eifNDE_r001_1]
		scalar nie = _b[eifNIE_r001_1]
	
		scalar se_ate = _se[eifATE_r001_1]
		scalar se_nde = _se[eifNDE_r001_1]
		scalar se_nie = _se[eifNIE_r001_1]
	
		scalar ll95_ate = _b[eifATE_r001_1]-1.96*_se[eifATE_r001_1]
		scalar ll95_nde = _b[eifNDE_r001_1]-1.96*_se[eifNDE_r001_1]
		scalar ll95_nie = _b[eifNIE_r001_1]-1.96*_se[eifNIE_r001_1]

		scalar ul95_ate = _b[eifATE_r001_1]+1.96*_se[eifATE_r001_1]
		scalar ul95_nde = _b[eifNDE_r001_1]+1.96*_se[eifNDE_r001_1]
		scalar ul95_nie = _b[eifNIE_r001_1]+1.96*_se[eifNIE_r001_1]

		scalar pval_ate = (1-normal(abs(_b[eifATE_r001_1]/_se[eifATE_r001_1])))*2
		scalar pval_nde = (1-normal(abs(_b[eifNDE_r001_1]/_se[eifNDE_r001_1])))*2
		scalar pval_nie = (1-normal(abs(_b[eifNIE_r001_1]/_se[eifNIE_r001_1])))*2

		matrix results = ///
			(ate, se_ate, pval_ate, ll95_ate, ul95_ate \ ///
			nde, se_nde, pval_nde, ll95_nde, ul95_nde \ ///
			nie, se_nie, pval_nie, ll95_nie, ul95_nie)
	
		matrix rownames results = "ATE" "NDE" "NIE"
		matrix colnames results = "Est." "Std. Err." "P>|z|" "[95% Conf." "Interval]"
		
		capture drop eifATE_r001_1 eifNDE_r001_1 eifNIE_r001_1
		
	}

	if (`num_mvars' == 2) {
	
		dmlmne `yvar' `mvar1' `mvar2' if `touse', ///
			model(`model') xfits(`xfits') seed(`seed') ///
			dvar(`dvar') d(`d') dstar(`dstar') cvars(`cvars') censor(`censor') `options'
		
		tempvar mnde_M1M2
		qui gen `mnde_M1M2' = eifNDE_r001_2 if `touse'
		
		capture drop eifATE_r001_2 eifNDE_r001_2 eifNIE_r001_2

		dmlmne `yvar' `mvar1' if `touse', ///
			model(`model') xfits(`xfits') seed(`seed') ///
			dvar(`dvar') d(`d') dstar(`dstar') cvars(`cvars') censor(`censor') `options'
		
		tempvar mnde_M1 diff_mnde_M1_mnde_M1M2
		qui gen `mnde_M1' = eifNDE_r001_1 if `touse'
		qui gen `diff_mnde_M1_mnde_M1M2' = `mnde_M1' - `mnde_M1M2' if `touse'
		
		qui mean `mnde_M1M2' `diff_mnde_M1_mnde_M1M2' eifNIE_r001_1 eifATE_r001_1 if `touse'
		
		scalar pse_DY = _b[`mnde_M1M2']
		scalar pse_DM2Y = _b[`diff_mnde_M1_mnde_M1M2']
		scalar pse_DM1Y = _b[eifNIE_r001_1]
		scalar ate = _b[eifATE_r001_1]
	
		scalar se_pse_DY = _se[`mnde_M1M2']
		scalar se_pse_DM2Y = _se[`diff_mnde_M1_mnde_M1M2']
		scalar se_pse_DM1Y = _se[eifNIE_r001_1]
		scalar se_ate = _se[eifATE_r001_1]
	
		scalar ll95_pse_DY = _b[`mnde_M1M2']-1.96*_se[`mnde_M1M2']
		scalar ll95_pse_DM2Y = _b[`diff_mnde_M1_mnde_M1M2']-1.96*_se[`diff_mnde_M1_mnde_M1M2']
		scalar ll95_pse_DM1Y = _b[eifNIE_r001_1]-1.96*_se[eifNIE_r001_1]
		scalar ll95_ate = _b[eifATE_r001_1]-1.96*_se[eifATE_r001_1]

		scalar ul95_pse_DY = _b[`mnde_M1M2']+1.96*_se[`mnde_M1M2']
		scalar ul95_pse_DM2Y = _b[`diff_mnde_M1_mnde_M1M2']+1.96*_se[`diff_mnde_M1_mnde_M1M2']
		scalar ul95_pse_DM1Y = _b[eifNIE_r001_1]+1.96*_se[eifNIE_r001_1]
		scalar ul95_ate = _b[eifATE_r001_1]+1.96*_se[eifATE_r001_1]

		scalar pval_pse_DY = (1-normal(abs(_b[`mnde_M1M2']/_se[`mnde_M1M2'])))*2
		scalar pval_pse_DM2Y = (1-normal(abs(_b[`diff_mnde_M1_mnde_M1M2']/_se[`diff_mnde_M1_mnde_M1M2'])))*2
		scalar pval_pse_DM1Y = (1-normal(abs(_b[eifNIE_r001_1]/_se[eifNIE_r001_1])))*2
		scalar pval_ate = (1-normal(abs(_b[eifATE_r001_1]/_se[eifATE_r001_1])))*2

		matrix results = ///
			(ate, se_ate, pval_ate, ll95_ate, ul95_ate \ ///
			pse_DY, se_pse_DY, pval_pse_DY, ll95_pse_DY, ul95_pse_DY \ ///
			pse_DM2Y, se_pse_DM2Y, pval_pse_DM2Y, ll95_pse_DM2Y, ul95_pse_DM2Y \ ///
			pse_DM1Y, se_pse_DM1Y, pval_pse_DM1Y, ll95_pse_DM1Y, ul95_pse_DM1Y)
	
		matrix rownames results = "ATE" "PSE_DY" "PSE_DM2Y" "PSE_DM1Y"
		matrix colnames results = "Est." "Std. Err." "P>|z|" "[95% Conf." "Interval]"
		
		capture drop eifATE_r001_1 eifNDE_r001_1 eifNIE_r001_1
		
	}

	if (`num_mvars' == 3) {
	
		dmlmne `yvar' `mvar1' `mvar2' `mvar3' if `touse', ///
			model(`model') xfits(`xfits') seed(`seed') ///
			dvar(`dvar') d(`d') dstar(`dstar') cvars(`cvars') censor(`censor') `options'
		
		tempvar mnde_M1M2M3
		qui gen `mnde_M1M2M3' = eifNDE_r001_3 if `touse'
		
		capture drop eifATE_r001_3 eifNDE_r001_3 eifNIE_r001_3
		
		dmlmne `yvar' `mvar1' `mvar2' if `touse', ///
			model(`model') xfits(`xfits') seed(`seed') ///
			dvar(`dvar') d(`d') dstar(`dstar') cvars(`cvars') censor(`censor') `options'
		
		tempvar mnde_M1M2 diff_mnde_M1M2_mnde_M1M2M3
		qui gen `mnde_M1M2' = eifNDE_r001_2 if `touse'
		qui gen `diff_mnde_M1M2_mnde_M1M2M3' = `mnde_M1M2' - `mnde_M1M2M3' if `touse'
		
		capture drop eifATE_r001_2 eifNDE_r001_2 eifNIE_r001_2

		dmlmne `yvar' `mvar1' if `touse', ///
			model(`model') xfits(`xfits') seed(`seed') ///
			dvar(`dvar') d(`d') dstar(`dstar') cvars(`cvars') censor(`censor') `options'
		
		tempvar mnde_M1 diff_mnde_M1_mnde_M1M2
		qui gen `mnde_M1' = eifNDE_r001_1 if `touse'
		qui gen `diff_mnde_M1_mnde_M1M2' = `mnde_M1' - `mnde_M1M2' if `touse'
		
		qui mean `mnde_M1M2M3' `diff_mnde_M1M2_mnde_M1M2M3' `diff_mnde_M1_mnde_M1M2' eifNIE_r001_1 eifATE_r001_1 if `touse'
		
		scalar pse_DY = _b[`mnde_M1M2M3']
		scalar pse_DM3Y = _b[`diff_mnde_M1M2_mnde_M1M2M3']
		scalar pse_DM2Y = _b[`diff_mnde_M1_mnde_M1M2']
		scalar pse_DM1Y = _b[eifNIE_r001_1]
		scalar ate = _b[eifATE_r001_1]
	
		scalar se_pse_DY = _se[`mnde_M1M2M3']
		scalar se_pse_DM3Y = _se[`diff_mnde_M1M2_mnde_M1M2M3']
		scalar se_pse_DM2Y = _se[`diff_mnde_M1_mnde_M1M2']
		scalar se_pse_DM1Y = _se[eifNIE_r001_1]
		scalar se_ate = _se[eifATE_r001_1]
	
		scalar ll95_pse_DY = _b[`mnde_M1M2M3']-1.96*_se[`mnde_M1M2M3']
		scalar ll95_pse_DM3Y = _b[`diff_mnde_M1M2_mnde_M1M2M3']-1.96*_se[`diff_mnde_M1M2_mnde_M1M2M3']
		scalar ll95_pse_DM2Y = _b[`diff_mnde_M1_mnde_M1M2']-1.96*_se[`diff_mnde_M1_mnde_M1M2']
		scalar ll95_pse_DM1Y = _b[eifNIE_r001_1]-1.96*_se[eifNIE_r001_1]
		scalar ll95_ate = _b[eifATE_r001_1]-1.96*_se[eifATE_r001_1]

		scalar ul95_pse_DY = _b[`mnde_M1M2M3']+1.96*_se[`mnde_M1M2M3']
		scalar ul95_pse_DM3Y = _b[`diff_mnde_M1M2_mnde_M1M2M3']+1.96*_se[`diff_mnde_M1M2_mnde_M1M2M3']
		scalar ul95_pse_DM2Y = _b[`diff_mnde_M1_mnde_M1M2']+1.96*_se[`diff_mnde_M1_mnde_M1M2']
		scalar ul95_pse_DM1Y = _b[eifNIE_r001_1]+1.96*_se[eifNIE_r001_1]
		scalar ul95_ate = _b[eifATE_r001_1]+1.96*_se[eifATE_r001_1]

		scalar pval_pse_DY = (1-normal(abs(_b[`mnde_M1M2M3']/_se[`mnde_M1M2M3'])))*2
		scalar pval_pse_DM3Y = (1-normal(abs(_b[`diff_mnde_M1M2_mnde_M1M2M3']/_se[`diff_mnde_M1M2_mnde_M1M2M3'])))*2
		scalar pval_pse_DM2Y = (1-normal(abs(_b[`diff_mnde_M1_mnde_M1M2']/_se[`diff_mnde_M1_mnde_M1M2'])))*2
		scalar pval_pse_DM1Y = (1-normal(abs(_b[eifNIE_r001_1]/_se[eifNIE_r001_1])))*2
		scalar pval_ate = (1-normal(abs(_b[eifATE_r001_1]/_se[eifATE_r001_1])))*2

		matrix results = ///
			(ate, se_ate, pval_ate, ll95_ate, ul95_ate \ ///
			pse_DY, se_pse_DY, pval_pse_DY, ll95_pse_DY, ul95_pse_DY \ ///
			pse_DM3Y, se_pse_DM3Y, pval_pse_DM3Y, ll95_pse_DM3Y, ul95_pse_DM3Y \ ///
			pse_DM2Y, se_pse_DM2Y, pval_pse_DM2Y, ll95_pse_DM2Y, ul95_pse_DM2Y \ ///
			pse_DM1Y, se_pse_DM1Y, pval_pse_DM1Y, ll95_pse_DM1Y, ul95_pse_DM1Y)
	
		matrix rownames results = "ATE" "PSE_DY" "PSE_DM3Y" "PSE_DM2Y" "PSE_DM1Y"
		matrix colnames results = "Est." "Std. Err." "P>|z|" "[95% Conf." "Interval]"
		
		capture drop eifATE_r001_1 eifNDE_r001_1 eifNIE_r001_1		
		
	}


	if (`num_mvars' == 4) {

		dmlmne `yvar' `mvar1' `mvar2' `mvar3' `mvar4' if `touse', ///
			model(`model') xfits(`xfits') seed(`seed') ///
			dvar(`dvar') d(`d') dstar(`dstar') cvars(`cvars') censor(`censor') `options'
		
		tempvar mnde_M1M2M3M4
		qui gen `mnde_M1M2M3M4' = eifNDE_r001_4 if `touse'
		
		capture drop eifATE_r001_4 eifNDE_r001_4 eifNIE_r001_4
		
		dmlmne `yvar' `mvar1' `mvar2' `mvar3' if `touse', ///
			model(`model') xfits(`xfits') seed(`seed') ///
			dvar(`dvar') d(`d') dstar(`dstar') cvars(`cvars') censor(`censor') `options'
		
		tempvar mnde_M1M2M3 diff_mnde_M1M2M3_mnde_M1M2M3M4
		qui gen `mnde_M1M2M3' = eifNDE_r001_3 if `touse'
		qui gen `diff_mnde_M1M2M3_mnde_M1M2M3M4' = `mnde_M1M2M3' - `mnde_M1M2M3M4' if `touse'
		
		capture drop eifATE_r001_3 eifNDE_r001_3 eifNIE_r001_3
		
		dmlmne `yvar' `mvar1' `mvar2' if `touse', ///
			model(`model') xfits(`xfits') seed(`seed') ///
			dvar(`dvar') d(`d') dstar(`dstar') cvars(`cvars') censor(`censor') `options'
		
		tempvar mnde_M1M2 diff_mnde_M1M2_mnde_M1M2M3
		qui gen `mnde_M1M2' = eifNDE_r001_2 if `touse'
		qui gen `diff_mnde_M1M2_mnde_M1M2M3' = `mnde_M1M2' - `mnde_M1M2M3' if `touse'
		
		capture drop eifATE_r001_2 eifNDE_r001_2 eifNIE_r001_2

		dmlmne `yvar' `mvar1' if `touse', ///
			model(`model') xfits(`xfits') seed(`seed') ///
			dvar(`dvar') d(`d') dstar(`dstar') cvars(`cvars') censor(`censor') `options'
		
		tempvar mnde_M1 diff_mnde_M1_mnde_M1M2
		qui gen `mnde_M1' = eifNDE_r001_1 if `touse'
		qui gen `diff_mnde_M1_mnde_M1M2' = `mnde_M1' - `mnde_M1M2' if `touse'
		
		qui mean `mnde_M1M2M3M4' `diff_mnde_M1M2M3_mnde_M1M2M3M4' `diff_mnde_M1M2_mnde_M1M2M3' `diff_mnde_M1_mnde_M1M2' eifNIE_r001_1 eifATE_r001_1 if `touse'
		
		scalar pse_DY = _b[`mnde_M1M2M3M4']
		scalar pse_DM4Y = _b[`diff_mnde_M1M2M3_mnde_M1M2M3M4']
		scalar pse_DM3Y = _b[`diff_mnde_M1M2_mnde_M1M2M3']
		scalar pse_DM2Y = _b[`diff_mnde_M1_mnde_M1M2']
		scalar pse_DM1Y = _b[eifNIE_r001_1]
		scalar ate = _b[eifATE_r001_1]
	
		scalar se_pse_DY = _se[`mnde_M1M2M3M4']
		scalar se_pse_DM4Y = _se[`diff_mnde_M1M2M3_mnde_M1M2M3M4']
		scalar se_pse_DM3Y = _se[`diff_mnde_M1M2_mnde_M1M2M3']
		scalar se_pse_DM2Y = _se[`diff_mnde_M1_mnde_M1M2']
		scalar se_pse_DM1Y = _se[eifNIE_r001_1]
		scalar se_ate = _se[eifATE_r001_1]
	
		scalar ll95_pse_DY = _b[`mnde_M1M2M3M4']-1.96*_se[`mnde_M1M2M3M4']
		scalar ll95_pse_DM4Y = _b[`diff_mnde_M1M2M3_mnde_M1M2M3M4']-1.96*_se[`diff_mnde_M1M2M3_mnde_M1M2M3M4']
		scalar ll95_pse_DM3Y = _b[`diff_mnde_M1M2_mnde_M1M2M3']-1.96*_se[`diff_mnde_M1M2_mnde_M1M2M3']
		scalar ll95_pse_DM2Y = _b[`diff_mnde_M1_mnde_M1M2']-1.96*_se[`diff_mnde_M1_mnde_M1M2']
		scalar ll95_pse_DM1Y = _b[eifNIE_r001_1]-1.96*_se[eifNIE_r001_1]
		scalar ll95_ate = _b[eifATE_r001_1]-1.96*_se[eifATE_r001_1]

		scalar ul95_pse_DY = _b[`mnde_M1M2M3M4']+1.96*_se[`mnde_M1M2M3M4']
		scalar ul95_pse_DM4Y = _b[`diff_mnde_M1M2M3_mnde_M1M2M3M4']+1.96*_se[`diff_mnde_M1M2M3_mnde_M1M2M3M4']
		scalar ul95_pse_DM3Y = _b[`diff_mnde_M1M2_mnde_M1M2M3']+1.96*_se[`diff_mnde_M1M2_mnde_M1M2M3']
		scalar ul95_pse_DM2Y = _b[`diff_mnde_M1_mnde_M1M2']+1.96*_se[`diff_mnde_M1_mnde_M1M2']
		scalar ul95_pse_DM1Y = _b[eifNIE_r001_1]+1.96*_se[eifNIE_r001_1]
		scalar ul95_ate = _b[eifATE_r001_1]+1.96*_se[eifATE_r001_1]

		scalar pval_pse_DY = (1-normal(abs(_b[`mnde_M1M2M3M4']/_se[`mnde_M1M2M3M4'])))*2
		scalar pval_pse_DM4Y = (1-normal(abs(_b[`diff_mnde_M1M2M3_mnde_M1M2M3M4']/_se[`diff_mnde_M1M2M3_mnde_M1M2M3M4'])))*2
		scalar pval_pse_DM3Y = (1-normal(abs(_b[`diff_mnde_M1M2_mnde_M1M2M3']/_se[`diff_mnde_M1M2_mnde_M1M2M3'])))*2
		scalar pval_pse_DM2Y = (1-normal(abs(_b[`diff_mnde_M1_mnde_M1M2']/_se[`diff_mnde_M1_mnde_M1M2'])))*2
		scalar pval_pse_DM1Y = (1-normal(abs(_b[eifNIE_r001_1]/_se[eifNIE_r001_1])))*2
		scalar pval_ate = (1-normal(abs(_b[eifATE_r001_1]/_se[eifATE_r001_1])))*2

		matrix results = ///
			(ate, se_ate, pval_ate, ll95_ate, ul95_ate \ ///
			pse_DY, se_pse_DY, pval_pse_DY, ll95_pse_DY, ul95_pse_DY \ ///
			pse_DM4Y, se_pse_DM4Y, pval_pse_DM4Y, ll95_pse_DM4Y, ul95_pse_DM4Y \ ///
			pse_DM3Y, se_pse_DM3Y, pval_pse_DM3Y, ll95_pse_DM3Y, ul95_pse_DM3Y \ ///
			pse_DM2Y, se_pse_DM2Y, pval_pse_DM2Y, ll95_pse_DM2Y, ul95_pse_DM2Y \ ///
			pse_DM1Y, se_pse_DM1Y, pval_pse_DM1Y, ll95_pse_DM1Y, ul95_pse_DM1Y)
	
		matrix rownames results = "ATE" "PSE_DY" "PSE_DM4Y" "PSE_DM3Y" "PSE_DM2Y" "PSE_DM1Y"
		matrix colnames results = "Est." "Std. Err." "P>|z|" "[95% Conf." "Interval]"
		
		capture drop eifATE_r001_1 eifNDE_r001_1 eifNIE_r001_1		
		
	}
	
	if (`num_mvars' == 5) {

		dmlmne `yvar' `mvar1' `mvar2' `mvar3' `mvar4' `mvar5' if `touse', ///
			model(`model') xfits(`xfits') seed(`seed') ///
			dvar(`dvar') d(`d') dstar(`dstar') cvars(`cvars') censor(`censor') `options'
		
		tempvar mnde_M1M2M3M4M5
		qui gen `mnde_M1M2M3M4M5' = eifNDE_r001_5 if `touse'
		
		capture drop eifATE_r001_5 eifNDE_r001_5 eifNIE_r001_5
		
		dmlmne `yvar' `mvar1' `mvar2' `mvar3' `mvar4' if `touse', ///
			model(`model') xfits(`xfits') seed(`seed') ///
			dvar(`dvar') d(`d') dstar(`dstar') cvars(`cvars') censor(`censor') `options'
		
		tempvar mnde_M1M2M3M4 diff_M1M2M3M4_M1M2M3M4M5
		qui gen `mnde_M1M2M3M4' = eifNDE_r001_4 if `touse'
		qui gen `diff_M1M2M3M4_M1M2M3M4M5' = `mnde_M1M2M3M4' - `mnde_M1M2M3M4M5' if `touse'
		
		capture drop eifATE_r001_4 eifNDE_r001_4 eifNIE_r001_4
		
		dmlmne `yvar' `mvar1' `mvar2' `mvar3' if `touse', ///
			model(`model') xfits(`xfits') seed(`seed') ///
			dvar(`dvar') d(`d') dstar(`dstar') cvars(`cvars') censor(`censor') `options'
		
		tempvar mnde_M1M2M3 diff_mnde_M1M2M3_mnde_M1M2M3M4
		qui gen `mnde_M1M2M3' = eifNDE_r001_3 if `touse'
		qui gen `diff_mnde_M1M2M3_mnde_M1M2M3M4' = `mnde_M1M2M3' - `mnde_M1M2M3M4' if `touse'
		
		capture drop eifATE_r001_3 eifNDE_r001_3 eifNIE_r001_3
		
		dmlmne `yvar' `mvar1' `mvar2' if `touse', ///
			model(`model') xfits(`xfits') seed(`seed') ///
			dvar(`dvar') d(`d') dstar(`dstar') cvars(`cvars') censor(`censor') `options'
		
		tempvar mnde_M1M2 diff_mnde_M1M2_mnde_M1M2M3
		qui gen `mnde_M1M2' = eifNDE_r001_2 if `touse'
		qui gen `diff_mnde_M1M2_mnde_M1M2M3' = `mnde_M1M2' - `mnde_M1M2M3' if `touse'
		
		capture drop eifATE_r001_2 eifNDE_r001_2 eifNIE_r001_2

		dmlmne `yvar' `mvar1' if `touse', ///
			model(`model') xfits(`xfits') seed(`seed') ///
			dvar(`dvar') d(`d') dstar(`dstar') cvars(`cvars') censor(`censor') `options'
		
		tempvar mnde_M1 diff_mnde_M1_mnde_M1M2
		qui gen `mnde_M1' = eifNDE_r001_1 if `touse'
		qui gen `diff_mnde_M1_mnde_M1M2' = `mnde_M1' - `mnde_M1M2' if `touse'
		
		qui mean `mnde_M1M2M3M4M5' `diff_M1M2M3M4_M1M2M3M4M5' `diff_mnde_M1M2M3_mnde_M1M2M3M4' `diff_mnde_M1M2_mnde_M1M2M3' `diff_mnde_M1_mnde_M1M2' eifNIE_r001_1 eifATE_r001_1 if `touse'
		
		scalar pse_DY = _b[`mnde_M1M2M3M4M5']
		scalar pse_DM5Y = _b[`diff_M1M2M3M4_M1M2M3M4M5']
		scalar pse_DM4Y = _b[`diff_mnde_M1M2M3_mnde_M1M2M3M4']
		scalar pse_DM3Y = _b[`diff_mnde_M1M2_mnde_M1M2M3']
		scalar pse_DM2Y = _b[`diff_mnde_M1_mnde_M1M2']
		scalar pse_DM1Y = _b[eifNIE_r001_1]
		scalar ate = _b[eifATE_r001_1]
	
		scalar se_pse_DY = _se[`mnde_M1M2M3M4M5']
		scalar se_pse_DM5Y = _se[`diff_M1M2M3M4_M1M2M3M4M5']
		scalar se_pse_DM4Y = _se[`diff_mnde_M1M2M3_mnde_M1M2M3M4']
		scalar se_pse_DM3Y = _se[`diff_mnde_M1M2_mnde_M1M2M3']
		scalar se_pse_DM2Y = _se[`diff_mnde_M1_mnde_M1M2']
		scalar se_pse_DM1Y = _se[eifNIE_r001_1]
		scalar se_ate = _se[eifATE_r001_1]
	
		scalar ll95_pse_DY = _b[`mnde_M1M2M3M4M5']-1.96*_se[`mnde_M1M2M3M4M5']
		scalar ll95_pse_DM5Y = _b[`diff_M1M2M3M4_M1M2M3M4M5']-1.96*_se[`diff_M1M2M3M4_M1M2M3M4M5']
		scalar ll95_pse_DM4Y = _b[`diff_mnde_M1M2M3_mnde_M1M2M3M4']-1.96*_se[`diff_mnde_M1M2M3_mnde_M1M2M3M4']
		scalar ll95_pse_DM3Y = _b[`diff_mnde_M1M2_mnde_M1M2M3']-1.96*_se[`diff_mnde_M1M2_mnde_M1M2M3']
		scalar ll95_pse_DM2Y = _b[`diff_mnde_M1_mnde_M1M2']-1.96*_se[`diff_mnde_M1_mnde_M1M2']
		scalar ll95_pse_DM1Y = _b[eifNIE_r001_1]-1.96*_se[eifNIE_r001_1]
		scalar ll95_ate = _b[eifATE_r001_1]-1.96*_se[eifATE_r001_1]

		scalar ul95_pse_DY = _b[`mnde_M1M2M3M4M5']+1.96*_se[`mnde_M1M2M3M4M5']
		scalar ul95_pse_DM5Y = _b[`diff_M1M2M3M4_M1M2M3M4M5']+1.96*_se[`diff_M1M2M3M4_M1M2M3M4M5']
		scalar ul95_pse_DM4Y = _b[`diff_mnde_M1M2M3_mnde_M1M2M3M4']+1.96*_se[`diff_mnde_M1M2M3_mnde_M1M2M3M4']
		scalar ul95_pse_DM3Y = _b[`diff_mnde_M1M2_mnde_M1M2M3']+1.96*_se[`diff_mnde_M1M2_mnde_M1M2M3']
		scalar ul95_pse_DM2Y = _b[`diff_mnde_M1_mnde_M1M2']+1.96*_se[`diff_mnde_M1_mnde_M1M2']
		scalar ul95_pse_DM1Y = _b[eifNIE_r001_1]+1.96*_se[eifNIE_r001_1]
		scalar ul95_ate = _b[eifATE_r001_1]+1.96*_se[eifATE_r001_1]

		scalar pval_pse_DY = (1-normal(abs(_b[`mnde_M1M2M3M4M5']/_se[`mnde_M1M2M3M4M5'])))*2
		scalar pval_pse_DM5Y = (1-normal(abs(_b[`diff_M1M2M3M4_M1M2M3M4M5']/_se[`diff_M1M2M3M4_M1M2M3M4M5'])))*2
		scalar pval_pse_DM4Y = (1-normal(abs(_b[`diff_mnde_M1M2M3_mnde_M1M2M3M4']/_se[`diff_mnde_M1M2M3_mnde_M1M2M3M4'])))*2
		scalar pval_pse_DM3Y = (1-normal(abs(_b[`diff_mnde_M1M2_mnde_M1M2M3']/_se[`diff_mnde_M1M2_mnde_M1M2M3'])))*2
		scalar pval_pse_DM2Y = (1-normal(abs(_b[`diff_mnde_M1_mnde_M1M2']/_se[`diff_mnde_M1_mnde_M1M2'])))*2
		scalar pval_pse_DM1Y = (1-normal(abs(_b[eifNIE_r001_1]/_se[eifNIE_r001_1])))*2
		scalar pval_ate = (1-normal(abs(_b[eifATE_r001_1]/_se[eifATE_r001_1])))*2

		matrix results = ///
			(ate, se_ate, pval_ate, ll95_ate, ul95_ate \ ///
			pse_DY, se_pse_DY, pval_pse_DY, ll95_pse_DY, ul95_pse_DY \ ///
			pse_DM5Y, se_pse_DM5Y, pval_pse_DM5Y, ll95_pse_DM5Y, ul95_pse_DM5Y \ ///
			pse_DM4Y, se_pse_DM4Y, pval_pse_DM4Y, ll95_pse_DM4Y, ul95_pse_DM4Y \ ///
			pse_DM3Y, se_pse_DM3Y, pval_pse_DM3Y, ll95_pse_DM3Y, ul95_pse_DM3Y \ ///
			pse_DM2Y, se_pse_DM2Y, pval_pse_DM2Y, ll95_pse_DM2Y, ul95_pse_DM2Y \ ///
			pse_DM1Y, se_pse_DM1Y, pval_pse_DM1Y, ll95_pse_DM1Y, ul95_pse_DM1Y)
	
		matrix rownames results = "ATE" "PSE_DY" "PSE_DM5Y" "PSE_DM4Y" "PSE_DM3Y" "PSE_DM2Y" "PSE_DM1Y"
		matrix colnames results = "Est." "Std. Err." "P>|z|" "[95% Conf." "Interval]"
		
		capture drop eifATE_r001_1 eifNDE_r001_1 eifNIE_r001_1		

	}

	matrix list results

end dmlpath
