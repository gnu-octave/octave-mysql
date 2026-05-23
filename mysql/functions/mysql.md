---
layout: "default"
permalink: "/functions/5_mysql/"
pkg_name: "mysql"
pkg_version: "0.0.1"
pkg_description: "Basic Octave implementation of MySQL toolkit"
title: "Mysql Toolkit - mysql"
category: "Support Functions"
func_name: "mysql"
navigation:
- id: "overview"
  name: "Overview"
  url: "/index"
- id: "Functions"
  name: "Function Reference"
  url: "/functions"
- id: "16_MYSQLconnection"
  name: "&nbsp;&nbsp;MYSQL connection"
  url: "/functions/#16_MYSQLconnection"
  subitems:
- id: "14_ImportingData"
  name: "&nbsp;&nbsp;Importing Data"
  url: "/functions/#14_ImportingData"
  subitems:
- id: "14_ExportingData"
  name: "&nbsp;&nbsp;Exporting Data"
  url: "/functions/#14_ExportingData"
  subitems:
- id: "19_DatabaseOperations"
  name: "&nbsp;&nbsp;Database Operations"
  url: "/functions/#19_DatabaseOperations"
  subitems:
- id: "17_SupportFunctions"
  name: "&nbsp;&nbsp;Support Functions"
  url: "/functions/#17_SupportFunctions"
  subitems:
- id: "news"
  name: "News"
  url: "/news"
- id: "manual"
  name: "Manual"
  url: "/manual"
---
<dl class="first-deftypefn def-block">
<dt class="deftypefn def-line" id="index-mysql"><span><code class="def-type"><var class="var">conn</var> =</code> <strong class="def-name">mysql</strong> <code class="def-code-arguments">(<var class="var">dbname</var>, <var class="var">username</var>, <var class="var">password</var>)</code></span></dt>
<dt class="deftypefnx def-cmd-deftypefn def-line" id="index-mysql-1"><span><code class="def-type"><var class="var">conn</var> =</code> <strong class="def-name">mysql</strong> <code class="def-code-arguments">(<var class="var">username</var>, <var class="var">password</var>, <var class="var">propertyname</var>, <var class="var">propertyvalue</var> &hellip;)</code></span></dt>
<dd><p>Create a MySQL database connection
</p>
<h4 class="subsubheading" id="Inputs"><span>Inputs</span></h4>
<dl class="table">
<dt><code class="code"><var class="var">dbname</var></code></dt>
<dd><p>Database name
 </p></dd>
<dt><code class="code"><var class="var">username</var></code></dt>
<dd><p>Username for connecting to database.
 </p></dd>
<dt><code class="code"><var class="var">password</var></code></dt>
<dd><p>Password for connecting to database.
 </p></dd>
<dt><code class="code"><var class="var">propertyname</var>, <var class="var">propertyvalue</var></code></dt>
<dd><p>Property names and values
 </p></dd>
</dl>

<p>Input property names can be:
 </p><dl class="table">
<dt>Server</dt>
<dd><p>Server lookup name or ip address (default is &quot;localhost&quot;)
 </p></dd>
<dt>PortNumber</dt>
<dd><p>numeric port number (default 3306)
 </p></dd>
<dt>DatabaseName</dt>
<dd><p>Name of the database to connect to (default &quot;&quot;)
 </p></dd>
<dt>LoginTimeout</dt>
<dd><p>Numeric timeout value (default 0)
 </p></dd>
</dl>

<h4 class="subsubheading" id="Outputs"><span>Outputs</span></h4>
<dl class="table">
<dt><code class="code"><var class="var">conn</var></code></dt>
<dd><p>A connection object for the connected database
 </p></dd>
</dl>

<h4 class="subsubheading" id="Examples"><span>Examples</span></h4>
<p>Open a connection to a MySQL Database &quot;MySQLNative&quot;, using username/password root/matlab
 </p><div class="example">
<pre class="example-preformatted"> <code class="code">
 db = mysql(&quot;MySQLNative&quot;, &quot;root&quot;, &quot;matlab&quot;);
 </code>
 </pre></div>

<p>Using property name/values:
 </p><div class="example">
<pre class="example-preformatted"> <code class="code">
 db = mysql(&quot;root&quot;, &quot;matlab&quot;, &quot;DatabaseName&quot;, &quot;MySQLNative&quot;);
 </code>
 </pre></div>


<p><strong class="strong">See also:</strong> mysqldb.connection.
 </p></dd></dl>