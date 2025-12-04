*!TITLE: IMPMED - causal mediation analysis using regression imputation
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.2 - added parallelization 
*!

program define impmed, eclass

	version 15	
	
	syntax varlist(min=2 numeric) [if][in] [pweight], ///
		dvar(varname numeric) ///
		d(real) ///
		dstar(real) ///
		yreg(string) ///
		[cvars(varlist numeric) ///
		NOINTERaction ///
		cxd ///
		cxm ///
		parallel ///
		detail * ]

	qui {
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000
	}
	
	gettoken yvar mvars : varlist
	
	local num_mvars = wordcount("`mvars'")
	
	if ("`yreg'"=="logit") {
	
		confirm variable `yvar'
		qui levelsof `yvar', local(levels)
		if "`levels'" != "0 1" & "`levels'" != "1 0" {
			display as error "The outcome variable `yvar' is not binary and coded 0/1"
			error 198
		}
	
	}

	/***REPORT MODELS IF REQUESTED***/
	if ("`detail'" != "") {
		
		impmedbs `yvar' `mvars' [`weight' `exp'] if `touse', ///
			dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
			d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction'
	
	}
	
	/***COMPUTE POINT AND INTERVAL ESTIMATES FOR NDE/NIE***/
	
	if ("`parallel'" == "") {		
		
		if (`num_mvars'==1) {
	
			bootstrap ///
				ATE=r(ate) ///
				NDE=r(nde) ///
				NIE=r(nie), ///
					`options' force noheader notable: ///
						impmedbs `yvar' `mvars' [`weight' `exp'] if `touse', ///
							dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
							d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction'

		}
	
		if (`num_mvars'>1) {
	
			bootstrap ///
				ATE=r(ate) ///
				MNDE=r(nde) ///
				MNIE=r(nie), ///
					`options' force noheader notable: ///
						impmedbs `yvar' `mvars' [`weight' `exp'] if `touse', ///
							dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
							d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction'

		}
		
		estat bootstrap, p noheader
	}

	if ("`parallel'" != "") {		
		
		di ""
		di "{bf:Parallel Bootstrapping with Stata}"
		
		parallel initialize
		
		di "{it:Waiting for the child processes to finish...}"
		di ""
		
		if (`num_mvars'==1) {

			qui parallel bs, expr(ATE=r(ate) NDE=r(nde) NIE=r(nie)) `options' : ///
				impmedbs `yvar' `mvars' [`weight' `exp'] if `touse', ///
					dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
					d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction'
							
		}
	
		if (`num_mvars'>1) {
	
			qui parallel bs, expr(ATE=r(ate) MNDE=r(nde) MNIE=r(nie)) `options' : ///
				impmedbs `yvar' `mvars' [`weight' `exp'] if `touse', ///
					dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
					d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction'

		}
		
		estat bootstrap, p noheader
		
		capture parallel clean, all
		
	}
	
end impmed
