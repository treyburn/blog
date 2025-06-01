+++
date = '{{ .Date.Format "2006-01-02" }}'
draft = true
displayTitle = '{{ replace .File.ContentBaseName "_" " " | title }}'
title = '{{ replace .File.ContentBaseName "_" " " | title }}'
+++
