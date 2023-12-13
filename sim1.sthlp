{smcl}
{hline}
Help file for {hi:sim1}
{hline}

{p 4 4 2}
Generate variables with specified correlation. The program
can generate two variables, or a second variable can
be generated having a specified correlation with a given variable.
By default, two variables (x and y) are added to the active
data file. Alternative names can be specified.

{hline}

{p 8 17 2}
{cmd: sim1} , {hi:r(}{it:string}{hi:)}
 [ {cmd:var1(}{it:string}{hi:)}
   {cmd:obs(}{it:interger 1000}{hi:)}
   {cmd:sample(}{it:string}{hi:)}
   {cmd:savey(}{it:string}{hi:)} 
   {cmd:savex(}{it:string}{hi:)} 
   {hi:rank} 
   {hi:howell} ]
 
{title:Required commands}

{p 0 8 2}
{cmd:r} - Input the correlation the two variables are supposed to have.

{title:Options}

{p 0 8 2}
{cmd:var1(}{it:string}{hi:)} - name the variable a second 
variable is to be correlated with. The variable named must
exist in the active data set.

{p 0 8 2}
{cmd:obs} - enter the number of observations to be used
in the generation. The default is 1000.

{p 0 8 2}
{cmd:sample(}{it:string}{hi:)} - use the same syntax as in the
STATA command {hi:sample}.  For example, if you wanted to sample 30
persons from the larger data set, use {hi:sample(30 , count)}.

{p 0 8 2}
{cmd:savey(}{it:string}{hi:)} and {cmd:savex(}{it:string}{hi:)} - enter 
a name for the generated variable(s) to be saved in the active 
data set. The names must not exist in the currently active data set. 

{p 0 8 2}
{cmd:rank} - rescales the second variable using a Blom 
transformation.

{p 0 8 2}
{cmd:howell} - calls Howell's algorithm instead of the default, which is
Paul Barrett's algorithm. See references.

{title:Description}

{p 4 4 2}
{cmd:sim1} generates simulated data. It uses Paul Barrett's algorithm,
but Howell's can be used by invoking the {hi:howell} option
(see references). Barrett's algorithm is:


          x  = given (or generated as N(0,1))
          y  = generated as N(0,1)
          y' = r*x+sqrt(1-r^2)*y
          x and y' are correlated r

{p 4 4 2}
After calcuation, y' is standardized with respect to the mean 
and variance of x, and y is replaced with the rescaled y'. 
Alternatively, if the {hi:rank} option is invoked, y' is 
rescaled using a Blom transformation. 


{title:Examples}

. {hi:sim1 , r(.5)}

/* start irt sim program */

     clear
     set obs 1000
     gen q = invnorm(uniform())

     local items = 50
     foreach i of numlist 1/`items' {
        local threshold = invnorm(.25*(uniform()))
        sim1 , r(.707) var1(q) savey(y`i') rank 
        gen u`i' = y`i'>= `threshold'
     }

     order q y* u*
     gen id = _n
     runparscale u1-u`items' , id(id) 
     corr q theta
     scatter q theta

/* end irt sim program */


{title:References}

{p 8 8 2}
This program is based on a formula presented in Paul Barrett's 
unpublished essay "Likert Response Range and Correlation
Attenuation". The essay can be downloaded from Paul Barrett's
web page {hi:www.pbarrett.net} (last accessed 15 Oct 2005).
Paul Barrett references David Howell's web page.


{title:Author}

{p 8 8 2}
Richard N Jones, ScD{break}
jones@hrca.harvard.edu{break}
Develped with the support of NIH grants P60AG008812 and R01AG025308


{p 8 8 2}
Contact Paul Crane, MD, MPH 
(pcrane@u.washington.edu) for information 
about {hi:prepar} and Paul and/or Rich Jones 
for information about {hi:runparscale}.





