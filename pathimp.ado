*!TITLE: PATHIMP - path-specific effects using pure regression imputation
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.2 - added parallelization 
*!


program define pathimp, eclass

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
		detail *]
		
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
	
	local yregtypes regress logit
	local nyreg : list posof "`yreg'" in yregtypes
	if !`nyreg' {
		display as error "Error: yreg must be chosen from: `yregtypes'."
		error 198		
	}
	else {
		local mreg : word `nyreg' of `yregtypes'
	}

	/***PRINT MODELS***/
	if ("`detail'" != "") {
	
		if ("`cxd'"!="") {	
			foreach c in `cvars' {
				tempvar dX`c'_dis
				qui gen `dX`c'_dis' = `dvar' * `c' if `touse'
				local cxd_vars_dis `cxd_vars_dis' `dX`c'_dis'
			}
		}
		
		di ""
		di "{bf:Model for `yvar' given {cvars `dvar'}:}"
		if ("`yreg'"=="regress") {
			reg `yvar' `dvar' `cvars' `cxd_vars_dis' [`weight' `exp'] if `touse'
		}

		if ("`yreg'"=="logit") {
			glm `yvar' `dvar' `cvars' `cxd_vars_dis' [`weight' `exp'] if `touse', family(b) link(l)
		}
		
		pathimpbs `yvar' `mvars' [`weight' `exp'] if `touse', ///
			dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
			d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction'
	}
		
	local effects ATE = r(ate)
	if (`num_mvars' == 1) local effects `effects' NDE = r(nde) NIE = r(nie)
	if (`num_mvars' > 1) {
		local effects `effects' PSE_DY = r(pse_DY)
		forv k=`num_mvars'(-1)1 {
			local effects `effects' PSE_DM`k'Y = r(pse_DM`k'Y)
		}
	}

	if ("`parallel'" == "") {		
		
		bootstrap `effects', `options' force noheader notable: ///
			pathimpbs `yvar' `mvars' [`weight' `exp'] if `touse', ///
				dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
				d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction'
	
		estat bootstrap, p noheader
	
	}

	if ("`parallel'" != "") {		
	
		di ""
		di "{bf:Parallel Bootstrapping with Stata}"
		
		parallel initialize
		
		di "{it:Waiting for the child processes to finish...}"
		di ""
		
		qui parallel bs, expr(`effects') `options' : ///
			pathimpbs `yvar' `mvars' [`weight' `exp'] if `touse', ///
				dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
				d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction'
	
		estat bootstrap, p noheader
		
		capture parallel clean, all

	}

end pathimp
