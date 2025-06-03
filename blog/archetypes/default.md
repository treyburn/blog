+++
date = '{{ dateFormat "2006-01-02" .Date }}'
draft = true
displayTitle = '{{ replace (substr .File.ContentBaseName 11) "_" " " | title }}'
title = '{{ replace (substr .File.ContentBaseName 11) "_" " " | title }}'
subtitle = ""
description = ""
summary = ""
aliases = []
tags = []
keywords = []
+++
