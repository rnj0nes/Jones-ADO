*! version 1.0.1  30mar2009  Ben Jann

program r
    version 9.2
    if `"${Rdoc_docname}"'=="" {
        di as txt "(Rdoc not initialized; nothing to do)"
        exit
//        di as error "rdoc not initialized"
//        exit 499
    }
    mata: texdoc_fput(st_global("Rdoc_docname"))
end

version 9.2
mata:
mata set matastrict on

void texdoc_fput(string scalar fn)
{
    real scalar fh

    fh = fopen(fn, "a")
    fput(fh, st_local("0"))
    fclose(fh)
}

end
