*!TITLE: MEDSIM - causal mediation analysis using a simulation estimator
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1
*!

program define medsim, eclass

	version 15	

	syntax varlist(min=1 max=1 numeric) [if][in] [pweight], ///
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
		detail * ]
		
	qui {
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000
	}

	local yregtypes regress logit poisson
	local nyreg : list posof "`yreg'" in yregtypes
	if !`nyreg' {
		display as error "Error: yreg must be chosen from: `yregtypes'."
		error 198		
		}

	local mregtypes regress logit poisson
	local nmreg : list posof "`mreg'" in mregtypes
	if !`nmreg' {
		display as error "Error: mreg must be chosen from: `mregtypes'."
		error 198		
		}
		
	if ("`detail'" != "") {		
		medsimbs `varlist' [`weight' `exp'] if `touse' , ///
			dvar(`dvar') mvar(`mvar') cvars(`cvars') ///
			d(`d') dstar(`dstar') mreg(`mreg') yreg(`yreg') nsim(1) /// 
			`nointeraction' `cxd' `cxm'
	}
		
	bootstrap ///
		ATE=r(ate) ///
		NDE=r(nde) ///
		NIE=r(nie), ///
			force `options' noheader notable: ///
				medsimbs `varlist' if `touse' [`weight' `exp'], ///
					dvar(`dvar') mvar(`mvar') cvars(`cvars') ///
					d(`d') dstar(`dstar') mreg(`mreg') yreg(`yreg') nsim(`nsim') ///
					`nointeraction' `cxd' `cxm'

	estat bootstrap, p noheader
	
end medsim
