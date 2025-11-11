*!TITLE: DMLMED - causal mediation analysis using de-biased machine learning
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1 
*!


program define dmlmed, eclass

	version 15	

	syntax varlist(min=2 numeric) [if][in], ///
		type(string) ///
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
	}

	gettoken yvar mvars : varlist
	
	local num_mvars = wordcount("`mvars'")
	
	local mrtypes mr1 mr2
	local nmrtype : list posof "`type'" in mrtypes
	if !`nmrtype' {
		display as error "Error: type must be chosen from: `mrtypes'."
		error 198		
	}

	local modeltypes rforest lasso
	local nmodeltype : list posof "`model'" in modeltypes
	if !`nmodeltype' {
		display as error "Error: model must be chosen from: `modeltypes'."
		error 198		
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
	
	if ("`type'"=="mr1" & "`model'"=="rforest") {
	
		capture which rforest
		if _rc {
			display as error "{p 0 0 5 0} A required package is not installed."
			display as error "This module depends on rforest."
			display as error "Install using -ssc install rforest-"
			exit 198
		}
	
		if (`num_mvars' > 1) {
			display as error "type(mr1) robust estimation only supports a single mediator"
			display as error "but `num_mvars' mediators --`mvars' -- have been specified."
			error 198
		}
	
		foreach i in `dvar' `mvars' {
			confirm variable `i'
			qui levelsof `i', local(levels)
			if "`levels'" != "0 1" & "`levels'" != "1 0" {
				display as error "The variable `i' is not binary and coded 0/1"
				error 198
			}
		}

		mr1forest `yvar' if `touse', ///
			dvar(`dvar') mvar(`mvars') d(`d') dstar(`dstar') ///
			cvars(`cvars') xfits(`xfits') seed(`seed') censor(`censor') `options'
			
	}

	if ("`type'"=="mr1" & "`model'"=="lasso") {
	
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
		
		if (`num_mvars' > 1) {
			display as error "type(mr1) robust estimation only supports a single mediator"
			display as error "but `num_mvars' mediators --`mvars' -- have been specified."
			error 198
		}
	
		foreach i in `dvar' `mvars' {
			confirm variable `i'
			qui levelsof `i', local(levels)
			if "`levels'" != "0 1" & "`levels'" != "1 0" {
				display as error "The variable `i' is not binary and coded 0/1"
				error 198
			}
		}

		mr1lasso `yvar' if `touse', ///
			dvar(`dvar') mvar(`mvars') d(`d') dstar(`dstar') ///
			cvars(`cvars') xfits(`xfits') seed(`seed') censor(`censor') `options'
			
	}
	
	if ("`type'"=="mr2" & "`model'"=="rforest") {

		capture which rforest
		if _rc {
			display as error "{p 0 0 5 0} A required package is not installed."
			display as error "This module depends on rforest."
			display as error "Install using -ssc install rforest-"
			exit 198
		}
		
		confirm variable `dvar'
		qui levelsof `dvar', local(levels)
		if "`levels'" != "0 1" & "`levels'" != "1 0" {
			display as error "The variable `dvar' is not binary and coded 0/1"
			error 198
		}
		
		mr2forest `yvar' `mvars' if `touse', ///
			dvar(`dvar') d(`d') dstar(`dstar') cvars(`cvars') ///
			xfits(`xfits') seed(`seed') censor(`censor') `options'
				
	}

	if ("`type'"=="mr2" & "`model'"=="lasso") {

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
		
		confirm variable `dvar'
		qui levelsof `dvar', local(levels)
		if "`levels'" != "0 1" & "`levels'" != "1 0" {
			display as error "The variable `dvar' is not binary and coded 0/1"
			error 198
		}
		
		mr2lasso `yvar' `mvars' if `touse', ///
			dvar(`dvar') d(`d') dstar(`dstar') cvars(`cvars') ///
			xfits(`xfits') seed(`seed') censor(`censor') `options'
				
	}
	
	matrix results = ///
		(r(ate), r(se_ate), r(pval_ate), r(ll95_ate), r(ul95_ate) \ ///
		r(nde), r(se_nde), r(pval_nde), r(ll95_nde), r(ul95_nde) \ ///
		r(nie), r(se_nie), r(pval_nie), r(ll95_nie), r(ul95_nie))
	
	if (`num_mvars'==1) {
		matrix rownames results = "ATE" "NDE" "NIE"
	}

	if (`num_mvars'>=2) {
		matrix rownames results = "ATE" "MNDE" "MNIE"
	}
	
	matrix colnames results = "Est." "Std. Err." "P>|z|" "[95% Conf." "Interval]"

	matrix list results
		
end dmlmed
