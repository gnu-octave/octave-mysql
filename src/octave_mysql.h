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


#ifndef OCTAVE_MYSQL_H
#define OCTAVE_MYSQL_H

#include <iostream>
#include <sstream>
#include <ctype.h>
#include <cmath>
#include <octave/oct.h>
#include <octave/version.h>
#include <octave/defun-dld.h>

#ifdef HAVE_CONFIG_H
#  include "./config.h"
#endif

#include <mysql.h>

class octave_mysql : public OCTAVE_BASE_CLASS
{
public:
  /**
   * default constructor 
   */
  octave_mysql ();

  /**
   * create object
   */
  octave_mysql (const std::string &filename, const std::string &mode);

  /**
   * deconstructor
   */
  ~octave_mysql (void);

  // interface functions
  bool create (const std::string &hostname, int port, const std::string &username, const std::string &password, const std::string database, int flags, unsigned int to);
  void close (void);
  bool is_open() const;
  std::string getMessage() const;
  bool run (const std::string &query, octave_value &v);
  bool rollback ();
  bool commit ();

  /**
   * Various properties of the octave_base_value datatype.
   */
  bool is_constant (void) const { return true;}
  bool is_defined (void) const { return true;}
  bool is_object (void) const { return true; }

  // required to use subsasn
  //string_vector map_keys (void) const { return fieldnames; }
  dim_vector dims (void) const { static dim_vector dv(1, 1); return dv; }

  octave_base_value * clone (void) const;
  octave_base_value * empty_clone (void) const;
  octave_base_value * unique_clone (void);

 /**
  * Overloaded methods to print
  */
  void print (std::ostream& os, bool pr_as_read_syntax = false) const;
  void print (std::ostream& os, bool pr_as_read_syntax = false); 
  void print_raw (std::ostream& os, bool pr_as_read_syntax) const;

 /**
  * overloaded methods to get properties
  */
  octave_value_list subsref (const std::string& type, const std::list<octave_value_list>& idx, int nargout);

  octave_value subsref (const std::string& type, const std::list<octave_value_list>& idx)
  {
    octave_value_list retval = subsref (type, idx, 1);
    return (retval.length () > 0 ? retval(0) : octave_value ());
  }

  octave_value subsasgn (const std::string& type, const std::list<octave_value_list>& idx, const octave_value& rhs);

private:
  octave_mysql (const octave_mysql &);

  //SQLHENV env;
  //SQLHDBC dbc;
  MYSQL *dbc;

  std::string autocommit;
  unsigned int timeout;

  std::string db_name;
  std::string db_ver;
  std::string db_driver_name;
  std::string db_driver_ver;

  std::string message;

//  string_vector fieldnames;
#ifdef DECLARE_OCTAVE_ALLOCATOR
  DECLARE_OCTAVE_ALLOCATOR
#endif
  DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA
};


#endif // OCTAVE_MYSQL_H
