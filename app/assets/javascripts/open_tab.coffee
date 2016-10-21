  $(document).on 'turbolinks:load', ->
    $('.nav-tabs a[href="' + document.location.hash + '"]').tab('show') if document.location.hash
