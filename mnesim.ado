*!TITLE: MNESIM - analysis of multivariate natural effects using a simulation estimator
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1
*!

program define mnesim, eclass

	version 15	

	syntax varlist(min=1 max=1 numeric) [if][in] [pweight], ///
		dvar(varname numeric) ///
		mvars(varlist numeric) ///
		d(real) ///
		dstar(real) ///
		mregs(string) ///
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
	
	if ("`detail'" != "") {		
		mnesimbs `varlist' [`weight' `exp'] if `touse' , ///
			dvar(`dvar') mvars(`mvars') cvars(`cvars') ///
			d(`d') dstar(`dstar') mregs(`mregs') yreg(`yreg') /// 
			nsim(1) `nointeraction' `cxd' `cxm'
	}
		
	bootstrap ///
		ATE=r(ate) ///
		MNDE=r(mnde) ///
		MNIE=r(mnie), ///
			force `options' noheader notable: ///
				mnesimbs `varlist' if `touse' [`weight' `exp'], ///
					dvar(`dvar') mvars(`mvars') cvars(`cvars') ///
					d(`d') dstar(`dstar') mregs(`mregs') yreg(`yreg') ///
					nsim(`nsim') `nointeraction' `cxd' `cxm'

	estat bootstrap, p noheader
	
end mnesim
