*!TITLE: IMPCDE - a module for estimating controlled direct effects using regression imputation
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.3 - added svy compatibility
*!

program define impcde, eclass

	version 15	

	syntax varlist(min=1 max=1 numeric) [if][in], ///
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
		parallel ///
		svy ///
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
	
		if ("`svy'" == "svy") {
			qui svyset
			local svywgt = r(wtype)
			local wgtexp = r(wexp)
		}
		else {
			local svywgt
			local wgtexp
		}
		
		impcdebs `varlist' if `touse' [`svywgt' `wgtexp'], ///
			dvar(`dvar') mvar(`mvar') d(`d') dstar(`dstar') m(`m') yreg(`yreg') ///
			cvars(`cvars') `nointeraction' `cxd' `cxm'
	
	}

	if ("`parallel'" == "") {		
		
		bootstrap, `options' `svy' noheader notable : ///
			impcdebs `varlist' if `touse', ///
				dvar(`dvar') mvar(`mvar') d(`d') dstar(`dstar') m(`m') ///
				yreg(`yreg') cvars(`cvars') `nointeraction' `cxd' `cxm'
			
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
			impcdebs `varlist' if `touse', ///
				dvar(`dvar') mvar(`mvar') d(`d') dstar(`dstar') m(`m') ///
				yreg(`yreg') cvars(`cvars') `nointeraction' `cxd' `cxm'
	
		estat bootstrap, p noheader
		di as text "Note: CDE evaluated at m=`m'"
		
		capture parallel clean, all

	}
	
end impcde
