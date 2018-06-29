---
permalink: /inst-list/
layout: default
title: List of downloadable inst files
description: Ready to import inst files of already made installations
---

{% for item in site.static_files %}
{% if item.path contains "assets/inst" %}
<a href="{{item.path}}">{{item.basename}}</a>
{% endif %}
{% endfor %}

