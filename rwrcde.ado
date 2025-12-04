*!TITLE: RWRCDE - estimating controlled direct effects using regression-with-residuals
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.2 - added parallelization 
*!
 

program define rwrcde, eclass
	
	version 14	

	syntax varlist(min=1 numeric) [if][in] [pweight], ///
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
		detail * ]
							
	qui {
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000
		local N = r(N)
	}

	gettoken yvar lvar : varlist

	if ("`detail'" != "") {		
		
		rwrcdebs `varlist' if `touse' [`weight' `exp'], ///
			dvar(`dvar') mvar(`mvar') d(`d') dstar(`dstar') m(`m') ///
			cvar(`cvars') cat(`cat') `cxd' `cxm' `lxm' `nointeraction'
			
	}

	if ("`parallel'" == "") {		
		
		bootstrap ///
			CDE=e(CDE), ///
				`options' force noheader notable: ///
					rwrcdebs `varlist' if `touse' [`weight' `exp'], ///
						dvar(`dvar') mvar(`mvar') d(`d') dstar(`dstar') m(`m') ///
						cvar(`cvars') cat(`cat') `cxd' `cxm' `lxm' `nointeraction'

		estat bootstrap, p noheader
		di as txt "CDE: controlled direct effect at m=`m'"

	}

	if ("`parallel'" != "") {		
	
		di ""
		di "{bf:Parallel Bootstrapping with Stata}"
		
		parallel initialize
		
		di "{it:Waiting for the child processes to finish...}"
		di ""
		
		qui parallel bs, expr(CDE=e(CDE)) `options' : ///
			rwrcdebs `varlist' if `touse' [`weight' `exp'], ///
				dvar(`dvar') mvar(`mvar') d(`d') dstar(`dstar') m(`m') ///
				cvar(`cvars') cat(`cat') `cxd' `cxm' `lxm' `nointeraction'
	
		estat bootstrap, p noheader
		di as txt "CDE: controlled direct effect at m=`m'"
		
		capture parallel clean, all

	}	
	
	ereturn local cmdline `"rwrcde `0'"'
	
end




			





