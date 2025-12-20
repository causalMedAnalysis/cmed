*!TITLE: LINMED - causal mediation analysis using linear models
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.3 - added svy compatibility
*!

program define linmed, eclass

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
	
	if ("`detail'"!="") {
		
		if ("`svy'" == "svy") {
			qui svyset
			local svywgt = r(wtype)
			local wgtexp = r(wexp)
		}
		else {
			local svywgt
			local wgtexp
		}
		
		linmedbs `varlist' [`svywgt' `wgtexp'] if `touse', ///
			dvar(`dvar') d(`d') dstar(`dstar') cvars(`cvars') ///
			`nointeraction' `cxd' `cxm'
			
	}
	
	if ("`parallel'" == "") {		

		bootstrap, `options' `svy' noheader notable : ///
			linmedbs `varlist' if `touse', ///
				dvar(`dvar') d(`d') dstar(`dstar') cvars(`cvars') ///
				`nointeraction' `cxd' `cxm'
		
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
			linmedbs `varlist' if `touse', ///
				dvar(`dvar') d(`d') dstar(`dstar') cvars(`cvars') ///
				`nointeraction' `cxd' `cxm'
					
		estat bootstrap, p noheader
		
		capture parallel clean, all
		
	}

end linmed
