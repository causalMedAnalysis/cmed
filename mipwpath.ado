*!TITLE: IPWPATH - analysis of path-specific effects using inverse probability weighting
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.4 - added keepweights option
*!

program define mipwpath, eclass properties(svyb)
	
	version 15	

	syntax varlist(min=2 numeric) [if][in] [pweight iweight], ///
		dvar(varname numeric) ///
		d(real) ///
		dstar(real) ///
		[cvars(varlist numeric)] ///
		[keepweights] ///		
		[censor(numlist min=2 max=2)] 
	
	qui {
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000
		local N = r(N)
	}
			
	gettoken yvar mvars : varlist

	tempvar sampwts
	qui gen `sampwts' = 1 if `touse'
	
	if ("`weight'" != "") {
		tempvar wtvar
		quietly {
			gen double `wtvar' `exp'
			sum `wtvar' if `touse' , meanonly
			replace `sampwts' = `wtvar'/r(mean) if `touse'
		}
	}
		
	logit `dvar' `cvars' [`weight' `exp'] if `touse'
	tempvar phat_D1_C phat_D0_C
	qui predict `phat_D1_C' if e(sample), pr
	qui gen `phat_D0_C'=1-`phat_D1_C' if `touse'
		
	logit `dvar' `mvars' `cvars' [`weight' `exp'] if `touse'
	tempvar phat_D1_CM phat_D0_CM
	qui predict `phat_D1_CM' if e(sample), pr
	qui gen `phat_D0_CM'=1-`phat_D1_CM' if `touse'

	logit `dvar' [`weight' `exp'] if `touse'
	tempvar phat_D1 phat_D0
	qui predict `phat_D1' if e(sample), pr
	qui gen `phat_D0'=1-`phat_D1' if `touse'
	
	tempvar sw1 sw2 sw3 
	qui gen `sw1' = `phat_D`dstar'' / `phat_D`dstar'_C' if `dvar'==`dstar' & `touse'
	qui gen `sw2' = `phat_D`d'' / `phat_D`d'_C' if `dvar'==`d' & `touse'
	qui gen `sw3' = (`phat_D`dstar'_CM'*`phat_D`d'') / (`phat_D`d'_CM'*`phat_D`dstar'_C') if `dvar'==`d' & `touse'
		
	if ("`censor'"!="") {
		foreach i of var `sw1' `sw2' `sw3' {
			qui centile `i' if `i'!=. & `touse', c(`censor') 
			qui replace `i'=r(c_1) if `i'<r(c_1) & `i'!=. & `touse'
			qui replace `i'=r(c_2) if `i'>r(c_2) & `i'!=. & `touse'
		}
	}
	
	foreach i of var `sw1' `sw2' `sw3' {
		qui replace `i' = `i' * `sampwts' if `touse'
	}
	
	qui reg `yvar' [pw=`sw1'] if `dvar'==`dstar' & `touse'
	local Ehat_Y0M0=_b[_cons]
		
	qui reg `yvar' [pw=`sw2'] if `dvar'==`d' & `touse'
	local Ehat_Y1M1=_b[_cons]
		
	qui reg `yvar' [pw=`sw3'] if `dvar'==`d' & `touse'
	local Ehat_Y1M0=_b[_cons]

	tempname ate nde nie
	scalar `ate'=`Ehat_Y1M1'-`Ehat_Y0M0'
	scalar `nde'=`Ehat_Y1M0'-`Ehat_Y0M0'
	scalar `nie'=`Ehat_Y1M1'-`Ehat_Y1M0'

	if ("`keepweights'" != "") {
		
		local ipw_var_names "sw1_r001 sw2_r001 sw3_r001"
		foreach name of local ipw_var_names {
			capture confirm new variable `name'
			if _rc {
				display as error "{p 0 0 5 0}The command needs to create weight variables"
				display as error "with the following names: `ipw_var_names', "
				display as error "but these variables have already been defined.{p_end}"
				error 110
			}
		}
		
		qui gen sw1_r001 = `sw1' if `touse'
		qui gen sw2_r001 = `sw2' if `touse'
		qui gen sw3_r001 = `sw3' if `touse'
	
	}
	
	ereturn clear

	tempname b 
	
	matrix `b' = (`ate', `nde', `nie')
	matrix colnames `b' = "ATE" "NDE" "NIE"	
	
	ereturn post `b' , esample(`touse') obs(`N')

end mipwpath
