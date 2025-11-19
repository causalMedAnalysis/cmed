*!TITLE: PATHSIM - analysis of path-specific effects using a simulation approach
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1 
*!


program define pathsim, eclass

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
	
	local yvar `varlist'
	
	local num_mvars = wordcount("`mvars'")

	if ("`detail'" != "") {		
		mnesimbs `varlist' [`weight' `exp'] if `touse' , ///
			dvar(`dvar') mvars(`mvars') cvars(`cvars') ///
			d(`d') dstar(`dstar') mregs(`mregs') yreg(`yreg') /// 
			nsim(1) `nointeraction' `cxd' `cxm'
	}
	
	local effects ATE = r(ate)
	if (`num_mvars' == 1) local effects `effects' NDE = r(nde) NIE = r(nie)
	if (`num_mvars' > 1) {
		local effects `effects' PSE_DY = r(pse_DY)
		forv k=`num_mvars'(-1)1 {
			local effects `effects' PSE_DM`k'Y = r(pse_DM`k'Y)
		}
	}
	
	if ("`parallel'" == "") {		
		
		bootstrap `effects', `options' noheader notable: ///
			pathsimbs `yvar' if `touse' [`weight' `exp'], ///
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
		
		qui parallel bs, expr(`effects') `options' noheader notable: ///
			pathsimbs `yvar' if `touse' [`weight' `exp'], ///
				dvar(`dvar') mvars(`mvars') cvars(`cvars') ///
				d(`d') dstar(`dstar') mregs(`mregs') yreg(`yreg') ///
				nsim(`nsim') `nointeraction' `cxd' `cxm'	
	
		estat bootstrap, p noheader
		
		capture parallel clean, all

	}
	
end pathsim
