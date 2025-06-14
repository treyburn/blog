+++
date = '{{ dateFormat "2006-01-02" .Date }}' # date of publication
draft = true # set to false or remove to publish
author = 'travis reyburn'
title = '{{ replace (substr .File.ContentBaseName 11) "_" " " | title }}' # official title of the post
displayTitle = '{{ replace (substr .File.ContentBaseName 11) "_" " " | title }}' # display title in content
displayLanguage = ''
subtitle = '' # subtitle used for display and content
tagline = '' # note on the sidebar
description = '' # seo description? unclear of usecase
summary = '' # seo summary? unclear of usecase
aliases = [] # re-directs from moved content
tags = [] # content grouping tags
keywords = [] # seo keywords
+++
