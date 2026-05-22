#include "octave_mysql.h"
#include <iomanip>
#include <sstream>

#ifdef DEFINE_OCTAVE_ALLOCATOR 
DEFINE_OCTAVE_ALLOCATOR (octave_mysql);
#endif
DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA (octave_mysql, "octave_mysql", "octave_mysql");

static std::string make_version_string(unsigned long version)
{
  // major_version*10000 + release_level*100 + sub_version
  int major_version = version / 10000;
  int release_level = (version / 100) % 100;
  int sub_version = version % 100;

  std::ostringstream os;

  os << major_version
     << '.'
     << release_level
     << '.'
     << sub_version;

  return os.str();
}

octave_mysql::octave_mysql ()
{
  dbc = 0;
//  dbc = SQL_NULL_HENV;
//  env = SQL_NULL_HENV;
}

octave_mysql::octave_mysql (const octave_mysql &s)
{
  // should never be called
}

octave_mysql::~octave_mysql(void)
{
  close ();
}

octave_base_value *
octave_mysql::empty_clone (void) const 
{
  return new octave_mysql();
}

octave_base_value *
octave_mysql::clone (void) const 
{
  return new octave_mysql (*this);
}

octave_base_value *
octave_mysql::unique_clone (void) 
{
  OV_COUNT++;
  return this;
}

void
octave_mysql::print (std::ostream& os, bool pr_as_read_syntax) const
{
  print_raw (os, pr_as_read_syntax);
  newline (os);
}

void
octave_mysql::print (std::ostream& os, bool pr_as_read_syntax)
{
  print_raw (os, pr_as_read_syntax);
  newline (os);
}

void
octave_mysql::print_raw (std::ostream& os, bool pr_as_read_syntax) const
{
  os << "  Database with Properties:"; newline(os);
  os << "                  AutoCommit: " << autocommit; newline(os);
  os << "                LoginTimeout: " << timeout; newline(os);
  os << "  Database and Driver Information:"; newline(os);
  os << "         DatabaseProductName: " << db_name; newline(os);
  os << "      DatabaseProductVersion: " << db_ver; newline(os);
  os << "                  DriverName: " << db_driver_name; newline(os);
  os << "               DriverVersion: " << db_driver_ver; newline(os);
}

octave_value_list
octave_mysql::subsref (const std::string& type, const std::list<octave_value_list>& idx, int nargout)
{
  octave_value_list retval;
  int skip = 1;

  switch (type[0])
    {
    default:
      error ("octave_mysql object cannot be indexed with %c", type[0]);
      break;
    case '.':
      {
        std::string prop = (idx.front ()) (0).string_value();
	if (prop == "Database")
	  retval(0) = db_name;
	else if (prop == "IsOpen")
	  retval(0) = octave_value(is_open());
	else if (prop == "Message")
	  retval(0) = octave_value(getMessage());
	else if (prop == "AutoCommit")
	  retval(0) = autocommit;
	else if (prop == "LoginTimeout")
	  retval(0) = octave_value(timeout);
	else
	  error ("Unkown property '%s'", prop.c_str());
      }
      break;
    }

  if (idx.size () > 1 && type.length () > 1)
    retval = retval (0).next_subsref (nargout, type, idx, skip);

  return retval;
}

octave_value
octave_mysql::subsasgn (const std::string& type, const std::list<octave_value_list>& idx, const octave_value& rhs)
{
  octave_value retval;

  switch (type[0])
    {
    default:
      error ("octave_mysql object cannot be indexed with %c", type[0]);
      break;

    // Only AutoCommit property isnt readonly
    case '.':
      if (type.length () == 1)
        {
          octave_value prop = (idx.front ()) (0);
	  if (!prop.is_string() || prop.string_value() != "AutoCommit")
	    {
              error ("octave_mysql Unknown property");
	    }
          else if(!rhs.is_string() || (rhs.string_value() != "on" && rhs.string_value() != "off"))
            {
              error ("Expected AutoCommit as 'on' or 'off'");
            }
	  else
            {
              std::string  newautocommit = rhs.string_value();
              if (newautocommit != autocommit)
                {
                  int rc = 0;
                  if (newautocommit == "off")
                    rc = mysql_autocommit(dbc, 0);
		  else
                    rc = mysql_autocommit(dbc, 1);

		  if (rc == 0)
                    autocommit = newautocommit;
                }
            }
            OV_COUNT++;
            retval = octave_value (this);
        }
      else
        {
          error ("octave_mysql invalid index");
        }
    }
  return retval;
}


// mysql functionality
bool
octave_mysql::create (
  const std::string &hostname, int port, const std::string &username, const std::string &password,
  const std::string database, int flags, unsigned int to)
{
  autocommit = "off";
  timeout = to;

  // Initialize MySQL handle
  MYSQL *conn = mysql_init(nullptr);

  if (!conn)
    {
      std::cerr << "mysql_init() failed" << std::endl;
      return EXIT_FAILURE;
    }

  mysql_options(conn,
      MYSQL_OPT_CONNECT_TIMEOUT,
      &to);

  // Connect to database
  MYSQL *result = mysql_real_connect(conn,
                                     hostname.c_str(),
                                     username.c_str(),
                                     password.c_str(),
                                     database.c_str(),
                                     port,
                                     nullptr,       // unix socket
                                     flags);            // flags

  if (!result)
    {
      message = mysql_error(conn);
      mysql_close(conn);
    }
  else
    {
      dbc = conn;
    }

  db_ver = mysql_get_server_info(conn);
  if (db_ver.find("Maria") != std::string::npos)
    db_name = "MariaDB";
  else
    db_name = "MySQL";
#ifdef LIBMARIADB
  db_driver_name = "MariaDB Connector/C";
#else
  db_driver_name = "MySQL Connector/C";
#endif
  db_driver_ver = mysql_get_client_info();

  return result != 0;
}

void
octave_mysql::close (void)
{
  if (dbc != 0)
    {
      mysql_close(dbc);
      dbc = 0;
    }
}

bool
octave_mysql::is_open () const
{
  if (dbc)
    return true;
  else
    return false;
}

std::string
octave_mysql::getMessage() const
{
  return message;
}

octave_value to_octave(const MYSQL_FIELD &f, const char *data, unsigned int length)
{
  if (!data)
    return octave_value(Matrix(0,0));

  if(f.type == MYSQL_TYPE_TINY)
  {
    if (f.flags & UNSIGNED_FLAG)
      return octave_value((uint8_t)std::atoi(data));
    else
      return octave_value((int8_t)std::atoi(data));
  }
  else
  {
	  return octave_value(std::string(data, length));
  }
}

bool
octave_mysql::run (const std::string &query, octave_value &v)
{
  v = Cell();

  if (mysql_query(dbc, query.c_str()))
    {
      message = mysql_error(dbc);
      return false;
    }

  MYSQL_RES *res = mysql_store_result(dbc);

  if (!res)
    {
       if (mysql_field_count(dbc) != 0)
         {
           message = mysql_error(dbc);
           return false;
         }
    }
  else 
    {
      MYSQL_ROW row_data;
      unsigned int cols = mysql_num_fields(res);

      MYSQL_FIELD *fields = mysql_fetch_fields(res);

      Cell coldata[cols];

      octave_idx_type row = 0;
      octave_value value;
      while ((row_data = mysql_fetch_row(res)))
        {
          unsigned long *lengths;
          lengths = mysql_fetch_lengths(res);

          for (unsigned int c = 0; c < cols; c++)
            {
              value = to_octave(fields[c], row_data[c], lengths[c]);
              if (coldata[c].numel() <= row)
                {
                  coldata[c].resize(dim_vector(2*row+32, 1));
                }
              coldata[c](row) = value;
            }

          row ++;
        }

      // set the data
      octave_map om;
      for (unsigned int c =0; c < cols; c++)
        {
          coldata[c].resize(dim_vector(row, 1));
          om.assign(fields[c].name, octave_value(coldata[c]));
        }

      mysql_free_result(res);
      v = om;
    }

  return true;
}

bool
octave_mysql::rollback (void)
{
  bool ok = true;
  if (dbc)
    {
      mysql_rollback(dbc);
    }
  return ok;
}

bool
octave_mysql::commit (void)
{
  bool ok = true;
  if (dbc)
    {
      mysql_commit(dbc);
    }
  return ok;
}
