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

    " Create the code template
    let package = makeunit#GetPackage()
    let methods = makeunit#GetPublicMethods()
    let tb = makeunit#NewTemplateBuilder(classname, g:makeunit_use_allman_style)
    if !empty(package)
        call tb.set_package(package)
    endif
    for import in g:makeunit_imports
        call tb.add_import(import)
    endfor
    for import in g:makeunit_static_imports
        call tb.add_static_import(import)
    endfor
    for method in methods
        call tb.add_stub(method)
    endfor

    " Open unit-test file
    exec 'edit ' . fnameescape(testfile)
    " Make sure opening the file succeeded
    if expand('%') ==# testfile
        call setline(1, tb.to_lines())
        " Indent buffer and show current file
        silent normal! gg=G
    endif
endfunction

function! makeunit#NewTemplateBuilder(class, use_allman_style)
    if empty(a:class)
        echoerr 'Class must be provided'
        return
    endif
    let tb = { 'class' : a:class, 'package' : '', 'imports' : [],
\       'static_imports' : [], 'methods' : [], 'allman' : a:use_allman_style }

    function tb.set_package(package)
        let self.package = a:package
    endfunction

    function tb.add_import(import)
        call add(self.imports, a:import)
    endfunction

    function tb.add_static_import(import)
        call add(self.static_imports, a:import)
    endfunction

    function tb.add_stub(method)
        call add(self.methods, a:method)
    endfunction

    function tb._add_line(line)
        call add(self._lines, a:line)
    endfunction

    function tb._add_brace_line(line)
        if self.allman
            call self._add_line(a:line)
            call self._add_line('{')
        else
            call self._add_line(a:line . ' {')
        endif
    endfunction

    function tb._add_space()
        if !empty(self._lines) && !empty(self._lines[-1])
            call add(self._lines, '')
        endif
    endfunction

    function tb.to_lines()
        let self._lines = []

        if !empty(self.package)
            call self._add_line(printf('package %s;', self.package))
            call self._add_space()
        endif

        for import in self.imports
            call self._add_line(printf('import %s;', import))
        endfor
        call self._add_space()

        for import in self.static_imports
            call self._add_line(printf('import static %s;', import))
        endfor
        call self._add_space()

        call self._add_brace_line(printf('public class %sTest', self.class))
        call self._add_space()

        for method in self.methods
            " fooBar => testFooBar
            let method = 'test' . substitute(method, '.*', '\u\0', '')
            call self._add_line('@Test')
            call self._add_brace_line(printf('public void %s()', method))
            call self._add_line('}')
            call self._add_space()
        endfor

        call self._add_line('}')

        return self._lines
    endfunction

    return tb
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

" vim: set foldmarker=function,endfunction foldmethod=marker foldlevel=0:
