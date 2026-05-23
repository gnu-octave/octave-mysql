# Octave MySQL Toolkit

Native MYSQL database access for GNU Octave

## Overview

This is a basic mysql toolkit using and interface similar to
the Matlab Native MYSQL interface.

It provides functionality for the following functions:

* mysql - create a database connection
* close - close a sqlite database connection
* fetch - fetch data from a connection using sql
* execute - execute a non selecting sql statement 
* sqlfind - query info about a sqlite table
* sqlread - read a sqlite table
* sqlwrite - write to a sqlite table
* sqlupdate - update a sqlite table
* commit - commit transaction when not in autocommit mode
* rollback - rollback a transaction when not in autocommit mode
* isopen - verify the database is open

## Installing the Toolkit

The toolkit can be installed in Octave 6.0 and greater.  It has a dependency 
on the MYSQL client library (<https://dev.mysql.com/>), or MariaDB Client library
(<https://mariadb.org/>),
so one must be installed in order to successfully install the toolkit.

The toolkit can be installed in Octave 7.2+ using the command:

    pkg install -forge mysql

After installation, load the package in order to use it.

    pkg load mysql

**Note:** The package needs to loaded each time Octave is run in order to use the package. 

## Documentation

On newer versions of Octave, on loading the package the documentation will be available in the
Octave documentation pages.

The Documentation is also installed as a pdf in the installed package folder.

Online documentation is also available at
https://gnu-octave.github.io/octave-mysql/

## Reporting Bugs

Bugs can be filed on the [issue tracker](https://github.com/gnu-octave/octave-mysql/issues).
