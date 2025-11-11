*!TITLE: RWRCDE - estimating controlled direct effects using regression-with-residuals
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1
*!

capture program drop rwrcdebs
program define rwrcdebs, eclass
	
	version 14	

	syntax varlist(min=1 numeric) [if][in] [pweight],		 	///
		dvar(varname numeric)									/// 
		mvar(varname numeric)									///
		d(real) 												/// 
		dstar(real) 											/// 
		m(real)													/// 
		[cvar(varlist numeric)									/// 
		CAT(varlist numeric)									/// specify categorical variables
		cxd														/// interaction between cvar and dvar
		cxm														/// interaction between cvar and mvar
		lxm														/// interaction between lvar and mvar
		NOINTERaction]										

		qui {
			marksample touse
			count if `touse'
			if r(N) == 0 error 2000
			local N = r(N)
		}
		
		gettoken yvar lvar : varlist
		
		local mreg regress
				
		// generate treatment X mediator interaction
		if "`nointeraction'" == "" {
			tempvar inter
			qui gen `inter' = `dvar'*`mvar' if `touse'
		}
	
		// residualize pre-treatment covariates 
		qui if "`cvar'"!="" {	
			foreach c in `cvar' {
				local ctest : list c in cat
				* categorical variables
				if `ctest' == 1 {
					levelsof `c' if `touse', local(levels)
					local levcnt: word count `levels'
					if `levcnt' < 2 { 
                        di as err "`c' must have at least 2 levels."
						exit 198
					} 
					* binary 
					else if `levcnt' == 2 {
						regress `c' [`weight' `exp'] if `touse'
						tempvar `c'_r
						predict ``c'_r' if e(sample), resid
						* residualized cvars
						local cvar_r `cvar_r' ``c'_r'
						* revised cvars
						local cvarlist `cvarlist' `c'
					}
					* else multicategorical
					else if `levcnt' > 2 {
						sum `c' if `touse', meanonly
						local min = `r(min)'
						levelsof `c' if `c' > `min' & `touse', local(levels)
						foreach i of local levels {
							tempvar `c'`i'
							gen ``c'`i'' = (`c'==`i') if `touse'
							regress ``c'`i'' [`weight' `exp'] if `touse'
							tempvar `c'_r`i'
							predict ``c'_r`i'' if e(sample), resid
							* residualized cvars
							local cvar_r `cvar_r' ``c'_r`i'' 
							* revised cvars
							local cvarlist `cvarlist' ``c'`i''
						} // foreach
					} // end levcnt > 2 
				} // end ctest == 1
				* else continuous
				else {
					regress `c' [`weight' `exp'] if `touse'
					tempvar `c'_r
					predict ``c'_r' if e(sample), resid
					* residualized cvars
					local cvar_r `cvar_r' ``c'_r'
					* revised cvars
					local cvarlist `cvarlist' `c'
				} // end ctest == 0
			} // end foreach
		} // end if cvar
		
		// generate dvar X cvar interactions
		if "`cxd'"!="" {	
			foreach c in `cvar_r' {
				tempvar `dvar'X`c'
				gen ``dvar'X`c'' = `dvar' * `c' if `touse'
				local cxd_r `cxd_r'  ``dvar'X`c''
			}
		}
	
		// generate mvar X cvar interactions
		if "`cxm'"!="" {	
			foreach c in `cvar_r' {
				tempvar `mvar'X`c'
				gen ``mvar'X`c'' = `mvar' * `c' if `touse'
				local cxm_r `cxm_r'  ``mvar'X`c''
			}
		}
		
		// residualize post-treatment covariates
		qui if "`lvar'"!="" {	
			foreach l in `lvar' {
				local ltest : list l in cat
				if `ltest' == 1 {
					levelsof `l' if `touse', local(levels)
					local levcnt: word count `levels'
					if `levcnt' == 2 {
						capture logit `l' `dvar' `cvarlist' `cxd_r' [`weight' `exp'] if `touse'
						capture assert e(rank) == e(k)
						if _rc==9 {
							display "`l' has values that lead to perfect prediction, and thus observations were dropped"
						}
						tempvar `l'_r
						predict ``l'_r' if e(sample), pr
						replace ``l'_r' = `l' - ``l'_r' if `touse'
						local lvar_r `lvar_r' ``l'_r'
					}
					else if `levcnt' > 2 {
						sum `l' if `touse', meanonly
						local min = `r(min)'
						levelsof `l' if `l' > `min' & `touse', local(levels)
						foreach i of local levels {
							tempvar `l'`i'
							gen ``l'`i'' = (`l'==`i') if `touse'
							capture logit ``l'`i'' `dvar' `cvarlist' `cxd_r' [`weight' `exp'] if `touse'
							if _rc==430 {
								noisily di _n
								di as err "A model could not converge when residualizing level `i' of `l'."
								di as err "Consider either collapsing this variable into fewer categories, or treat it as a continuous variable" 
								exit 430
							}	
							capture assert e(rank) == e(k)
							if _rc==9 {
								noisily di _n
								di as err "When residualing level `i' of `l', the model had values that lead to perfect prediction, and thus observations were dropped."
								di as err "Consider either collapsing `l' into fewer categories, or treat it as a continuous variable" 
							}
							tempvar `l'_r`i'
							predict ``l'_r`i'' if e(sample), pr
							replace ``l'_r`i'' = ``l'`i'' - ``l'_r`i'' if `touse'
							local lvar_r `lvar_r' ``l'_r`i''
						} // foreach
					} // end levcnt > 2 
				} // end ltest == 1
				else {
					regress `l' `dvar' `cvarlist' `cxd_r' [`weight' `exp'] if `touse'
					tempvar `l'_r
					predict ``l'_r' if e(sample), resid
					local lvar_r `lvar_r' ``l'_r'
				} // end ltest == 0
			} // end foreach
		} // end if lvar
				
		// generate mvar X lvar interactions
		if "`lxm'"!="" {	
			foreach l in `lvar_r' {
				tempvar `mvar'X`l'
				gen ``mvar'X`l'' = `mvar' * `l' if `touse'
				local lxm_r `lxm_r'  ``mvar'X`l''
			}
		}
	
		***************************
		// block 1: mreg=regress // 
		***************************
		if substr("`mreg'", 1, 3) == "reg" {
		
			// no interaction
			if "`nointeraction'" != "" {

				`qui' gsem (`yvar' <- `dvar' `mvar' `cvar_r' `lvar_r' `cxd_r' `cxm_r' `lxm_r' [`weight' `exp'] if `touse', regress) ///
							(`mvar' <- `dvar' `cvar_r' `cxd_r' , regress) 
				
				// * save table of estimates as matrix * //
				qui matrix b = e(b)

				// * retrieve estimates * // 
				scalar treatO = b[1,colnumb(matrix(b),"`yvar':`dvar'")]
				scalar treatM = b[1,colnumb(matrix(b),"`mvar':`dvar'")]
				scalar medO = b[1,colnumb(matrix(b),"`yvar':`mvar'")]

				ereturn scalar CDE = treatO * (`d'-`dstar')
			
			} // end no interaction
			
			// with interaction
			if "`nointeraction'" == "" {
				
				`qui' gsem  (`yvar' <- `dvar' `mvar' `inter' `cvar_r' `lvar_r' `cxd_r' `cxm_r' `lxm_r' [`weight' `exp'] if `touse', regress) ///
							(`mvar' <- `dvar' `cvar_r' `cxd_r', regress) 

				// * save table of estimates as matrix * //
				qui matrix b = e(b)

				// * retrieve estimates * // 
				scalar treatO = b[1,colnumb(matrix(b),"`yvar':`dvar'")]
				scalar treatM = b[1,colnumb(matrix(b),"`mvar':`dvar'")]
				scalar medO = b[1,colnumb(matrix(b),"`yvar':`mvar'")]
				scalar interY = b[1,colnumb(matrix(b),"`yvar':`inter'")]
				scalar consM =  b[1,colnumb(matrix(b),"`mvar':_cons")]
				
				ereturn scalar CDE = (treatO + interY * `m') * (`d'-`dstar')
							
			} // end with interaction 
		} // end mreg == regress

end


