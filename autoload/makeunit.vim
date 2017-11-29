function! makeunit#CreateUnitTest()
    " Construct the appropriate path and filename for the unit test
    let filepath = simplify(expand('%'))
    let testdir = substitute(fnamemodify(filepath, ':h'), 'src/main', 'src/test', '')
    let classname = makeunit#GetClassName()
    if empty(classname)
        echoerr 'Could not determine class name'
        return
    endif
    let testfile = simplify(printf('%s/%sTest.java', testdir, classname))

    " If the unit test already exists, open it and stop
    if filereadable(testfile)
        echoerr 'File "' . testfile . '"already exists'
        exec 'edit ' . fnameescape(testfile)
        return
    endif

    " Create directory if it doesn't exist
    if !isdirectory(testdir)
        call mkdir(testdir, 'p')
    endif

    " Get package and method names before changing buffers
    let package = makeunit#GetPackage()
    let methods = makeunit#GetPublicMethods()

    " Open unit-test file
    exec 'edit ' . fnameescape(testfile)
    
    " Create the code template
    if !empty(package)
        call setline(1, 'package ' . package . ';')
        call append(line('$'), '')
    endif

    for import in g:makeunit_imports
        call append(line('$'), 'import ' . import . ';')
    endfor
    call append(line('$'), '')
    
    call append(line('$'), [ printf('public class %sTest {', classname), '' ]) 

    for method in methods
        let method = substitute(method, '.*', '\u\0', '')
        call append(
\           line('$'), 
\           [ "\t@Test", printf("\tpublic void test%s () {", method), "\t}", '' ]
\       )
    endfor

    call append(line('$'), '}')
endfunction

function! makeunit#FindAndMatch(searchpat, matchpat)
    let cursave = getcurpos()
    let myline = search(a:searchpat)
    if myline == '0'
        return ''
    endif
    call setpos('.', cursave)
    return matchstr(getline(myline), a:matchpat)
endfunction

function! makeunit#GetClassName()
    return makeunit#FindAndMatch('^\s*public\s\+class', 'class\s\+\zs\I\i*\ze')
endfunction

function! makeunit#GetPackage()
    return makeunit#FindAndMatch('^\s*package', 'package\s*\zs\S\+\ze\s*;')
endfunction

function! makeunit#GetPublicMethods()
    call cursor(0, 0)
    let type_pat = '\%( \)'
    let methods = []
    for i in range(line('$'))
        let mymatch = matchstr(getline(i + 1), '^\s*public\s\+.*\s\zs\I\i*\ze\s*(')
        if !empty(mymatch)
            call add(methods, mymatch)
        endif
    endfor
    return methods
endfunction
