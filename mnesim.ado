*!TITLE: MNESIM - analysis of multivariate natural effects using a simulation approach
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.3 - added svy compatibility
*!

program define mnesim, eclass

	version 15	

	syntax varlist(min=1 max=1 numeric) [if][in], ///
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
		
		mnesimbs `varlist' [`svywgt' `wgtexp'] if `touse' , ///
			dvar(`dvar') mvars(`mvars') cvars(`cvars') ///
			d(`d') dstar(`dstar') mregs(`mregs') yreg(`yreg') /// 
			nsim(1) `nointeraction' `cxd' `cxm'
			
	}

	if ("`parallel'" == "") {		
		
		bootstrap, `options' `svy' noheader notable: ///
			mnesimbs `varlist' if `touse', ///
				dvar(`dvar') mvars(`mvars') cvars(`cvars') ///
				d(`d') dstar(`dstar') mregs(`mregs') yreg(`yreg') ///
				nsim(`nsim') `nointeraction' `cxd' `cxm'

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
			mnesimbs `varlist' if `touse', ///
				dvar(`dvar') mvars(`mvars') cvars(`cvars') ///
				d(`d') dstar(`dstar') mregs(`mregs') yreg(`yreg') ///
				nsim(`nsim') `nointeraction' `cxd' `cxm'
	
		estat bootstrap, p noheader
		
		capture parallel clean, all

	}
	
end mnesim
