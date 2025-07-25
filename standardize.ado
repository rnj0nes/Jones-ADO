pro def standardize
capture program drop standardize
syntax varlist [if] [in] [, replace mean(string) sd(string) t ets iq stanines nce gelman tmc ]
   
* T = 50(10)
* ETS = 500(100)
* IQ = 100(15)
* STANINES = 5(2)
* Gelman = 0(.5) [var = 0.25] <- via standardizing on two standard deviations
* nce = 50(21.06)

local factor1=0
local factor2=1

if lower("`t'")=="t" {
   local factor1=50
   local factor2=10
}
if lower("`ets'")=="ets" {
   local factor1=500
   local factor2=100
}
if lower("`iq'")=="iq" {
   local factor1=100
   local factor2=15
}
if lower("`stanines'")=="stanines" {
   local factor1=5
   local factor2=2
}
*if lower("`gelman'")=="gelman" {
*   local factor1=0
*   local factor2=0.5
*}

if lower("`nce'")=="nce" {
   local factor1=50
   local factor2=21.06
}


marksample touse , novarlist
tokenize `varlist'
while "`1'"~="" {
	if "`tmc'"~="tmc"{
	   if "`replace'"~="replace" {
	      capture novarabbrev drop z`1'
	   }
	   if "`mean'"=="" & "`sd'"=="" {
	      qui summarize `1' if `touse'
	      local mean=r(mean)
	      local sd=r(sd)
	   }
	   else if "`mean'"=="" & "`sd'"~="" {
	      qui summarize `1' if `touse'
	      local mean=r(mean)
	   }
	   else if "`mean'"~="" & "`sd'"=="" {
	      qui summarize `1' if `touse'
	      local sd=r(sd)
	   }
	   if "`replace'"=="replace" {
	      local cmd="replace"
	   }
	   else {
	      local cmd="gen"
	      local stub="z"
	   }
	   if lower("`gelman'")~="gelman" {
	      qui `cmd' `stub'`1' = (((`1'-`mean')/`sd')*`factor2')+`factor1'
	   }
	   if lower("`gelman'")=="gelman" {
	      qui `cmd' `stub'`1' = (((`1'-`mean')/(2*`sd'))*`factor2')+`factor1'
	   }
	   local mean=round(`mean',.001)
	   local sd=round(`sd',.001)
	   if "`replace'"=="replace" {
	      * label commands for replace
	   }
	   else {
	      label variable `stub'`1' "`1' standardized with mean `mean' and sd `sd'"
	   }
	   qui su `stub'`1' 
	   local valid=r(N)
	   tempvar v1
	   qui gen `v1' = 1
	   qui su `v1'
	   local sam = r(N)
	   local ifin = "`if'"+"`in'"
	   if "`ifin'"~="" {
	      local text1 = ", the mean and sd of the group defined by `ifin'"
	   }   
	   di in gr "`stub'`1' generated as `1' standardized with " _c
	   di in gr %5.3f "mean(sd)" `mean' "(" `sd' ")"  _c
	   display ", with " `sam'-`valid' " missing values" _c
	   display "`text1'"
	}
	if "`tmc'"=="tmc" {
		* Step 1 - gather information
		qui {
			local X = "`1'" // the outcome variable
			cap drop z3`X' // replace option is always on
			cap drop z3`X's1 
			cap drop z3`X's2
			_pctile `X' if `touse' , p(33 67)  // obtain and store (next lines) tertile tresholds
			local t1 = `r(r1)'
			local t2 = `r(r2)'	
			summarize `X' if (`X' < `t1') //& `touse'
			local mean1 = `r(mean)' // mean in lowest tertile
			summarize `X' if (`X' >= `t1' & `X' < `t2') //& `touse'
			local mean2 = `r(mean)' // mean in middle tertile
			summarize `X' if (`X' >= `t2' & missing(`X')~=1) //& `touse'
			local mean3 = `r(mean)' // mean in highest tertile
			* step 2 - linear transformation
			cap drop z3`X' // I name the continuous variable z3 prefix
			gen z3`X'  = (`X'-`mean2')/(`mean2'-`mean1') if `X'<`mean2'
			replace z3`X' = (`X'-`mean2')/(`mean3'-`mean2') if `X'>=`mean2'
			* stepm 3 - make a spline at 0
			gen z3`X's1 = z3`X' if z3`X'<0
			gen z3`X's2 = z3`X' if z3`X'>=0
			replace z3`X's1 = 0 if z3`X'>=0
			replace z3`X's2 = 0 if z3`X'<0
			noisily di "Generated z3`X', z3`X's1, and z3`X's2" 
			noisily di _col(3) "as tertile mean centering and piecewise standardization with linear spline."
			noisily di _col(3) "Using z3`X's1 and z3`X's2 in a regression model, their associated"
			noisily di _col(3) "coefficients have the same interpretation as comparing the bottom and"
			noisily di _col(3) "top tertiles, but they are linear splines and there is no information loss." _n
			gen _t1`X' = `X' < `t1'
			gen _t2`X' = `X'>= `t1' & `X'<`t2'
			gen _t3`X' = `X'>=`t2' & missing(`X')~=1
			noisily di _col(3) "Also, generated _t1`X', _t2`X', and _t3`X' dummies indicating"
			noisily di _col(3) "membership in tertilles given if/in"
		}
	}
   mac shift 1
}
end

