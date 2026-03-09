*!TITLE: IPWPATH - analysis of path-specific effects using inverse probability weighting
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.4 - added keepweights option; modified variable labels
*!

program define ipwpath, eclass

	version 15	

	syntax varlist(min=2 numeric) [if][in], ///
		dvar(varname numeric) ///
		d(real) ///
		dstar(real) ///
		[cvars(varlist numeric) ///
		censor(numlist min=2 max=2) ///
		parallel ///		
		keepweights ///		
		svy ///
		detail * ]
		
	qui {
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000
	}
	
	gettoken yvar mvars : varlist
	
	local num_mvars = wordcount("`mvars'")

	foreach i in `dvar' {
		confirm variable `i'
		qui levelsof `i', local(levels)
		if "`levels'" != "0 1" & "`levels'" != "1 0" {
			display as error "The variable `i' is not binary and coded 0/1"
			error 198
		}
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

	if ("`svy'" == "svy") {
		qui svyset
		local svywgt = r(wtype)
		local wgtexp = r(wexp)
	}
	else {
		local svywgt
		local wgtexp
	}
	
	if ("`detail'" != "") {
		
		di ""
		di "{bf:Model for `dvar' conditional on cvars:}"
		logit `dvar' `cvars' [`svywgt' `wgtexp'] if `touse'
		
		local mvars_include		
		forv i=1/`num_mvars' {
			
			local mvars_include `mvars_include' `=word("`mvars'",`i')'
			
			di ""
			di "{bf:Model for `dvar' conditional on {cvars `mvars_include'}:}"
			logit `dvar' `mvars_include' `cvars' [`svywgt' `wgtexp'] if `touse'
			
		}
		
	}

	if ("`keepweights'" != "") {
		
		forv k=`num_mvars'(-1)1 {
		
			local mvars_include
			forv j=1/`k' {
				local mvars_include `mvars_include' `=word("`mvars'",`j')'
			}
		
			qui mipwpath `yvar' `mvars_include' [`svywgt' `wgtexp'] if `touse', ///
				dvar(`dvar') cvars(`cvars') d(`d') dstar(`dstar') ///
				censor(`censor') keepweights

			local ipw_var_names "sw1_r001_`k' sw2_r001_`k' sw3_`k'_r001"
			foreach name of local ipw_var_names {
				capture confirm new variable `name'
				if _rc {
					display as error "{p 0 0 5 0}The command needs to create weight variables"
					display as error "with the following names: `ipw_var_names', "
					display as error "but these variables have already been defined.{p_end}"
					error 110
				}
			}
				
			qui rename sw1_r001 sw1_r001_`k'
			qui rename sw2_r001 sw2_r001_`k'
			qui rename sw3_r001 sw3_`k'_r001
			
            local dots = cond(`k'>2,"...",",")
			qui label var sw3_`k'_r001 "IPW for estimating E(Y(d,M1(d*)`dots'M`k'(d*)))"
            
		}
		
		qui rename sw1_r001_`num_mvars' sw1_r001
		qui rename sw2_r001_`num_mvars' sw2_r001
		
		qui label var sw1_r001 "IPW for estimating E(Y(d*))"
		qui label var sw2_r001 "IPW for estimating E(Y(d))"
		qui label var sw3_1_r001 "IPW for estimating E(Y(d,M1(d*)))"
			
		capture drop sw1_r001_* sw2_r001_*
	}
	
	if ("`parallel'" == "") {		
		
		bootstrap, `options' `svy' noheader notable : ///
			ipwpathbs `yvar' `mvars' if `touse', ///
				dvar(`dvar') cvars(`cvars') d(`d') dstar(`dstar') ///
				censor(`censor')
	
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
			ipwpathbs `yvar' `mvars' if `touse', ///
				dvar(`dvar') cvars(`cvars') d(`d') dstar(`dstar') ///
				censor(`censor')
	
		estat bootstrap, p noheader
		
		capture parallel clean, all

	}
	
end ipwpath
