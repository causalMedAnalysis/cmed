*!TITLE: LINPATH - path-specific effects using linear models
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1 
*!

program define linpath, eclass

	version 15	

	syntax varlist(min=2 numeric) [if][in] [pweight], ///
		dvar(varname numeric) ///
		d(real) ///
		dstar(real) ///
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
	
	gettoken yvar mvars : varlist
	
	local num_mvars = wordcount("`mvars'")
	
	/***PRINT MODELS***/
	if ("`detail'" != "") {
	
		foreach c in `cvars' {
			tempvar `c'_dis_r001
			qui regress `c' [`weight' `exp'] if `touse'
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
			di "Model for `m' given {cvars `dvar'}:"
			regress `m' `dvar' `cvars_dis_r' `cxd_vars_dis' [`weight' `exp'] if `touse' 
		}
		
		linpathbs `yvar' `mvars' [`weight' `exp'] if `touse', ///
			dvar(`dvar') cvars(`cvars') d(`d') dstar(`dstar') ///
			`cxd' `cxm' `nointeraction'
	}
		
	/***COMPUTE POINT AND INTERVAL ESTIMATES***/
	local effects ATE = r(ate)
	if (`num_mvars' == 1) local effects `effects' NDE = r(nde) NIE = r(nie)
	if (`num_mvars' > 1) {
		local effects `effects' PSE_DY = r(pse_DY)
		forv k=`num_mvars'(-1)1 {
			local effects `effects' PSE_DM`k'Y = r(pse_DM`k'Y)
		}
	}
	
	bootstrap `effects', `options' force noheader notable: ///
		linpathbs `yvar' `mvars' [`weight' `exp'] if `touse', ///
			dvar(`dvar') cvars(`cvars') d(`d') dstar(`dstar') ///
			`cxd' `cxm' `nointeraction'
	
	estat bootstrap, p noheader
	
end linpath
