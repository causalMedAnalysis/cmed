*!TITLE: DMLMED - causal mediation analysis using de-biased machine learning
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1 
*!

program define mr1lasso, rclass
	
	version 15	

	syntax varlist(min=1 max=1 numeric) [if][in], ///
		dvar(varname numeric) ///
		mvar(varname numeric) ///
		d(real) ///
		dstar(real) ///
		[ cvars(varlist numeric) ///
		xfits(integer 5) ///
		seed(integer 12345) ///
		censor(numlist min=2 max=2) * ] 
	
	qui {
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000
		local N = r(N)
	}
			
	local yvar `varlist'
		
	tempvar dvar_orig mvar_orig
	qui gen `dvar_orig' = `dvar' if `touse'
	qui gen `mvar_orig' = `mvar' if `touse'

	qui set seed `seed'
	tempvar u kpart
	qui gen `u' = uniform() if `touse'
	qui sort `u'
	qui count if !(`touse')
	local numNotToUse = r(N)
	qui gen `kpart' = ceil(_n/((_N-`numNotToUse')/`xfits')) if `touse'

	local tvars	pi`dstar'_C pi`d'_C ///
		f_M1_CD`dstar' f_M0_CD`dstar' f_M_CD`dstar' ///
		f_M1_CD`d' f_M0_CD`d' f_M_CD`d' ///
		mu`dstar'_CM mu`d'_CM ///
		mu`dstar'_CM0 mu`dstar'_CM1 mu`d'_CM0 mu`d'_CM1
	
	tempvar `tvars'
	
	foreach v in `tvars' {
		qui gen ``v'' = . if `touse'
	}

	tempvar inter
	qui gen `inter' = `dvar' * `mvar' if `touse'

	local cxd_vars
	local cxm_vars
	foreach c in `cvars' {
		tempvar `dvar'X`c' `mvar'X`c'
		
		qui gen ``dvar'X`c'' = `dvar' * `c' if `touse'
		local cxd_vars `cxd_vars' ``dvar'X`c''
		
		qui gen ``mvar'X`c'' = `mvar' * `c' if `touse'
		local cxm_vars `cxm_vars' ``mvar'X`c''
	}

	forval k=1/`xfits' {
		
		di "xfit = `k' ..."
		di "   Training LASSO logit model for `dvar' given C "
		qui lassologit `dvar' `cvars' if `kpart'!=`k' & `touse', lic(aic) postres 
		
		tempvar	phat_D1_C
		qui predict `phat_D1_C' if `kpart'==`k' & `touse', pr
		qui replace `pi`d'_C' = `phat_D1_C'*`d' + (1-`phat_D1_C')*(1-`d') if `kpart'==`k' & `touse'
		qui replace `pi`dstar'_C' = `phat_D1_C'*`dstar' + (1-`phat_D1_C')*(1-`dstar') if `kpart'==`k' & `touse'
		
		di "   Training LASSO logit model for `mvar' given {C,D}"
		qui lassologit `mvar' `dvar' `cvars' `cxd_vars' if `kpart'!=`k' & `touse', lic(aic) postres 
		
		qui replace `dvar' = `dstar' if `touse'
		
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
		}
		
		tempvar	xxf_M1_CD`dstar'
		qui predict `xxf_M1_CD`dstar'' if `kpart'==`k' & `touse', pr
		qui replace `f_M0_CD`dstar'' = 1 - `xxf_M1_CD`dstar'' if `kpart'==`k' & `touse'
		qui replace `f_M1_CD`dstar'' = `xxf_M1_CD`dstar'' if `kpart'==`k' & `touse'
		qui replace `f_M_CD`dstar'' = `f_M1_CD`dstar''*`mvar' + `f_M0_CD`dstar''*(1-`mvar') if `kpart'==`k' & `touse'

		qui replace `dvar' = `d' if `touse'
		
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
		}
				
		tempvar	xxf_M1_CD`d'
		qui predict `xxf_M1_CD`d'' if `kpart'==`k' & `touse', pr
		qui replace `f_M0_CD`d'' = 1 - `xxf_M1_CD`d'' if `kpart'==`k' & `touse'
		qui replace `f_M1_CD`d'' = `xxf_M1_CD`d'' if `kpart'==`k' & `touse'
		qui replace `f_M_CD`d'' = `f_M1_CD`d''*`mvar' + `f_M0_CD`d''*(1-`mvar') if `kpart'==`k' & `touse'
		
		qui replace `dvar' = `dvar_orig' if `touse'
		
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
		}
		
		di "   Training LASSO regression model for `yvar' given {C,D,M}"
		qui lasso2 `yvar' `dvar' `mvar' `inter' `cvars' `cxd_vars' `cxm_vars' if `kpart'!=`k' & `touse', lic(aic) postres `options'
		
		qui replace `dvar' = `dstar' if `touse'
		
		qui replace `inter' = `dvar' * `mvar' if `touse'

		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
		}
		
		tempvar xxmu`dstar'_CM
		qui predict `xxmu`dstar'_CM' if `kpart'==`k' & `touse'
		qui replace `mu`dstar'_CM' = `xxmu`dstar'_CM' if `kpart'==`k' & `touse'

		qui replace `dvar' = `d' if `touse'
		
		qui replace `inter' = `dvar' * `mvar' if `touse'

		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
		}
		
		tempvar xxmu`d'_CM
		qui predict `xxmu`d'_CM' if `kpart'==`k' & `touse'
		qui replace `mu`d'_CM' = `xxmu`d'_CM' if `kpart'==`k' & `touse'
		
		qui replace `dvar' = `dstar' if `touse'
		qui replace `mvar' = 0 if `touse'
		
		qui replace `inter' = `dvar' * `mvar' if `touse'

		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
			qui replace ``mvar'X`c'' = `mvar' * `c' if `touse'
		}
		
		tempvar xxmu`dstar'_CM0
		qui predict `xxmu`dstar'_CM0' if `kpart'==`k' & `touse'
		qui replace `mu`dstar'_CM0' = `xxmu`dstar'_CM0' if `kpart'==`k' & `touse'

		qui replace `dvar' = `dstar' if `touse'
		qui replace `mvar' = 1 if `touse'
		
		qui replace `inter' = `dvar' * `mvar' if `touse'
		
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
			qui replace ``mvar'X`c'' = `mvar' * `c' if `touse'
		}
		
		tempvar xxmu`dstar'_CM1
		qui predict `xxmu`dstar'_CM1' if `kpart'==`k' & `touse'
		qui replace `mu`dstar'_CM1' = `xxmu`dstar'_CM1' if `kpart'==`k' & `touse'
		
		qui replace `dvar' = `d' if `touse'
		qui replace `mvar' = 0 if `touse'
		
		qui replace `inter' = `dvar' * `mvar' if `touse'
		
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
			qui replace ``mvar'X`c'' = `mvar' * `c' if `touse'
		}

		tempvar xxmu`d'_CM0
		qui predict `xxmu`d'_CM0' if `kpart'==`k' & `touse'
		qui replace `mu`d'_CM0' = `xxmu`d'_CM0' if `kpart'==`k' & `touse'

		qui replace `dvar' = `d' if `touse'
		qui replace `mvar' = 1 if `touse'

		qui replace `inter' = `dvar' * `mvar' if `touse'
		
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
			qui replace ``mvar'X`c'' = `mvar' * `c' if `touse'
		}

		tempvar xxmu`d'_CM1
		qui predict `xxmu`d'_CM1' if `kpart'==`k' & `touse'
		qui replace `mu`d'_CM1' = `xxmu`d'_CM1' if `kpart'==`k' & `touse'
		
		qui replace `dvar' = `dvar_orig' if `touse'
		qui replace `mvar' = `mvar_orig' if `touse'
		
		qui replace `inter' = `dvar' * `mvar' if `touse'
		
		foreach c in `cvars' {
			qui replace ``dvar'X`c'' = `dvar' * `c' if `touse'
			qui replace ``mvar'X`c'' = `mvar' * `c' if `touse'
		}
		
		capture drop ///
			`phat_D0_C' `phat_D1_C' ///
			`xxf_M0_CD`dstar'' `xxf_M1_CD`dstar'' ///
			`xxf_M0_CD`d'' `xxf_M1_CD`d'' ///
			`xxmu`dstar'_CM' `xxmu`d'_CM' ///
			`xxmu`dstar'_CM0' `xxmu`d'_CM0' ///
			`xxmu`dstar'_CM1' `xxmu`d'_CM1'
	}
	
	tempvar ipw`d' ipw`dstar' rmpw

	qui gen `ipw`d'' = 0 if `touse'
	qui replace `ipw`d'' = 1/`pi`d'_C' if `dvar'==`d' & `touse'
	
	qui gen `ipw`dstar'' = 0 if `touse'
	qui replace `ipw`dstar'' = 1/`pi`dstar'_C' if `dvar'==`dstar' & `touse'
		
	qui gen `rmpw' = `ipw`d''*(`f_M_CD`dstar''/`f_M_CD`d'') if `touse'

	if ("`censor'"!="") {
		qui centile `ipw`d'' if `ipw`d''!=. & `dvar'==`d' & `touse', c(`censor') 
		qui replace `ipw`d''=r(c_1) if `ipw`d''<r(c_1) & `ipw`d''!=. & `dvar'==`d' & `touse'
		qui replace `ipw`d''=r(c_2) if `ipw`d''>r(c_2) & `ipw`d''!=. & `dvar'==`d' & `touse'

		qui centile `ipw`dstar'' if `ipw`dstar''!=. & `dvar'==`dstar' & `touse', c(`censor') 
		qui replace `ipw`dstar''=r(c_1) if `ipw`dstar''<r(c_1) & `ipw`dstar''!=. & `dvar'==`dstar' & `touse'
		qui replace `ipw`dstar''=r(c_2) if `ipw`dstar''>r(c_2) & `ipw`dstar''!=. & `dvar'==`dstar' & `touse'

		qui centile `rmpw' if `rmpw'!=. & `dvar'==`d' & `touse', c(`censor') 
		qui replace `rmpw'=r(c_1) if `rmpw'<r(c_1) & `rmpw'!=. & `dvar'==`d' & `touse'
		qui replace `rmpw'=r(c_2) if `rmpw'>r(c_2) & `rmpw'!=. & `dvar'==`d' & `touse'
	}
	
	tempvar dr`d'`d'_summand
	qui gen `dr`d'`d'_summand' = `ipw`d''*(`yvar' - `mu`d'_CM') ///
		+ `ipw`d''*(`mu`d'_CM' - (`mu`d'_CM0'*`f_M0_CD`d'' + `mu`d'_CM1'*`f_M1_CD`d'')) ///
		+ (`mu`d'_CM0'*`f_M0_CD`d'' + `mu`d'_CM1'*`f_M1_CD`d'') if `touse'
	
	tempvar dr`dstar'`dstar'_summand
	qui gen `dr`dstar'`dstar'_summand' = `ipw`dstar''*(`yvar' - `mu`dstar'_CM') ///
		+ `ipw`dstar''*(`mu`dstar'_CM' - (`mu`dstar'_CM0'*`f_M0_CD`dstar'' + `mu`dstar'_CM1'*`f_M1_CD`dstar'')) ///
		+ (`mu`dstar'_CM0'*`f_M0_CD`dstar'' + `mu`dstar'_CM1'*`f_M1_CD`dstar'') if `touse'

	tempvar dr`dstar'`d'_summand
	qui gen `dr`dstar'`d'_summand' = `rmpw'*(`yvar' - `mu`d'_CM') ///
		+ `ipw`dstar''*(`mu`d'_CM' - (`mu`d'_CM0'*`f_M0_CD`dstar'' + `mu`d'_CM1'*`f_M1_CD`dstar'')) ///
		+ (`mu`d'_CM0'*`f_M0_CD`dstar'' + `mu`d'_CM1'*`f_M1_CD`dstar'') if `touse'
	
	tempvar eifATE eifNDE eifNIE
	qui gen `eifATE' = `dr`d'`d'_summand' - `dr`dstar'`dstar'_summand'
	qui gen `eifNDE' = `dr`dstar'`d'_summand' - `dr`dstar'`dstar'_summand'
	qui gen `eifNIE' = `dr`d'`d'_summand' - `dr`dstar'`d'_summand'
	
	qui mean `eifATE' `eifNDE' `eifNIE'
	return scalar ate = _b[`eifATE']
	return scalar nde = _b[`eifNDE']
	return scalar nie = _b[`eifNIE']
	
	return scalar se_ate = _se[`eifATE']
	return scalar se_nde = _se[`eifNDE']
	return scalar se_nie = _se[`eifNIE']
	
	return scalar ll95_ate = _b[`eifATE']-1.96*_se[`eifATE']
	return scalar ll95_nde = _b[`eifNDE']-1.96*_se[`eifNDE']
	return scalar ll95_nie = _b[`eifNIE']-1.96*_se[`eifNIE']

	return scalar ul95_ate = _b[`eifATE']+1.96*_se[`eifATE']
	return scalar ul95_nde = _b[`eifNDE']+1.96*_se[`eifNDE']
	return scalar ul95_nie = _b[`eifNIE']+1.96*_se[`eifNIE']

	return scalar pval_ate = (1-normal(abs(_b[`eifATE']/_se[`eifATE'])))*2
	return scalar pval_nde = (1-normal(abs(_b[`eifNDE']/_se[`eifNDE'])))*2
	return scalar pval_nie = (1-normal(abs(_b[`eifNIE']/_se[`eifNIE'])))*2
	
end mr1lasso

	
