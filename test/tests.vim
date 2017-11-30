let s:num_tests = 0

function! Ok(ok, ...)
    if a:ok != 0 && a:ok != 1
        echoerr 'Non-boolean passed to Ok()'
        return
    endif
    let s:num_tests += 1
    if !a:ok
        echoerr 'not ok ' . s:num_tests . (a:0 ? " " . a:1 : "")
    else
        echo 'ok ' . s:num_tests . (a:0 ? " " . a:1 : "")
    endif
endfunction

function! TestTemplateBuilder()
    let tb = makeunit#NewTemplateBuilder('Foo', 1)
    call Ok(tb.to_lines() == [
\       'public class FooTest', '{', '', '}'
\   ], 'Allman style')

    let tb = makeunit#NewTemplateBuilder('Foo', 0)
    call Ok(tb.to_lines() == [
\       'public class FooTest {', '', '}'
\   ], 'Non-Allman style')

    call tb.set_package('com.example.test')
    call Ok(tb.to_lines() == [
\       'package com.example.test;', '',
\       'public class FooTest {', '', '}'
\   ], 'Package')

    call tb.add_import('org.junit.Test')
    call Ok(tb.to_lines() == [
\       'package com.example.test;', '',
\       'import org.junit.Test;', '',
\       'public class FooTest {', '', '}'
\   ], 'Import')
    call tb.add_import('org.junit.OtherTest')
    call Ok(tb.to_lines() == [
\       'package com.example.test;', '',
\       'import org.junit.Test;',
\       'import org.junit.OtherTest;', '',
\       'public class FooTest {', '', '}'
\   ], 'Imports')

    call tb.add_static_import('org.junit.AssertEqual')
    call Ok(tb.to_lines() == [
\       'package com.example.test;', '',
\       'import org.junit.Test;',
\       'import org.junit.OtherTest;', '',
\       'import static org.junit.AssertEqual;', '',
\       'public class FooTest {', '', '}'
\   ], 'Static import ')
    call tb.add_static_import('org.junit.AssertNotEqual')
    call Ok(tb.to_lines() == [
\       'package com.example.test;', '',
\       'import org.junit.Test;',
\       'import org.junit.OtherTest;', '',
\       'import static org.junit.AssertEqual;',
\       'import static org.junit.AssertNotEqual;', '',
\       'public class FooTest {', '', '}'
\   ], 'Static imports')

    let tb = makeunit#NewTemplateBuilder('Foo', 1)
    call tb.add_stub('method')
    call Ok(tb.to_lines() == [
\       'public class FooTest', '{', '',
\           '@Test', 'public void testMethod()', '{', '}', '',
\       '}'
\   ], 'Method stub (Allman)')

    let tb = makeunit#NewTemplateBuilder('Foo', 0)
    call tb.add_stub('method')
    call Ok(tb.to_lines() == [
\       'public class FooTest {', '',
\           '@Test', 'public void testMethod() {', '}', '',
\       '}'
\   ], 'Method stub (Non-Allman)')
    call tb.add_stub('otherMethod')
    call Ok(tb.to_lines() == [
\       'public class FooTest {', '',
\           '@Test', 'public void testMethod() {', '}', '',
\           '@Test', 'public void testOtherMethod() {', '}', '',
\       '}'
\   ], 'Method stub (Non-Allman)')
endfunction

function! RunTests()
    call TestTemplateBuilder()
endfunction
