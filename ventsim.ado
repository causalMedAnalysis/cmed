*!TITLE: VENTSIM - analysis of interventional effects using a simulation estimator
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.3 - added svy compatibility
*!

program define ventsim, eclass

	version 15	

	syntax varlist(min=1 max=1 numeric) [if][in], ///
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

		ventsimbs `varlist' [`svywgt' `wgtexp'] if `touse' , ///
			dvar(`dvar') mvar(`mvar') lvars(`lvars') cvars(`cvars') ///
			d(`d') dstar(`dstar') mreg(`mreg') yreg(`yreg') lregs(`lregs') /// 
			nsim(1) `nointeraction' `cxd' `cxm' `lxm'
			
	}
		
	if ("`parallel'" == "") {		
		
		bootstrap, `options' `svy' noheader notable : ///
			ventsimbs `varlist' if `touse', ///
				dvar(`dvar') mvar(`mvar') lvars(`lvars') cvars(`cvars') ///
				d(`d') dstar(`dstar') mreg(`mreg') yreg(`yreg') lregs(`lregs') ///
				nsim(`nsim') `nointeraction' `cxd' `cxm' `lxm'

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
			ventsimbs `varlist' if `touse', ///
				dvar(`dvar') mvar(`mvar') lvars(`lvars') cvars(`cvars') ///
				d(`d') dstar(`dstar') mreg(`mreg') yreg(`yreg') lregs(`lregs') ///
				nsim(`nsim') `nointeraction' `cxd' `cxm' `lxm'
	
		estat bootstrap, p noheader
		
		capture parallel clean, all

	}		
	
end ventsim
