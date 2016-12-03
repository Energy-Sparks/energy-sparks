class @GoogleAnalytics

  @load_script: (ga_code) ->
    ((i, s, o, g, r, a, m) ->
      i['GoogleAnalyticsObject'] = r
      i[r] = i[r] or ->
        (i[r].q = i[r].q or []).push arguments

      i[r].l = 1 * new Date()

      a = s.createElement(o)
      m = s.getElementsByTagName(o)[0]

      a.async = 1
      a.src = g
      m.parentNode.insertBefore a, m
    ) window, document, 'script', '//www.google-analytics.com/analytics.js', 'ga'
    ga 'create', "#{ga_code}", 'auto'
    ga 'send', 'pageview'
