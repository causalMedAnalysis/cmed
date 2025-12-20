*!TITLE: MRPATH - path-specific effects using parametric multiply robust methods
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.3 - added svy compatibility
*!


program define mrpath, eclass

	version 15	

	syntax varlist(min=2 numeric) [if][in], ///
		dvar(varname numeric) ///
		d(real) ///
		dstar(real) ///
		[ cvars(varlist numeric) ///
		NOINTERaction ///
		cxd ///
		cxm ///
		parallel ///	
		svy ///
		censor(numlist min=2 max=2) ///
		detail * ] 
		
	qui {
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000
	}
	
	gettoken yvar mvars : varlist
	
	local num_mvars = wordcount("`mvars'")

	confirm variable `dvar'
	qui levelsof `dvar', local(levels)
	if "`levels'" != "0 1" & "`levels'" != "1 0" {
		display as error "The variable `dvar' is not binary and coded 0/1"
		error 198
	}

	if ("`censor'" != "") {
		local censor1: word 1 of `censor'
		local censor2: word 2 of `censor'

		if (`censor1' >= `censor2') {
			di as error "The first number in the censor() option must be less than the second."
			error 198
		}

		if (`censor1' < 1 | `censor1' > 49) {
			di as error "The first number in the censor() option must be between 1 and 49."
			error 198
		}

		if (`censor2' < 51 | `censor2' > 99) {
			di as error "The second number in the censor() option must be between 51 and 99."
			error 198
		}
	}

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

	di ""
	di "{bf:Model for `dvar' conditional on {cvars}:}"			
	logit `dvar' `cvars' [`svywgt' `wgtexp'] if `touse'
			
	mrpathbs `yvar' `mvars' [`svywgt' `wgtexp'] if `touse', ///
		dvar(`dvar') d(`d') dstar(`dstar') cvars(`cvars') ///
		`cxd' `cxm' `nointeraction' censor(`censor')
			
	}
	
	if ("`parallel'" == "") {		
		
		bootstrap, `options' `svy' noheader notable: ///
			mrpathbs `yvar' `mvars' if `touse', ///
				dvar(`dvar') d(`d') dstar(`dstar') cvars(`cvars') ///
				`cxd' `cxm' `nointeraction' censor(`censor')
	
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
			mrpathbs `yvar' `mvars' if `touse', ///
				dvar(`dvar') d(`d') dstar(`dstar') cvars(`cvars') ///
				`cxd' `cxm' `nointeraction' censor(`censor')
	
		estat bootstrap, p noheader
		
		capture parallel clean, all

	}	

end mrpath
