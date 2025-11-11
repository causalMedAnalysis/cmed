*!TITLE: SIMCDE - estimate controlled direct effects using a simulation estimator
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1
*!

program define simcde, eclass

	version 15	

	syntax varlist(min=1 max=1 numeric) [if][in] [pweight], ///
		dvar(varname numeric) ///
		mvar(varname numeric) ///
		lvars(varlist numeric) ///
		d(real) ///
		dstar(real) ///
		m(real) ///
		yreg(string) ///
		lregs(string) ///
		[nsim(integer 200) ///
		cvars(varlist numeric) ///
		NOINTERaction ///
		cxd ///
		cxm ///
		lxm ///
		detail * ]
		
	qui {
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000
	}
	
	if ("`detail'" != "") {		
		simcdebs `varlist' [`weight' `exp'] if `touse' , ///
			dvar(`dvar') mvar(`mvar') lvars(`lvars') cvars(`cvars') ///
			d(`d') dstar(`dstar') m(`m') ///
			yreg(`yreg') lregs(`lregs') /// 
			nsim(1) `nointeraction' `cxd' `cxm' `lxm'
	}
		
	bootstrap ///
		CDE=r(cde), ///
			force `options' noheader notable: ///
				simcdebs `varlist' if `touse' [`weight' `exp'], ///
					dvar(`dvar') mvar(`mvar') lvars(`lvars') cvars(`cvars') ///
					d(`d') dstar(`dstar') m(`m') ///
					yreg(`yreg') lregs(`lregs') ///
					nsim(`nsim') `nointeraction' `cxd' `cxm'

	estat bootstrap, p noheader
	
end simcde
