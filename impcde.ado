*!TITLE: IMPCDE - a module for estimating controlled direct effects using regression imputation
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1
*!

program define impcde, eclass

	version 15	

	syntax varlist(min=1 max=1 numeric) [if][in] [pweight], ///
		dvar(varname numeric) ///
		mvar(varname numeric) ///
		d(real) ///
		dstar(real) ///
		m(real) ///
		yreg(string) ///
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

	local yregtypes regress logit poisson 
	local nyreg : list posof "`yreg'" in yregtypes
	if !`nyreg' {
		display as error "Error: yreg must be chosen from: `yregtypes'."
		error 198		
	}

	if ("`detail'" != "") {		
	
		impcdebs `varlist' if `touse' [`weight' `exp'], ///
			dvar(`dvar') mvar(`mvar') d(`d') dstar(`dstar') m(`m') yreg(`yreg') ///
			cvars(`cvars') `nointeraction' `cxd' `cxm'
	
	}
		
	bootstrap ///
		CDE=r(cde), ///
			force `options' noheader notable: ///
				impcdebs `varlist' if `touse' [`weight' `exp'], ///
					dvar(`dvar') mvar(`mvar') d(`d') dstar(`dstar') m(`m') yreg(`yreg') ///
					cvars(`cvars') `nointeraction' `cxd' `cxm'
			
	estat bootstrap, p noheader
	
end impcde
