*!TITLE: RWRLITE - causal mediation analysis using regression-with-residuals
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.3 - added svy compatibility 
*!

program define rwrlite, eclass
	
	version 14	

	syntax varlist(min=1 numeric) [if][in], ///
		dvar(varname numeric) /// 
		mvar(varname numeric) ///
		d(real) /// 
		dstar(real) /// 
		[cvars(varlist numeric) /// 
		CAT(varlist numeric) ///
		cxd ///
		cxm ///
		lxm ///
		NOINTERaction ///
		parallel ///	
		svy ///
		detail * ]
							
	qui {
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000
	}

	gettoken yvar lvar : varlist

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
		
		rwrlitebs `varlist' if `touse' [`svywgt' `wgtexp'], ///
			dvar(`dvar') mvar(`mvar') d(`d') dstar(`dstar') ///
			cvar(`cvars') cat(`cat') `cxd' `cxm' `lxm' `nointeraction'
			
	}

	if ("`parallel'" == "") {		
		
		bootstrap, `options' `svy' noheader notable : ///
			rwrlitebs `varlist' if `touse', ///
				dvar(`dvar') mvar(`mvar') d(`d') dstar(`dstar') ///
				cvar(`cvars') cat(`cat') `cxd' `cxm' `lxm' `nointeraction'

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
			rwrlitebs `varlist' if `touse' [`weight' `exp'], ///
				dvar(`dvar') mvar(`mvar') d(`d') dstar(`dstar') ///
				cvar(`cvars') cat(`cat') `cxd' `cxm' `lxm' `nointeraction'
	
		estat bootstrap, p noheader
		
		capture parallel clean, all

	}	
	
end

			





