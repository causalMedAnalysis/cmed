*!TITLE: IPWMED - causal mediation analysis using inverse probability weighting
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1 
*!

program define ipwmed, eclass

	version 15	

	syntax varlist(min=2 numeric) [if][in], ///
		dvar(varname numeric) ///
		d(real) ///
		dstar(real) ///
		[cvars(varlist numeric) ///
		sampwts(varname numeric) ///
		censor(numlist min=2 max=2) ///
		detail * ]

	qui {
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000
	}
	
	gettoken yvar mvars : varlist

	confirm variable `dvar'
	qui levelsof `dvar', local(levels)
	if "`levels'" != "0 1" & "`levels'" != "1 0" {
		display as error "The variable `i' is not binary and coded 0/1"
		error 198
	}
	
	local num_mvars = wordcount("`mvars'")
	
	if ("`detail'" != "") {
		
		local ipw_var_names "sw1_r001 sw2_r001 sw3_r001"
		foreach name of local ipw_var_names {
			capture confirm new variable `name'
			if _rc {
				display as error "{p 0 0 5 0}The command needs to create weight variables"
				display as error "with the following names: `ipw_var_names', "
				display as error "but these variables have already been defined.{p_end}"
				error 110
			}
		}
			
		ipwmedbs `yvar' `mvars' if `touse', dvar(`dvar') d(`d') dstar(`dstar') ///
			cvars(`cvars') sampwts(`sampwts') `detail' censor(`censor')
	
		label var sw1_r001 "IPW for estimating E(Y(d*,M(d*)))"
		label var sw2_r001 "IPW for estimating E(Y(d,M(d)))"
		label var sw3_r001 "IPW for estimating E(Y(d,M(d*)))"
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

	if (`num_mvars'==1) {
	
		bootstrap ///
			ATE=r(ate) ///
			NDE=r(nde) ///
			NIE=r(nie), ///
				`options' noheader notable: ///
					ipwmedbs `yvar' `mvars' if `touse', dvar(`dvar') d(`d') dstar(`dstar') ///
						cvars(`cvars') sampwts(`sampwts') censor(`censor')
	}

	if (`num_mvars'>=2) {
	
		bootstrap ///
			ATE=r(ate) ///
			MNDE=r(nde) ///
			MNIE=r(nie), ///
				`options' noheader notable: ///
					ipwmedbs `yvar' `mvars' if `touse', dvar(`dvar') d(`d') dstar(`dstar') ///
						cvars(`cvars') sampwts(`sampwts') censor(`censor')
	}
	
	estat bootstrap, p noheader
	
end ipwmed
