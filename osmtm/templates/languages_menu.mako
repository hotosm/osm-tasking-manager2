<%page args="languages, languages_full" />
<li class="dropdown"><a href="#" data-toggle="dropdown" class="dropdown-toggle"><img src="${request.static_url('osmtm:static/img/blank.gif')}" class="flag flag-${request.locale_name}" /> ${unicode(languages_full[languages.index(request.locale_name)], 'utf-8')}<b class="caret"></b></a>
  <ul role="menu" class="dropdown-menu languages">
    % for idx, language in enumerate(languages_full):
    <li><a href='${languages[idx]}'><img src="${request.static_url('osmtm:static/img/blank.gif')}" class="flag flag-${languages[idx]}"/> ${unicode(language, 'utf-8')}</a></li>
    % endfor
  </ul>
</li>
