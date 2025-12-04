*!TITLE: VENTSIM - analysis of interventional effects using a simulation estimator
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.3 -- added support for parallelization
*!

program define ventsim, eclass

	version 15	

	syntax varlist(min=1 max=1 numeric) [if][in] [pweight], ///
		dvar(varname numeric) ///
		mvar(varname numeric) ///
		lvars(varlist numeric) ///
		d(real) ///
		dstar(real) ///
		mreg(string) ///
		yreg(string) ///
		lregs(string) ///
		[nsim(integer 200) ///
		cvars(varlist numeric) ///
		NOINTERaction ///
		cxd ///
		cxm ///
		lxm ///
		parallel ///			
		detail * ]
		
	qui {
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000
	}
	
	if ("`detail'" != "") {		
		
		ventsimbs `varlist' [`weight' `exp'] if `touse' , ///
			dvar(`dvar') mvar(`mvar') lvars(`lvars') cvars(`cvars') ///
			d(`d') dstar(`dstar') mreg(`mreg') yreg(`yreg') lregs(`lregs') /// 
			nsim(1) `nointeraction' `cxd' `cxm' `lxm'
			
	}
		
	if ("`parallel'" == "") {		
		
		bootstrap ///
			OE=r(oe) ///
			IDE=r(ide) ///
			IIE=r(iie), ///
				`options' force noheader notable: ///
					ventsimbs `varlist' if `touse' [`weight' `exp'], ///
						dvar(`dvar') mvar(`mvar') lvars(`lvars') cvars(`cvars') ///
						d(`d') dstar(`dstar') mreg(`mreg') yreg(`yreg') lregs(`lregs') ///
						nsim(`nsim') `nointeraction' `cxd' `cxm' `lxm'

		estat bootstrap, p noheader
	
	}

	if ("`parallel'" != "") {		
	
		di ""
		di "{bf:Parallel Bootstrapping with Stata}"
		
		parallel initialize
		
		di "{it:Waiting for the child processes to finish...}"
		di ""
		
		qui parallel bs, expr(OE=r(oe) IDE=r(ide) IIE=r(iie)) `options' : ///
			ventsimbs `varlist' if `touse' [`weight' `exp'], ///
				dvar(`dvar') mvar(`mvar') lvars(`lvars') cvars(`cvars') ///
				d(`d') dstar(`dstar') mreg(`mreg') yreg(`yreg') lregs(`lregs') ///
				nsim(`nsim') `nointeraction' `cxd' `cxm' `lxm'
	
		estat bootstrap, p noheader
		
		capture parallel clean, all

	}		
	
end ventsim
