*!TITLE: MEDSIM - causal mediation analysis using a simulation estimator
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.3 - added svy compatibility
*!

program define medsim, eclass

	version 15	

	syntax varlist(min=1 max=1 numeric) [if][in], ///
		dvar(varname numeric) ///
		mvar(varname numeric) ///
		d(real) ///
		dstar(real) ///
		mreg(string) ///
		yreg(string) ///
		[nsim(integer 200) ///
		cvars(varlist numeric) ///
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

	local yregtypes regress logit ologit poisson
	local nyreg : list posof "`yreg'" in yregtypes
	if !`nyreg' {
		display as error "Error: yreg must be chosen from: `yregtypes'."
		error 198		
	}

	local mregtypes regress logit ologit poisson
	local nmreg : list posof "`mreg'" in mregtypes
	if !`nmreg' {
		display as error "Error: mreg must be chosen from: `mregtypes'."
		error 198		
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
		
		medsimbs `varlist' [`svywgt' `wgtexp'] if `touse' , ///
			dvar(`dvar') mvar(`mvar') cvars(`cvars') ///
			d(`d') dstar(`dstar') mreg(`mreg') yreg(`yreg') nsim(1) /// 
			`nointeraction' `cxd' `cxm'
			
	}

	if ("`parallel'" == "") {		
		
		bootstrap, `options' `svy' noheader notable : ///
			medsimbs `varlist' if `touse', ///
				dvar(`dvar') mvar(`mvar') cvars(`cvars') ///
				d(`d') dstar(`dstar') mreg(`mreg') yreg(`yreg') nsim(`nsim') ///
				`nointeraction' `cxd' `cxm'

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
			medsimbs `varlist' if `touse', ///
				dvar(`dvar') mvar(`mvar') cvars(`cvars') ///
				d(`d') dstar(`dstar') mreg(`mreg') yreg(`yreg') nsim(`nsim') ///
				`nointeraction' `cxd' `cxm'
	
		estat bootstrap, p noheader
		
		capture parallel clean, all

	}
	
end medsim
