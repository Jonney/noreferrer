`/**
  @license noreferrer.js, version 0.1.3
  https://github.com/knu/noreferrer

  Copyright (c) 2011 Akinori MUSHA
  Licensed under the 2-clause BSD license.
*/`

###
  Cross-browser support for HTML5's noreferrer link type.

  This version is for use with prototype.js.
###

do ->
  # WebKit based browsers do support rel="noreferrer"
  return if Prototype.Browser.WebKit

  Event.observe window, 'load', ->
    $$('a[href][rel~=noreferrer], area[href][rel~=noreferrer]').each (a) ->
      href = a.href

      # Opera seems to have no way to stop sending a Referer header.
      if Prototype.Browser.Opera
        # Use Google's redirector to hide the real referrer URL
        a.href = 'http://www.google.com/url?q=' + encodeURIComponent(href)
        a.title ||= 'Go to ' + href
        return

      # Disable opening a link in a new window with middle click
      middlebutton = false

      kill_href = (ev) ->
        a.href = 'javascript:void(0)'
        return

      restore_href = (ev) ->
        a.href = href
        return

      Event.observe a, name, restore_href for name in ['mouseout', 'mouseover', 'focus', 'blur']

      Event.observe a, 'mousedown', (ev) ->
        if Event.isMiddleClick(ev)
          middlebutton = true
        return

      Event.observe a, 'blur', (ev) ->
        middlebutton = false
        return

      Event.observe a, 'mouseup', (ev) ->
        return unless Event.isMiddleClick(ev) && middlebutton
        kill_href()
        Event.stop(ev)
        middlebutton = false
        setTimeout (->
          alert '''
            Middle clicking on this link is disabled to keep the browser from sending a referrer.
            '''
          restore_href()
          return
        ), 500
        return

      body = "<html><head><meta http-equiv='Refresh' content='0; URL=#{href.escapeHTML()}' /></head><body></body></html>"

      if Prototype.Browser.IE
        Event.observe a, 'click', (ev) ->
          switch target = @target || '_self'
            when '_self', window.name
              win = window
            else
              win = window.open(null, target)
              # This may be an existing window, hence always call clear().
          doc = win.document
          doc.clear()
          doc.write body
          doc.close()
          Event.stop(ev)
          false
      else
        uri = "data:text/html;charset=utf-8,#{encodeURIComponent(body)}"
        Event.observe a, 'click', (ev) ->
          @href = uri
          true

      return

    return

  return
