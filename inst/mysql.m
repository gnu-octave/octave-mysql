## Copyright (C) 2026 John Donoghue <john.donoghue@ieee.org>
##
## This program is free software: you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see
## <https://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {} {@var{conn} =} mysql (@var{dbname}, @var{username}, @var{password})
## @deftypefnx {} {@var{conn} =} mysql (@var{username}, @var{password}, @var{propertyname}, @var{propertyvalue} @dots{})
## Create a MySQL database connection
##
## @subsubheading Inputs
## @table @code
## @item @var{dbname}
## Database name
## @item @var{username}
## Username for connecting to database.
## @item @var{password}
## Password for connecting to database.
## @item @var{propertyname}, @var{propertyvalue}
## Property names and values
## @end table
##
## Input property names can be:
## @table @asis
## @item Server
## Server lookup name or ip address (default is "localhost")
## @item PortNumber
## numeric port number (default 3306)
## @item DatabaseName
## Name of the database to connect to (default "")
## @item LoginTimeout
## Numeric timeout value (default 0)
## @end table
##
## @subsubheading Outputs
## @table @code
## @item @var{conn}
## A connection object for the connected database
## @end table
##
## @subsubheading Examples
## Open a connection to a MySQL Database "MySQLNative", using username/password root/matlab
## @example
## @code {
## db = mysql("MySQLNative", "root", "matlab");
## }
## @end example
##
## Using property name/values:
## @example
## @code {
## db = mysql("root", "matlab", "DatabaseName", "MySQLNative");
## }
## @end example
##
## @seealso{mysqldb.connection}
## @end deftypefn

function conn = mysql(varargin)
  if nargin < 3 || !ischar(varargin{1})
    error ("Expected database name, username, password or username, password and connection properties");
  endif

  # dbname, username, password
  if nargin == 3
    if ! (ischar(varargin{1}) && ischar(varargin{2}) && ischar(varargin{3}))
      error ("Expected table, username and password as strings")
    endif
  else
    # username, password, [pairs of properties]
    if ! (ischar(varargin{1}) && ischar(varargin{2}))
      error ("Expected username and password as strings")
    endif

    # not enough property pairs
    if mod(nargin, 2)
      error ("Expected username and password followed by property name,value pairs")
    endif

    if nargin > 2
      if !iscellstr (varargin (3:2:nargin))
        error ("expected property names to be strings");
      endif
    endif

    # verify properties in the connection object
  endif

  conn = mysqldb.connection(varargin{:});

endfunction

%!xtest
%! # will probally fail unless we actually have a db set for this
%! a = mysql("MySQLNative", "root", "matlab");
%! assert(isa(a, "mysqldb.connection"))
%! assert(isopen(a));
%! close(a);

%!error mysql()
%!error mysql("","")
%!error mysql("","", 1)
