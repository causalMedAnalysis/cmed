*!TITLE: LINMED - causal mediation analysis using linear models
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.2 - added parallelization 
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
		parallel ///						
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
	
	if ("`parallel'" == "") {		
		
		if (`num_mvars'==1) {
	
			bootstrap ///
				ATE=r(ate) ///
				NDE=r(nde) ///
				NIE=r(nie), ///
					`options' force noheader notable: ///
						linmedbs `varlist' [`weight' `exp'] if `touse', ///
							dvar(`dvar') d(`d') dstar(`dstar') cvars(`cvars') ///
							`nointeraction' `cxd' `cxm'
		}

		if (`num_mvars'>=2) {
	
			bootstrap ///
				ATE=r(ate) ///
				MNDE=r(nde) ///
				MNIE=r(nie), ///
					`options' force noheader notable: ///
						linmedbs `varlist' [`weight' `exp'] if `touse', ///
							dvar(`dvar') d(`d') dstar(`dstar') cvars(`cvars') ///
							`nointeraction' `cxd' `cxm'
		}
	
		estat bootstrap, p noheader
	
	}
	
	if ("`parallel'" != "") {		
		
		di ""
		di "{bf:Parallel Bootstrapping with Stata}"
		
		parallel initialize
		
		di "{it:Waiting for the child processes to finish...}"
		di ""
		
		if (`num_mvars'==1) {

			qui parallel bs, expr(ATE=r(ate) NDE=r(nde) NIE=r(nie)) `options' : ///
				linmedbs `varlist' [`weight' `exp'] if `touse', ///
					dvar(`dvar') d(`d') dstar(`dstar') cvars(`cvars') ///
					`nointeraction' `cxd' `cxm'
							
		}
	
		if (`num_mvars'>=2) {
	
			qui parallel bs, expr(ATE=r(ate) MNDE=r(nde) MNIE=r(nie)) `options' : ///
				linmedbs `varlist' [`weight' `exp'] if `touse', ///
					dvar(`dvar') d(`d') dstar(`dstar') cvars(`cvars') ///
					`nointeraction' `cxd' `cxm'

		}
		
		estat bootstrap, p noheader
		
		capture parallel clean, all
		
	}

end linmed
