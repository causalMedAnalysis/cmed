*!TITLE: LINMED - causal mediation analysis using linear models
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1
*!

program define linmed, eclass

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
	
	if ("`detail'"!="") {
		linmedbs `varlist' [`weight' `exp'] if `touse', ///
			dvar(`dvar') d(`d') dstar(`dstar') cvars(`cvars') ///
			`nointeraction' `cxd' `cxm'
	}
	
	if (`num_mvars'==1) {
	
		bootstrap ///
			ATE=r(ate) ///
			NDE=r(nde) ///
			NIE=r(nie), ///
				force `options' noheader notable: ///
					linmedbs `varlist' [`weight' `exp'] if `touse', ///
						dvar(`dvar') d(`d') dstar(`dstar') cvars(`cvars') ///
						`nointeraction' `cxd' `cxm'
	}

	if (`num_mvars'>=2) {
	
		bootstrap ///
			ATE=r(ate) ///
			MNDE=r(nde) ///
			MNIE=r(nie), ///
				force `options' noheader notable: ///
					linmedbs `varlist' [`weight' `exp'] if `touse', ///
						dvar(`dvar') d(`d') dstar(`dstar') cvars(`cvars') ///
						`nointeraction' `cxd' `cxm'
	}
	
	estat bootstrap, p noheader

end linmed
