*!TITLE: RWRCDE - estimating controlled direct effects using regression-with-residuals
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.3 - added svy compatibility
*!
 
program define rwrcde, eclass
	
	version 14	

	syntax varlist(min=1 numeric) [if][in], ///
		dvar(varname numeric) /// 
		mvar(varname numeric) ///
		d(real) /// 
		dstar(real) /// 
		m(real) /// 
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
		local N = r(N)
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
		
		rwrcdebs `varlist' if `touse' [`svywgt' `wgtexp'], ///
			dvar(`dvar') mvar(`mvar') d(`d') dstar(`dstar') m(`m') ///
			cvar(`cvars') cat(`cat') `cxd' `cxm' `lxm' `nointeraction'
			
	}

	if ("`parallel'" == "") {		
		
		bootstrap, `options' `svy' noheader notable : ///
			rwrcdebs `varlist' if `touse', ///
				dvar(`dvar') mvar(`mvar') d(`d') dstar(`dstar') m(`m') ///
				cvar(`cvars') cat(`cat') `cxd' `cxm' `lxm' `nointeraction'

		if (e(prefix) == "svy") {
			bstat, noheader
		} 
		else {
			estat bootstrap, p noheader
		}
		
		di as txt "CDE: controlled direct effect at m=`m'"

	}

	if ("`parallel'" != "") {		
	
		di ""
		di "{bf:Parallel Bootstrapping with Stata}"
		
		parallel initialize
		
		di "{it:Waiting for the child processes to finish...}"
		di ""
		
		qui parallel bs, `options' `svy' : ///
			rwrcdebs `varlist' if `touse' [`weight' `exp'], ///
				dvar(`dvar') mvar(`mvar') d(`d') dstar(`dstar') m(`m') ///
				cvar(`cvars') cat(`cat') `cxd' `cxm' `lxm' `nointeraction'
	
		estat bootstrap, p noheader
		di as txt "CDE: controlled direct effect at m=`m'"
		
		capture parallel clean, all

	}	
	
end




			





