# makeunit

My first Vim plug-in. It's very simple: It provides a `:MakeUnit` command which
generates a skeletal unit test. Version 1 is quick and dirty, and doesn't
attempt to handle edge cases (improperly formatted code, incorrect project
layout, incorrect usage).

# Use

From inside a Java source file containing a public class, the `:MakeUnit`
command will create a test class and populate it with stub methods
corresponding to each public method in the source file.

For example, with the following directory structure

    my-app
    `-- src
        `-- main
            `-- java
                `-- com
                    `-- example
                        `-- app
                            `-- App.java

`:MakeUnit` will create the necessary directories and the unit test like so

    my-app
    `-- src
        |-- main
        |   `-- java
        |       `-- com
        |           `-- example
        |               `-- app
        |                   `-- App.java
        `-- test
            `-- java
                `-- com
                    `-- example
                        `-- app
                            `-- AppTest.java

See the included help for more information. (TODO)

# Missing features

Issues and missing features that I might fix should I find the need to do so.

* Needs help documentation
* The logic for choosing where to place the test is extremely simple
* Assumption of JUnit `@Test`
