*!TITLE: LINPATH - path-specific effects using linear models
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.3 - added svy compatibility
*!

program define linpath, eclass

	version 15	

	syntax varlist(min=2 numeric) [if][in], ///
		dvar(varname numeric) ///
		d(real) ///
		dstar(real) ///
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
	
	gettoken yvar mvars : varlist
	
	local num_mvars = wordcount("`mvars'")
	
	/***PRINT MODELS***/
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
	
		foreach c in `cvars' {
			tempvar `c'_dis_r001
			qui regress `c' [`svywgt' `wgtexp'] if `touse'
			qui predict ``c'_dis_r001' if e(sample), resid
			local cvars_dis_r `cvars_dis_r' ``c'_dis_r001'
		}

		if ("`cxd'"!="") {	
			foreach c in `cvars_dis_r' {
				tempvar `c'xD_dis
				qui gen ``c'xD_dis' = `dvar' * `c' if `touse'
				local cxd_vars_dis `cxd_vars_dis' ``c'xD_dis'
			}
		}
		
		foreach m in `mvars' {
			di ""
			di "{bf:Model for `m' given {cvars `dvar'}:}"
			regress `m' `dvar' `cvars_dis_r' `cxd_vars_dis' [`svywgt' `wgtexp'] if `touse' 
		}
		
		linpathbs `yvar' `mvars' [`svywgt' `wgtexp'] if `touse', ///
			dvar(`dvar') cvars(`cvars') d(`d') dstar(`dstar') ///
			`cxd' `cxm' `nointeraction'
			
	}
		
	/***COMPUTE POINT AND INTERVAL ESTIMATES***/
	if ("`parallel'" == "") {		
		
		bootstrap, `options' `svy' noheader notable : ///
			linpathbs `yvar' `mvars' if `touse', ///
				dvar(`dvar') cvars(`cvars') d(`d') dstar(`dstar') ///
				`cxd' `cxm' `nointeraction'
	
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
			linpathbs `yvar' `mvars' if `touse', ///
				dvar(`dvar') cvars(`cvars') d(`d') dstar(`dstar') ///
				`cxd' `cxm' `nointeraction'
	
		estat bootstrap, p noheader
		
		capture parallel clean, all

	}
	
end linpath
