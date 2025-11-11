*!TITLE: WIMPMED - causal mediation analysis using an imputation-based weighting estimator
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1 
*!

program define wimpmed, eclass

	version 15	
	
	syntax varlist(min=2 numeric) [if][in], ///
		dvar(varname numeric) ///
		d(real) ///
		dstar(real) ///
		yreg(string) ///
		[cvars(varlist numeric) ///
		NOINTERaction ///
		cxd ///
		cxm ///
		sampwts(varname numeric) ///
		censor(numlist min=2 max=2) ///
		detail * ]

	qui {
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000
	}
	
	gettoken yvar mvars : varlist
	
	local num_mvars = wordcount("`mvars'")

	confirm variable `dvar'
	qui levelsof `dvar', local(levels)
	if "`levels'" != "0 1" & "`levels'" != "1 0" {
		display as error "The variable `dvar' is not binary and coded 0/1"
		error 198
	}
	
	if ("`yreg'"=="logit") {
		confirm variable `yvar'
		qui levelsof `yvar', local(levels)
		if "`levels'" != "0 1" & "`levels'" != "1 0" {
			display as error "The outcome variable `yvar' is not binary and coded 0/1"
			error 198
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
	
	/***REPORT MODELS AND SAVE WEIGHTS IF REQUESTED***/
	if ("`detail'" != "") {
		wimpmedbs `yvar' `mvars' if `touse', ///
			dvar(`dvar') cvars(`cvars') yreg(`yreg') sampwts(`sampwts') ///
			d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction' censor(`censor') `detail'
	}
	
	/***COMPUTE POINT AND INTERVAL ESTIMATES FOR NDE/NIE***/
	if (`num_mvars'==1) {
	
		bootstrap ///
			ATE = (r(YdMd) - r(YdstarMdstar)) ///
			NDE = (r(YdMdstar) - r(YdstarMdstar)) ///
			NIE = (r(YdMd) - r(YdMdstar)), ///
				`options' noheader notable: ///
					wimpmedbs `yvar' `mvars' if `touse', ///
						dvar(`dvar') cvars(`cvars') yreg(`yreg') sampwts(`sampwts') ///
						d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction' censor(`censor')

	}
	
	if (`num_mvars'>1) {
	
		bootstrap ///
			ATE = (r(YdMd) - r(YdstarMdstar)) ///
			MNDE = (r(YdMdstar) - r(YdstarMdstar)) ///
			MNIE = (r(YdMd) - r(YdMdstar)), ///
				`options' noheader notable: ///
					wimpmedbs `yvar' `mvars' if `touse', ///
						dvar(`dvar') cvars(`cvars') yreg(`yreg') sampwts(`sampwts') ///
						d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction' censor(`censor')
	}
		
	estat bootstrap, p noheader
	
end wimpmed
