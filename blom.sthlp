{smcl}
{hline}
Help file for {hi:blom}
{hline}

{p 4 4 2}
Generate a new variable, 
{cmd:{it:varname}_blom}, that 
is a Blom-transformed version of 
{it:varname}

{p 8 17 2}
{cmd: blom} {it:variable} [ if in ] , 
   [ {cmd:replace }
  ]

{p 4 4 2}
The Blom transformation is a rank based inverse normal transformation:

{p 4 4 2}
{cmd:{it:varname}_blom} = 
invnorm[(RANK[{it:varname}] - 3/8)
/ ({it:N} + 0.25)]

{p 4 4 2}
References:

{p 4 4 2}
Blom, G. (1958). Statistical estimates and transformed beta variables. New York: John Wiley & Sons, Inc.

{p 4 4 2}
Beasley, T. M., Erickson, S., & Allison, D. B. (2009). Rank-based inverse normal transformations are increasingly used, but are they merited? {it: Behavior genetics}, 39(5), 580-595.


{title:Optional commands}

{p 4 8 2}
{cmd: replace} - READ CAREFULLY
if replace is specified, {it:varname}
will be replaced with the blom-transformed
version of {it: varname}, and
{it:varname}_blom will not be
created. It is the default
behavior of this program to overwrite
{it:varname}_blom if it exists
before the command is issued.

{title:Author}

{p 8 8 2}
Richard N Jones, ScD{break}
jones@hsl.harvard.edu{break}







