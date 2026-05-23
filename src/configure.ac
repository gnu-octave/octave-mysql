#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.
#
### Copyright (C) 2026 John Donoghue <john.donoghue@ieee.org>
###
### This program is free software; you can redistribute it and/or
### modify it under the terms of the GNU General Public License as
### published by the Free Software Foundation; either version 3 of the
### License, or (at your option) any later version.
###
### This program is distributed in the hope that it will be useful,
### but WITHOUT ANY WARRANTY; without even the implied warranty of
### MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
### General Public License for more details.
###
### You should have received a copy of the GNU General Public License
### along with this program; if not, see
### <http://www.gnu.org/licenses/>.

AC_PREREQ([2.67])
AC_INIT([Octave MySQL], [0.0.1])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_MACRO_DIRS([m4])
AH_TOP([#include "undef-ah-octave.h"])

AC_PROG_SED
AC_PROG_GREP

AC_CHECK_TOOL([MKOCTFILE], [mkoctfile], [none])
if [ test "x$MKOCTFILE" = "xnone" ]; then
  AC_MSG_ERROR([*** 'mkoctfile' not found.])
fi
AC_CHECK_TOOL([OCTAVE_CONFIG], [octave-config] ,[])
test -z "$OCTAVE_CONFIG" && OCTAVE_CONFIG=$MKOCTFILE

# try get around possible spaces in the path
if test "X${IGNORE_MINGW_PATH_MODIFICATION}" == "X"; then
  MSYSTEM="${MSYSTEM}"
else
  MSYSTEM="none"
fi

if test "X${IGNORE_MINGW_PATH_MODIFICATION}" == "X"; then
case X$MSYSTEM in
  XMINGW*)
    # try demangle spaces in escaped input strings
    MKOCTFILE=`echo $MKOCTFILE | $SED "s,\\\\\ ,?,g"`
    OCTAVE_CONFIG=`echo $OCTAVE_CONFIG | $SED "s,\\\\\ ,?,g"`
    ;;
  *)
    ;;
esac
fi

CXX=`${MKOCTFILE} -p CXX`

# The check for flags to enable C++11 is broken with a C++20 compiler (because
# the type of u8"" literals changed) in autoconf before version 2.73.
# Octave requires C++11 since version 4.2, so it is enabled by the CXX as
# returned by mkoctfile. Skip broken check which would demote to C++11.
ac_cv_prog_cxx_cxx11=""

save_CXX="$CXX"
AC_PROG_CXX
AC_PROG_CXXCPP

AC_LANG(C++)

# check can access std c files
AC_CHECK_HEADERS([string.h])

## octave API tests
save_CXX="$CXX"
save_CXXFLAGS="$CXXFLAGS"
save_LIBS="$LIBS"
save_LDFLAGS="$LDFLAGS"

CXX=`${MKOCTFILE} -p CXX`
OCTINCLUDEDIR="${OCTINCLUDEDIR:-`$MKOCTFILE -p OCTINCLUDEDIR`}/.."
OCTLIBDIR=${OCTLIBDIR:-`$MKOCTFILE -p OCTLIBDIR`}

case X$MSYSTEM in
  XMINGW64*)
    OCTAVE_HOME=`${MKOCTFILE} -p OCTAVE_HOME | $SED 's,\\\\,/,g'`
    # change \ to / and replace octave home part with mingw part
    OCTINCLUDEDIR=`echo $OCTINCLUDEDIR | $SED -e 's,\\\\,/,g' -e "s,${OCTAVE_HOME},/mingw64,g"`
    OCTLIBDIR=`echo $OCTLIBDIR | $SED -e 's,\\\\,/,g' -e "s,${OCTAVE_HOME},/mingw64,g"`
    ;;
  XMINGW32*)
    OCTAVE_HOME=`${MKOCTFILE} -p OCTAVE_HOME | $SED 's,\\\\,/,g'`
    # change \ to / and replace octave home part with mingw part
    OCTINCLUDEDIR=`echo $OCTINCLUDEDIR | $SED -e 's,\\\\,/,g' -e "s,${OCTAVE_HOME},/mingw32,g"`
    OCTLIBDIR=`echo $OCTLIBDIR | $SED -e 's,\\\\,/,g -e "s,${OCTAVE_HOME},/mingw32,g"'`
    ;;
  *)
    ;;
esac

CXXFLAGS="-I$OCTINCLUDEDIR $CXXFLAGS"
LDFLAGS="-L$OCTLIBDIR $LDFLAGS"
LIBS="-loctinterp $LIBS"

# includes
AC_CHECK_HEADERS([octave/interpreter.h octave/oct-time.h],
  [],
  [],
  [#include <octave/oct.h>]
)

dnl since we Octave 6+, there are not many types that have changed
OF_OCTAVE_LIST_ALT_SYMS([

[dnl
  [feval],
  [octave::feval],
  [[octave::feval ("date");]],
  [OCTAVE__FEVAL],
  [[#include <octave/parse.h>]],
  [[#include <octave/parse.h>]]
],

[dnl
  [octave_time],
  [octave::sys::time],
  [[octave::sys::time t;]],
  [OCTAVE__TIME],
  [[#include <octave/oct-time.h>]],
  [[#include <octave/oct-time.h>]]
],

[dnl
  [octave_base_value],
  [octave_base_dld_value],
  [[octave_base_dld_value tmp;]],
  [OCTAVE_BASE_CLASS],
  [],
  []
]

],[oct-alt-includes.h])

AC_MSG_CHECKING([for octave_base_value count field])
octave_count_field=count
AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[
   #include <octave/oct.h>
   #ifdef HAVE_CONFIG_H
   #  include "config.h"
   #endif
   class test_base_class : public octave_base_value
   {
   public:
     test_base_class() {}
     ~test_base_class() {}
     void test() { m_count ++; }
     bool is_object (void) const { return true; }
   };
  ]], [
    test_base_class t;  t.is_object();
  ])],
 [octave_count_field=m_count],
 [octave_count_field=count]
)
AC_MSG_RESULT([$octave_count_field])
AC_DEFINE_UNQUOTED([OV_COUNT],$octave_count_field,[octave_base_value ref count field])

CC=$save_CXX
CXXFLAGS=$save_CXXFLAGS
LIBS="$save_LIBS"
LDFLAGS="$save_LDFLAGS"

PKG_PROG_PKG_CONFIG

have_mysql=no
if test "x$PKG_CONFIG" != "x"; then
  AC_MSG_CHECKING([pkg-config for libmariadb or mysqlclient])

  PKG_CHECK_EXISTS([libmariadb], [
    MYSQL_CFLAGS=`$PKG_CONFIG --cflags libmariadb`
    MYSQL_LIBS=`$PKG_CONFIG --libs libmariadb`
    have_mysql=yes
  ], [
    PKG_CHECK_EXISTS([mysqlclient], [
      MYSQL_CFLAGS=`$PKG_CONFIG --cflags mysqlclient`
      MYSQL_LIBS=`$PKG_CONFIG --libs mysqlclient`
      have_mysql=yes
    ])
  ])
  AC_MSG_RESULT($have_mysql)
fi

# fallover check for mariadb_config
if test "x$have_mysql" != "xyes"; then
  # mariadb
  AC_CHECK_TOOL([MARIADB_CONFIG], [mariadb_config], [none])
  if [ test "x$MARIADB_CONFIG" != "xnone" ]; then
    have_mysql=yes
    MYSQL_CFLAGS=`$MARIADB_CONFIG --cflags`
    MYSQL_LIBS=`$MARIADB_CONFIG --libs`
  fi
fi

# fallover check for mysql_config
if test "x$have_mysql" != "xyes"; then
  # mysqlclient
  AC_CHECK_TOOL([MYSQL_CONFIG], [mysql_config], [none])
  if [ test "x$MYSQL_CONFIG" != "xnone" ]; then
    have_mysql=yes
    MYSQL_CFLAGS=`$MYSQL_CONFIG --cflags`
    MYSQL_LIBS=`$MYSQL_CONFIG --libs`
  fi
fi

if [ test "x$have_mysql" != "xyes" ]; then
  AC_MSG_ERROR([*** mariadb or mysql library information not found.])
fi

AC_SUBST([MYSQL_CFLAGS])
AC_SUBST([MYSQL_LIBS])

dnl Save current compilation flags
save_CPPFLAGS="$CPPFLAGS"
CPPFLAGS="$CPPFLAGS $MYSQL_CFLAGS"

dnl Verify mysql.h can be included
AC_CHECK_HEADER([mysql.h], [have_mysql_h="yes"], [have_mysql_h="no"])

dnl Restore previous compilation flags
CPPFLAGS="$save_CPPFLAGS"

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
AC_MSG_NOTICE([

$PACKAGE_NAME is configured with:
  MySQL LIBS:   $MYSQL_LIBS
  MYSQL CFLAGS: $MYSQL_CFLAGS
])

