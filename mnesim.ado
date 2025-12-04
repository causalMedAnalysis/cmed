*!TITLE: MNESIM - analysis of multivariate natural effects using a simulation approach
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.2 - added parallelization 
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
		parallel ///			
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

	if ("`parallel'" == "") {		
		
		bootstrap ///
			ATE=r(ate) ///
			MNDE=r(mnde) ///
			MNIE=r(mnie), ///
				`options' force noheader notable: ///
					mnesimbs `varlist' if `touse' [`weight' `exp'], ///
						dvar(`dvar') mvars(`mvars') cvars(`cvars') ///
						d(`d') dstar(`dstar') mregs(`mregs') yreg(`yreg') ///
						nsim(`nsim') `nointeraction' `cxd' `cxm'

		estat bootstrap, p noheader
		
	}

	if ("`parallel'" != "") {		
	
		di ""
		di "{bf:Parallel Bootstrapping with Stata}"
		
		parallel initialize
		
		di "{it:Waiting for the child processes to finish...}"
		di ""
		
		qui parallel bs, expr(ATE=r(ate) MNDE=r(mnde) MNIE=r(mnie)) `options' : ///
			mnesimbs `varlist' if `touse' [`weight' `exp'], ///
				dvar(`dvar') mvars(`mvars') cvars(`cvars') ///
				d(`d') dstar(`dstar') mregs(`mregs') yreg(`yreg') ///
				nsim(`nsim') `nointeraction' `cxd' `cxm'
	
		estat bootstrap, p noheader
		
		capture parallel clean, all

	}
	
end mnesim
