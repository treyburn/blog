+++
date = '{{ .Date.Format "2006-01-02" }}'
draft = true
title = '{{ replace .File.ContentBaseName "_" " " | title }}'
+++
