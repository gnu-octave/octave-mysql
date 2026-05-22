// Copyright (C) 2026 John Donoghue <john.donoghue@ieee.org>
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation; either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program; if not, see <http://www.gnu.org/licenses/>.

#include <iostream>
#include <sstream>
#include <ctype.h>
#include <cmath>
#include <octave/oct.h>
#include <octave/version.h>
#include <octave/defun-dld.h>

#include "octave/ov-struct.h"

#ifdef HAVE_CONFIG_H
#  include "./config.h"
#endif

#ifdef HAVE_OCTAVE_INTERPRETER_H
# include <octave/interpreter.h>
#endif

#include "octave_mysql.h"

static bool type_loaded = false;

void
init_types(void)
{
  if (!type_loaded)
    {
     octave_mysql::register_type ();
     type_loaded = true;
    }
}

// PKG_ADD: autoload ("__mysql_pkg_lock__", "__octave_mysql__.oct");
// PKG_ADD: __mysql_pkg_lock__(1);
// PKG_DEL: __mysql_pkg_lock__(0);
#ifdef DEFMETHOD_DLD
DEFMETHOD_DLD (__mysql_pkg_lock__, interp, args, , "internal function")
{
  octave_value retval;
  if (args.length () >= 1)
    {
      if (args(0).int_value () == 1)
        interp.mlock();
      else if (args(0).int_value () == 0 &&  interp.mislocked("__mysql_pkg_lock__"))
        interp.munlock("__mysql_pkg_lock__");
    }
  return retval;
}
#else
DEFUN_DLD(__mysql_pkg_lock__, args, ,  "internal function")
{
  octave_value retval;
  return retval;
}
#endif

// PKG_ADD: autoload ("__mysql_create__", "__octave_mysql__.oct");
DEFUN_DLD(__mysql_create__, args, nargout,
"-*- texinfo -*-\n \
@deftypefn {Function File} {} __mysql_create__\n \
Private function\n \
@end deftypefn")
{
  if ( args.length() != 7 || !args (0).is_string () || !args(1).isnumeric() || !args (2).is_string () || !args (3).is_string () || !args (4).is_string () || !args(5).isnumeric() || !args(6).isnumeric())
    {
      print_usage ();
      return octave_value();
    }

  std::string host = args (0).string_value();
  int port = args (1).int_value();
  std::string user = args (2).string_value();
  std::string pass = args (3).string_value();
  std::string db = args (4).string_value();
  int flags = args (5).int_value();
  int timeout = args (6).int_value();

  init_types ();

  octave_mysql * retvalue = new octave_mysql ();

  if ( retvalue->create (host, port, user, pass, db, flags, timeout) == false )
    {
      error ("Error connecting: %s", retvalue->getMessage().c_str());
      delete retvalue;
      return octave_value ();
    }

  return octave_value (retvalue);

}

// PKG_ADD: autoload ("__mysql_close__", "__octave_mysql__.oct");
DEFUN_DLD(__mysql_close__, args, nargout,
"-*- texinfo -*-\n \
@deftypefn {Function File} {} __mysql_close__\n \
Private function\n \
@end deftypefn")
{
  init_types ();

  if (args.length () != 1 || 
      args(0).type_id () != octave_mysql::static_type_id ())
    {
      print_usage ();
      return octave_value (false);  
    }

  octave_mysql * db = NULL;

  const octave_base_value& rep = args (0).get_rep ();

  db = &((octave_mysql &)rep);

  db->close();

  return octave_value (true);
}

// PKG_ADD: autoload ("__mysql_run__", "__octave_mysql__.oct");
DEFUN_DLD(__mysql_run__, args, nargout,
"-*- texinfo -*-\n \
@deftypefn {Function File} {} __mysql_run__\n \
Private function\n \
@end deftypefn")
{
  init_types ();

  if (args.length () != 2 || 
      args(0).type_id () != octave_mysql::static_type_id () ||
      !args(1).is_string())
    {
      print_usage ();
      return octave_value (false);  
    }

  octave_mysql * db = NULL;

  const octave_base_value& rep = args (0).get_rep ();

  db = &((octave_mysql &)rep);
  std::string query = args (1).string_value ();

  octave_value v;
 
  if(db->run(query, v))
    {
      return octave_value (v);
    }
  else
    {
      error ("Could not run query: %s", db->getMessage().c_str());
      return octave_value();
    }
}

// PKG_ADD: autoload ("__mysql_rollback__", "__octave_mysql__.oct");
DEFUN_DLD(__mysql_rollback__, args, nargout,
"-*- texinfo -*-\n \
@deftypefn {Function File} {} __mysql_rollback__\n \
Private function\n \
@end deftypefn")
{
  init_types ();

  if (args.length () != 1 || 
      args(0).type_id () != octave_mysql::static_type_id ())
    {
      print_usage ();
      return octave_value (false);  
    }

  octave_mysql * db = NULL;

  const octave_base_value& rep = args (0).get_rep ();

  db = &((octave_mysql &)rep);

  if(db->rollback())
    {
      return octave_value ();
    }
  else
    {
      error ("Could not run rollback: %s", db->getMessage().c_str());
      return octave_value();
    }
}

// PKG_ADD: autoload ("__mysql_commit__", "__octave_mysql__.oct");
DEFUN_DLD(__mysql_commit__, args, nargout,
"-*- texinfo -*-\n \
@deftypefn {Function File} {} __mysql_commit__\n \
Private function\n \
@end deftypefn")
{
  init_types ();

  if (args.length () != 1 || 
      args(0).type_id () != octave_mysql::static_type_id ())
    {
      print_usage ();
      return octave_value (false);  
    }

  octave_mysql * db = NULL;

  const octave_base_value& rep = args (0).get_rep ();

  db = &((octave_mysql &)rep);

  if(db->commit())
    {
      return octave_value ();
    }
  else
    {
      error ("Could not run commit: %s", db->getMessage().c_str());
      return octave_value();
    }
}

