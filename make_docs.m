# version 1.1 - newer text info updates
# version 1.2 - update  single;line functon to remove '"' from strings
# version 1.3 - add tracker
# version 1.4 - Support subgroups 
function make_docs (name)
  printf("* Getting package info ...\n");
  pkginfo = pkg_describe(name);
  pkg ("load", name);

  base_dir = fullfile(".", pkginfo.name);
  if !exist (base_dir, "file")
    mkdir(base_dir);
  endif

  fd = fopen(fullfile(base_dir, "index.md"), "wt");
  if fd == -1
    error ("Could not create index.md");
  endif

  printf("* Generating overview ...\n");

  unwind_protect
    fprintf(fd, "---\n");
    fprintf(fd, 'layout: "overview"\n');
    fprintf(fd, 'permalink: "/index"\n');
    fprintf(fd, 'title: "%s Toolkit - Overview"\n', tocapitalcase(pkginfo.name));
    fprintf(fd, 'pkg_name: "%s"\n', pkginfo.name);
    fprintf(fd, 'version: "%s"\n', pkginfo.version);
    fprintf(fd, 'pkg_date: "%s"\n', pkginfo.date);
    fprintf(fd, 'description: "%s"\n', singleline(pkginfo.description));
    fprintf(fd, 'author: "%s"\n', pkginfo.author);
    fprintf(fd, 'maintainer: "%s"\n', pkginfo.maintainer);
    fprintf(fd, 'license: "%s"\n', pkginfo.license);
    fprintf(fd, 'pkg_url: "%s"\n', pkginfo.url);
    if (isfield(pkginfo, "repository"))
      fprintf(fd, 'repository: "%s"\n', pkginfo.repository);
    endif
    if (isfield(pkginfo, "tracker"))
      fprintf(fd, 'issues: "%s"\n', pkginfo.tracker);
    endif
    fprintf(fd, 'navigation:\n');
    fprintf(fd, '- id: "%s"\n', "overview")
    fprintf(fd, '  name: "%s"\n', "Overview")
    #fprintf(fd, '  url: "%s"\n', "/index")
    fprintf(fd, '- id: "%s"\n', "Functions")
    fprintf(fd, '  name: "%s"\n', "Function Reference")
    fprintf(fd, '  url: "%s"\n', "/functions")
    fprintf(fd, '- id: "%s"\n', "news")
    fprintf(fd, '  name: "%s"\n', "News")
    fprintf(fd, '  url: "%s"\n', "/news")
    if !isempty(pkginfo.pkgdoc)
      fprintf(fd, '- id: "%s"\n', "manual")
      fprintf(fd, '  name: "%s"\n', "Manual")
      fprintf(fd, '  url: "%s"\n', "/manual")
    endif
 
    fprintf(fd, "---\n");

    # no actual content needed, as will build based on the vars only
  unwind_protect_cleanup
    fclose(fd);
  end_unwind_protect

  printf("* Function page ...\n");

  fd = fopen(fullfile(base_dir, "functions.md"), "wt");
  if fd == -1
    error ("Could not create functions.md");
  endif

  unwind_protect

    fprintf(fd, "---\n");
    fprintf(fd, 'layout: "function_list"\n');
    fprintf(fd, 'permalink: "/functions/"\n');
    fprintf(fd, 'title: "%s Toolkit - Functions"\n', tocapitalcase(pkginfo.name));
    fprintf(fd, 'pkg_name: "%s"\n', pkginfo.name);
    fprintf(fd, 'version: "%s"\n', pkginfo.version);
    fprintf(fd, 'description: "%s"\n', singleline(pkginfo.description));
    fprintf(fd, 'categories:\n');
    for cidx=1:numel(pkginfo.provides)
      categories = pkginfo.provides{cidx};
      fprintf(fd, '- id: "%s"\n', makeid(categories.category))
      fprintf(fd, '  description: "%s"\n', singleline(categories.category))
      fprintf(fd, '  functions:\n')

      has_subgroup = !isempty(categories.subgroups{1}.category);
      start_group = 1;
      if !has_subgroup
        start_group = 2;
        group = categories.subgroups{1};
        for fidx=1:numel(group.functions)
          func = group.functions{fidx};
          #fname = fullfile(base_dir, "functions", [makeid(func) ".md"])
          fname = fullfile(base_dir, "functions", [make_jekyll_filename(func) ".md"]);
          fpath = fileparts(fname);
          [text, status] = get_first_help_sentence(func, 80);
          fprintf(fd, '  - id: "%s"\n', makeid(func))
          fprintf(fd, '    name: "%s"\n', func)
          fprintf(fd, '    description: "%s"\n', singleline(text))
          fprintf(fd, '    url: "%s/"\n', fullfile(fpath(length(base_dir)+1:end), makeid(func)));
         #fprintf(fd, '    url: "%s"\n', fname);
        endfor
      endif
      fprintf(fd, '  groups:\n')
      for gidx=start_group:numel(categories.subgroups)
        group = categories.subgroups{gidx};
        fprintf(fd, '  - id: "%s"\n', makeid([categories.category "-" group.category]))
        fprintf(fd, '    description: "%s"\n', singleline(group.category))
        fprintf(fd, '    functions:\n')
        for fidx=1:numel(group.functions)
          func = group.functions{fidx};
          #fname = fullfile(base_dir, "functions", [makeid(func) ".md"])
          fname = fullfile(base_dir, "functions", [make_jekyll_filename(func) ".md"]);
          fpath = fileparts(fname);
          [text, status] = get_first_help_sentence(func, 80);
          fprintf(fd, '    - id: "%s"\n', makeid(func))
          fprintf(fd, '      name: "%s"\n', func)
          fprintf(fd, '      description: "%s"\n', singleline(text))
          fprintf(fd, '      url: "%s/"\n', fullfile(fpath(length(base_dir)+1:end), makeid(func)));
          #fprintf(fd, '      url: "%s"\n', fname);
        endfor
      endfor
    endfor
    
    fprintf(fd, 'navigation:\n');
    fprintf(fd, '- id: "%s"\n', "overview")
    fprintf(fd, '  name: "%s"\n', "Overview")
    fprintf(fd, '  url: "%s"\n', "/index")
    fprintf(fd, '- id: "%s"\n', "Functions")
    fprintf(fd, '  name: "%s"\n', "Function Reference")
    #fprintf(fd, '  url: "%s"\n', "/functions")
    for cidx=1:numel(pkginfo.provides)
      categories = pkginfo.provides{cidx};
      fprintf(fd, '- id: "%s"\n', makeid(categories.category))
      fprintf(fd, '  name: "&nbsp;&nbsp;%s"\n', categories.category)
      fprintf(fd, '  url: "%s"\n', ["/functions/#" makeid(categories.category)])

      fprintf(fd, '  subitems:\n')
      for gidx=1:numel(categories.subgroups)
        group = categories.subgroups{gidx};
        if !isempty(group.category)
          fprintf(fd, '  - id: "%s"\n', makeid([categories.category "-" group.category]))
          fprintf(fd, '    name: "&nbsp;&nbsp;&nbsp;&nbsp;%s"\n', singleline(group.category))
          fprintf(fd, '    url: "%s"\n', ["/functions/#" makeid([categories.category "-" group.category])])
        endif
      endfor
    endfor
    fprintf(fd, '- id: "%s"\n', "news")
    fprintf(fd, '  name: "%s"\n', "News")
    fprintf(fd, '  url: "%s"\n', "/news")
    if !isempty(pkginfo.pkgdoc)
      fprintf(fd, '- id: "%s"\n', "manual")
      fprintf(fd, '  name: "%s"\n', "Manual")
      fprintf(fd, '  url: "%s"\n', "/manual")
    endif
    fprintf(fd, "---\n");
  unwind_protect_cleanup
    fclose(fd);
  end_unwind_protect

  printf("* Generating function files ...\n");

  # function pages
  if !exist(fullfile(base_dir, "functions"), "file")
    mkdir (fullfile(base_dir, "functions"))
  endif

  # build a list of all the functions
  function_list = {};
  for cidx=1:numel(pkginfo.provides)
    categories = pkginfo.provides{cidx};
    for fidx=1:numel(categories.functions)
        func = categories.functions{fidx};
        function_list{end+1} = func;
    endfor

    #for gidx=1:numel(categories.subgroups)
    #    groups = categories.subgroups{gidx};
    #    for fidx=1:numel(groups.functions)
    #        func = groups.functions{fidx};
    #        function_list{end+1} = func;
    #    endfor
    #endfor
  endfor
 
  for fidx=1:numel(function_list)
    func = function_list{fidx}

    text = get_function_help(func);

    fname = fullfile(base_dir, "functions", [make_jekyll_filename(func) ".md"])
    fpath = fileparts(fname);
    if !exist(fpath, "file")
      mkdir (fpath)
    endif

    fd = fopen(fname, "wt");
    if fd == -1
      error ("Could not create %s", fname);
    endif

    unwind_protect
      fprintf(fd, "---\n");
      fprintf(fd, 'layout: "default"\n');
      fprintf(fd, 'permalink: "%s/"\n', fullfile(fpath(length(base_dir)+1:end), makeid(func)));
      fprintf(fd, 'pkg_name: "%s"\n', pkginfo.name);
      fprintf(fd, 'pkg_version: "%s"\n', pkginfo.version);
      fprintf(fd, 'pkg_description: "%s"\n', pkginfo.description);
      fprintf(fd, 'title: "%s Toolkit - %s"\n', tocapitalcase(pkginfo.name), func);
      fprintf(fd, 'category: "%s"\n', categories.category);
      fprintf(fd, 'func_name: "%s"\n', func);

      fprintf(fd, 'navigation:\n');
      fprintf(fd, '- id: "%s"\n', "overview")
      fprintf(fd, '  name: "%s"\n', "Overview")
      fprintf(fd, '  url: "%s"\n', "/index")
      fprintf(fd, '- id: "%s"\n', "Functions")
      fprintf(fd, '  name: "%s"\n', "Function Reference")
      fprintf(fd, '  url: "%s"\n', "/functions")
      for cidx1=1:numel(pkginfo.provides)
        categories1 = pkginfo.provides{cidx1};
        fprintf(fd, '- id: "%s"\n', makeid(categories1.category))
        fprintf(fd, '  name: "&nbsp;&nbsp;%s"\n', categories1.category)
        fprintf(fd, '  url: "%s"\n', ["/functions/#" makeid(categories1.category)])
        fprintf(fd, '  subitems:\n')
        for gidx=1:numel(categories1.subgroups)
          group = categories1.subgroups{gidx};
          if !isempty(group.category)
            fprintf(fd, '  - id: "%s"\n', makeid([categories1.category "-" group.category]))
            fprintf(fd, '    name: "&nbsp;&nbsp;&nbsp;&nbsp;%s"\n', singleline(group.category))
            fprintf(fd, '    url: "%s"\n', ["/functions/#" makeid([categories1.category "-" group.category])])
          endif
        endfor
      endfor
 
      fprintf(fd, '- id: "%s"\n', "news")
      fprintf(fd, '  name: "%s"\n', "News")
      fprintf(fd, '  url: "%s"\n', "/news")
      if !isempty(pkginfo.pkgdoc)
        fprintf(fd, '- id: "%s"\n', "manual")
        fprintf(fd, '  name: "%s"\n', "Manual")
        fprintf(fd, '  url: "%s"\n', "/manual")
      endif
 
      fprintf(fd, "---\n");
      fprintf (fd, "%s", text);
    unwind_protect_cleanup
      fclose(fd);
    end_unwind_protect
     
  endfor

  # news
  news = fullfile(pkginfo.dir, "packinfo", "NEWS");
  if exist(news, "file")
    printf("* News page ...\n");
    
    fd = fopen(fullfile(base_dir, "news.md"), "wt");
    if fd == -1
      error ("Could not create news.md");
    endif

    nfd = fopen(news, "rt");
    if nfd == -1
      fclose(fd);
      error ("Could not open NEWS");
    endif

    unwind_protect

      fprintf(fd, "---\n");
      fprintf(fd, 'layout: "default"\n');
      fprintf(fd, 'permalink: "/news/"\n');
      fprintf(fd, 'title: "%s Toolkit - News"\n', tocapitalcase(pkginfo.name));
      fprintf(fd, 'pkg_name: "%s"\n', pkginfo.name);
      fprintf(fd, 'version: "%s"\n', pkginfo.version);
      fprintf(fd, 'description: "%s"\n', pkginfo.description);
      fprintf(fd, 'navigation:\n');
      fprintf(fd, '- id: "%s"\n', "overview")
      fprintf(fd, '  name: "%s"\n', "Overview")
      fprintf(fd, '  url: "%s"\n', "/index")
      fprintf(fd, '- id: "%s"\n', "Functions")
      fprintf(fd, '  name: "%s"\n', "Function Reference")
      fprintf(fd, '  url: "%s"\n', "/functions")
      fprintf(fd, '- id: "%s"\n', "news")
      fprintf(fd, '  name: "%s"\n', "News")
      #fprintf(fd, '  url: "%s"\n', "/news")
      if !isempty(pkginfo.pkgdoc)
        fprintf(fd, '- id: "%s"\n', "manual")
        fprintf(fd, '  name: "%s"\n', "Manual")
        fprintf(fd, '  url: "%s"\n', "/manual")
      endif
 
      fprintf(fd, "---\n");
      # we dont want markdown messging with the format of our news, so wrap it all in a 
      # pre tag
      fprintf(fd, "<pre>\n");
      while !feof(nfd)
       s = fgetl(nfd);
       fprintf(fd, "%s\n", s);
      endwhile
      fprintf(fd, "</pre>\n");

    unwind_protect_cleanup
      fclose(fd);
      fclose(nfd);
    end_unwind_protect

  endif # news

  if !isempty(pkginfo.pkgdoc)
    printf("* Manual page ...\n");
    
    fd = fopen(fullfile(base_dir, "manual.md"), "wt");
    if fd == -1
      error ("Could not create manual.md");
    endif

    nfd = fopen(pkginfo.pkgdoc, "rt");
    if nfd == -1
      fclose(fd);
      error ("Could not open manual");
    endif

    unwind_protect

      fprintf(fd, "---\n");
      fprintf(fd, 'layout: "default"\n');
      fprintf(fd, 'permalink: "/manual/"\n');
      fprintf(fd, 'title: "%s Toolkit - Manual"\n', tocapitalcase(pkginfo.name));
      fprintf(fd, 'pkg_name: "%s"\n', pkginfo.name);
      fprintf(fd, 'version: "%s"\n', pkginfo.version);
      fprintf(fd, 'description: "%s"\n', pkginfo.description);
      fprintf(fd, 'navigation:\n');
      fprintf(fd, '- id: "%s"\n', "overview")
      fprintf(fd, '  name: "%s"\n', "Overview")
      fprintf(fd, '  url: "%s"\n', "/index")
      fprintf(fd, '- id: "%s"\n', "Functions")
      fprintf(fd, '  name: "%s"\n', "Function Reference")
      fprintf(fd, '  url: "%s"\n', "/functions")
      fprintf(fd, '- id: "%s"\n', "news")
      fprintf(fd, '  name: "%s"\n', "News")
      fprintf(fd, '  url: "%s"\n', "/news")
  
      fprintf(fd, '- id: "%s"\n', "manual")
      fprintf(fd, '  name: "%s"\n', "Manual")
      #fprintf(fd, '  url: "%s"\n', "/manual")
  
      while !feof(nfd)
        s = fgetl(nfd);
        #if strncmp(s, "<span id=", 6)
        if !isempty(strfind(s, '<h2 class="chapter'))
          [~,~,~,~,groups] = regexp(s, '.*id="([^"]*)".*>\d*([^<]*)</h2>');
          if !isempty(groups)
            groups = groups{1};
            fprintf(fd, '- id: "%s"\n', groups{1})
            fprintf(fd, '  name: "&nbsp;&nbsp;%s"\n', groups{2})
            fprintf(fd, '  url: "%s"\n', ["/manual/#" groups{1}])
          endif
        endif
      endwhile
 
      fprintf(fd, "---\n");
      skip = true;
      fseek(nfd, 0);

      while !feof(nfd)
        s = fgetl(nfd);
        if isempty(s)
          # skip blank lines
        elseif strncmp(s, "<body", 5)
          skip = false;
        elseif strncmp(s, "</body", 6)
          skip = true;
        elseif !skip
          s = strrep(s, " &para;", "");
          fprintf(fd, "%s\n", s);
        endif
      endwhile

    unwind_protect_cleanup
      fclose(fd);
      fclose(nfd);
    end_unwind_protect

  endif # news

endfunction

function text = get_function_help(func)
  ## Get the help text of the function
  [text, format] = get_help_text (func);

  ## Take action depending on help text format
  switch (lower (format))
    case "plain text"
      text = sprintf ("<pre>%s</pre>\n", text);
    case "texinfo"
      orig_text = text;
      ## Add easily recognisable text before and after real text
      start = "###### OCTAVE START ######";
      stop  = "###### OCTAVE STOP ######";
      text = sprintf ("%s\n%s\n%s\n", start, text, stop);

      #[~, text] = __texi2html__ (text, vpars);
      ## Run makeinfo
      [text, status] = __makeinfo__ (text, ...
               "html"); #, @(x) getopt ("seealso") (root, x{:}));
      if (status != 0)
        error ("__makeinfo__ returned with error code %d\n. Couldn't parse\
            texinfo:\n%s", status, orig_text (1:min (200, length (orig_text))));
      endif

      # TODO remove the html stuff at start and end
      ## Extract the body of makeinfo's output
      p_start = sprintf ('\\s*(<p>)?\\s*%s\\s*(</p>)?\\s*', start);
      p_stop = sprintf ('\\s*(<p>)?\\s*%s\\s*(</p>)?\\s*', stop);
      [i1, i2] = regexp (text, p_start);
      i3 = regexp (text, p_stop);
      text = text((i2 + 1):(i3 - 1));

      #text = strrep(text, " &para;", "");
      text = regexprep(text, '<span class="category[^"]*">: </span>', '');
      text = regexprep(text, '<a[^>]*class=.copiable[^>]*> &para;</a>', '');

    case "not documented"
      text = sprintf ("<pre>Not documented</pre>\n");
    case "not found" 
      warning ("`%s' not found\n", name);
    otherwise
      error ("Internal error: unsupported help text format '%s' for '%s'",
               format, name);
  endswitch
endfunction

function desc = pkg_describe(name)
  # the diff between list and describe for a pkg name is:
  # title
  # author
  # maintainer
  # - tracker
  # - provides
  # dir
 
  # list: + url, tracker
  desc = (pkg ("describe", name)){1};
  pkginfo = (pkg ("list", name)){1};

  if isfield(desc, "tracker")
    pkginfo.tracker = desc.tracker;
  endif

  pkgdoc = fullfile(pkginfo.dir, "doc", sprintf("octave-%s.html", desc.name));
  if !exist (pkgdoc, "file")
    pkgdoc = fullfile(pkginfo.dir, "doc", sprintf("%s.html", desc.name));
    if !exist (pkgdoc, "file")
      pkgdoc = "";
    endif
  endif
  pkginfo.pkgdoc = pkgdoc;

  indexname = fullfile(pkginfo.dir, "packinfo", "INDEX");
  fd = fopen(indexname, "r");
  line = fgetl (fd);
  while (isempty (strfind (line, ">>")) && ! feof (fd))
    line = fgetl (fd);
  endwhile

  cat_num = 1;
  group_num = 1;
  pkg_idx_struct{1}.category = "Uncategorized";
  pkg_idx_struct{1}.functions = {};
  pkg_idx_struct{1}.subgroups{1}.category = "";
  pkg_idx_struct{1}.subgroups{1}.functions = {};

  while (! feof (fd) || line != -1)
    #if startsWith(line, "#!")
    if strncmp(line, "#!", 2)
      # subgroup
      if (! isempty (pkg_idx_struct{cat_num}.subgroups{group_num}.functions))
        pkg_idx_struct{cat_num}.subgroups{++group_num}.functions = {};
      endif
      pkg_idx_struct{cat_num}.subgroups{group_num}.category = strtrim(line(3:end));
    elseif (! any (! isspace (line)) || line(1) == "#" || any (line == "="))
      ## Comments,  blank lines or comments about unimplemented
      ## functions: do nothing
      ## FIXME: probably comments and pointers to external functions
      ## could be treated better when printing to screen?
    elseif (! isempty (strfind (line, ">>")))
      ## Skip package name and description as they are in DESCRIPTION
      ## already.
    elseif (! isspace (line(1)))
      ## Category.
      if (! isempty (pkg_idx_struct{cat_num}.functions))
        pkg_idx_struct{++cat_num}.functions = {};
        pkg_idx_struct{cat_num}.subgroups{1}.category = "";
        pkg_idx_struct{cat_num}.subgroups{1}.functions = {};
        group_num = 1
      endif
      pkg_idx_struct{cat_num}.category = deblank (line);
    else
      ## Function names.
      while (any (! isspace (line)))
        [fun_name, line] = strtok (line);
        pkg_idx_struct{cat_num}.functions{end+1} = deblank (fun_name);
        pkg_idx_struct{cat_num}.subgroups{group_num}.functions{end+1} = deblank (fun_name)
      endwhile
    endif
    line = fgetl (fd);
  endwhile

  fclose(fd);

  pkginfo.provides = pkg_idx_struct;

  desc = pkginfo;
endfunction

function name = makeid(name)
  x = num2str(length(name));
  name = strrep(name, "@", "");
  name = strrep(name, "+", "");
  name = strrep(name, "/", "");
  name = strrep(name, " ", "");
  name = strrep(name, ".", "");
  name = strrep(name, "_", "");
  name = [x "_" name];
endfunction

function name = make_jekyll_filename(name)
  # jekyll ignores names startwith '_', so change that
  if name(1) == "_"
    name(1) = "1";
  endif
endfunction

function strout=tocapitalcase(str)
  str=lower(str);
  idx=regexp([' ' str],'(?<=\s+)\S','start')-1;
  str(idx)=upper(str(idx));
  strout  = str;
endfunction

function strout = singleline(str)
  str = strrep(str, "\n", " ");
  str = strrep(str, "\r", "");
  # replace some specific stuff too ?
  str = strrep(str, '"', '');
  strout = str;
endfunction
