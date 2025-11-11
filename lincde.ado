*!TITLE: LINCDE - estimating controlled direct effects using linear models
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1
*!

program define lincde, eclass

	version 15	

	syntax varlist(min=1 max=1 numeric) [if][in] [pweight], ///
		dvar(varname numeric) ///
		mvar(varname numeric) ///
		d(real) ///
		dstar(real) ///
		m(real) ///
		[cvars(varlist numeric) ///
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
		lincdebs `varlist' [`weight' `exp'] if `touse' , ///
			dvar(`dvar') mvar(`mvar') d(`d') dstar(`dstar') m(`m') ///
			cvars(`cvars') `nointeraction' `cxd' `cxm'
	}
	
	bootstrap ///
		CDE=r(cde), `options' force noheader notable: ///
		lincdebs `varlist' [`weight' `exp'] if `touse', ///
			dvar(`dvar') mvar(`mvar') d(`d') dstar(`dstar') m(`m') ///
			cvars(`cvars') `nointeraction' `cxd' `cxm'
			
	estat bootstrap, p noheader
	di "Note: CDE evaluated at m=`m'"

end lincde
