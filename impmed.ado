*!TITLE: IMPMED - causal mediation analysis using regression imputation
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.2 - added parallelization 
*!

program define impmed, eclass

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
		parallel ///
		svy ///
		detail * ]

	qui {
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000
	}
	
	gettoken yvar mvars : varlist
	
	if ("`yreg'"=="logit") {
	
		confirm variable `yvar'
		qui levelsof `yvar', local(levels)
		if "`levels'" != "0 1" & "`levels'" != "1 0" {
			display as error "The outcome variable `yvar' is not binary and coded 0/1"
			error 198
		}
	
	}

	if ("`detail'" != "") {

		if ("`svy'" == "svy") {
			qui svyset
			local svywgt = r(wtype)
			local wgtexp = r(wexp)
		}
		else {
			local svywgt
			local wgtexp
		}
		
		impmedbs `yvar' `mvars' [`svywgt' `wgtexp'] if `touse', ///
			dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
			d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction'
	
	}
	
	if ("`parallel'" == "") {		
		
		bootstrap, `options' `svy' noheader notable : ///
			impmedbs `yvar' `mvars' if `touse', ///
				dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
				d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction'

		if (e(prefix) == "svy") {
			bstat, noheader
		} 
		else {
			estat bootstrap, p noheader
		}
		
	}

	if ("`parallel'" != "") {		
		
		di ""
		di "{bf:Parallel Bootstrapping with Stata}"
		
		parallel initialize
		
		di "{it:Waiting for the child processes to finish...}"
		di ""
		
		qui parallel bs, `options' `svy' : ///
			impmedbs `yvar' `mvars' if `touse', ///
				dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
				d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction'
							
		estat bootstrap, p noheader
		
		capture parallel clean, all
		
	}
	
end impmed
