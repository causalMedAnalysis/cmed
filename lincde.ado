*!TITLE: LINCDE - estimating controlled direct effects using linear models
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.3 - added svy compatibility
*!

program define lincde, eclass

	version 15	

	syntax varlist(min=1 max=1 numeric) [if][in], ///
		dvar(varname numeric) ///
		mvar(varname numeric) ///
		d(real) ///
		dstar(real) ///
		m(real) ///
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

		lincdebs `varlist' [`svywgt' `wgtexp'] if `touse' , ///
			dvar(`dvar') mvar(`mvar') d(`d') dstar(`dstar') m(`m') ///
			cvars(`cvars') `nointeraction' `cxd' `cxm'
			
	}
	
	if ("`parallel'" == "") {		
	
		bootstrap, `options' `svy' noheader notable : ///
			lincdebs `varlist' if `touse', ///
				dvar(`dvar') mvar(`mvar') d(`d') dstar(`dstar') m(`m') ///
				cvars(`cvars') `nointeraction' `cxd' `cxm'
		
		if (e(prefix) == "svy") {
			bstat, noheader
		} 
		else {
			estat bootstrap, p noheader
		}
		
		di as text "Note: CDE evaluated at m=`m'"
	
	}

	if ("`parallel'" != "") {		
	
		di ""
		di "{bf:Parallel Bootstrapping with Stata}"
		
		parallel initialize
		
		di "{it:Waiting for the child processes to finish...}"
		di ""
		
		qui parallel bs, `options' `svy' : ///
			lincdebs `varlist' if `touse', ///
				dvar(`dvar') mvar(`mvar') d(`d') dstar(`dstar') m(`m') ///
				cvars(`cvars') `nointeraction' `cxd' `cxm'
	
		estat bootstrap, p noheader
		di as text "Note: CDE evaluated at m=`m'"
		
		capture parallel clean, all

	}
	
end lincde
