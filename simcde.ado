*!TITLE: SIMCDE - estimate controlled direct effects using a simulation estimator
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.3 - added svy compatibility
*!

program define simcde, eclass

	version 15	

	syntax varlist(min=1 max=1 numeric) [if][in], ///
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
		
		simcdebs `varlist' [`svywgt' `wgtexp'] if `touse' , ///
			dvar(`dvar') mvar(`mvar') lvars(`lvars') cvars(`cvars') ///
			d(`d') dstar(`dstar') m(`m') yreg(`yreg') lregs(`lregs') /// 
			nsim(1) `nointeraction' `cxd' `cxm' `lxm'
			
	}

	if ("`parallel'" == "") {		
		
		bootstrap, `options' `svy' noheader notable : ///
			simcdebs `varlist' if `touse', ///
				dvar(`dvar') mvar(`mvar') lvars(`lvars') cvars(`cvars') ///
				d(`d') dstar(`dstar') m(`m') yreg(`yreg') lregs(`lregs') ///
				nsim(`nsim') `nointeraction' `cxd' `cxm' `lxm'

		if (e(prefix) == "svy") {
			bstat, noheader
		} 
		else {
			estat bootstrap, p noheader
		}
		
		di as txt "CDE: controlled direct effect at m=`m'"
	
	}
	
	if ("`parallel'" != "") {		
	
		di ""
		di "{bf:Parallel Bootstrapping with Stata}"
		
		parallel initialize
		
		di "{it:Waiting for the child processes to finish...}"
		di ""
		
		qui parallel bs, `options' `svy' : ///
			simcdebs `varlist' if `touse', ///
				dvar(`dvar') mvar(`mvar') lvars(`lvars') cvars(`cvars') ///
				d(`d') dstar(`dstar') m(`m') yreg(`yreg') lregs(`lregs') ///
				nsim(`nsim') `nointeraction' `cxd' `cxm' `lxm'
	
		estat bootstrap, p noheader
		di as txt "CDE: controlled direct effect at m=`m'"
		
		capture parallel clean, all

	}		
	
end simcde
