cap program drop fitsis
program define fitsis
   syntax anything
	noisily {
		di "CFI = `r(CFI)'"
		di "RMSEA = `r(RMSEA)'"
		di "SRMR = `r(SRMR)'"
	}
	local mis "`1'"
	c_local cfi`mis'  : di %5.3f `r(CFI)'
	c_local rmsea`mis' : di %5.3f `r(RMSEA)'
	c_local srmr`mis' : di %5.3f `r(SRMR)'
	local test1`mis' = `r(CFI)'>=.9
	local test2`mis' = `r(RMSEA)'<=.08
	local test3`mis' = `r(SRMR)'<=.08
	local test4`mis' = `r(CFI)'>=.95
	local test5`mis' = `r(RMSEA)'<=.06
	local test6`mis' = `r(SRMR)'<=.06
	local testsum`mis' : di %4.2f  ///
		.9+((`r(CFI)'-.90) + (10/8)*(.08-`r(RMSEA)') + (10/8)*(.08-`r(SRMR)'))/3
	local fit`mis' = "poor (`testsum`mis'')"
	
	if (`test1`mis'' + `test2`mis'' + `test3`mis'')==3 {
		local fit`mis'="adequate (`testsum`mis'')"
	}
	if (`test4`mis'' + `test5`mis'' + `test6`mis'')==3 {
		local fit`mis'="good (`testsum`mis'')"
	}
	forvalues i=1/6 {
		c_local test`i'`mis' "`test`i'`mis''"
	}
	if `r(CFI)'==1 & `r(RMSEA)'==0 & `r(SRMR)'==0 {
		local fit`mis' = "perfect (`testsum`mis'')"
	}
	
	c_local fit`mis' "`fit`mis''"
	c_local free_parameters`mis' = `r(free_parameters)'
	mat E = r(residual_variance)
	local dependent : rownames(E)
        local observed_dependent = `r(Number_of_dependent_variables)'
        * local observed_dependent 0 
	* foreach x in `dependent' {
        *		if regexm("`x'","latent")~=1 {
        *			local observed_dependent = `observed_dependent'+1
        *		}
	* }
	c_local observed_dependent`mis' = `observed_dependent'
	local varok = "ok"
	mat E=r(estimate)
	local rowsare : rownames(E)
	foreach x in `rowsare' {
		if regexm("`x'","_with_")==1 & regexm("`x'","stdyx")==1 {
			eme `x' 
			if `r(r1)'>1 {
				local varok "notok"
				di in red _col(3) "Standardized covariance greater than 1 involving `x' (stdyx = ``r(r1)'')"
			}
		}
		if regexm("`x'","_by_")==1 & regexm("`x'","stdyx")==1 {
			eme `x' 
			if `r(r1)'>1 {
				local varok "notok"
				di in red _col(3) "Heywood case, `x' (stdyx = ``r(r1)'')"
			}
		}
		if regexm("`x'","residual")==1 & regexm("`x'","std")~=1 {
			eme `x' 
			if `r(r1)'<0 {
				local varok "notok"
				di in red _col(3) "negative residual variance, `x' (``x'')"
			}
		}
	}
   c_local varok`mis' "`varok'"	
end
