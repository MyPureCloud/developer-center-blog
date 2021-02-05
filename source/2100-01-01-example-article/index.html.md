---
title: Example Article
tags: example
date: 2100-01-01
author: kevin.glinski@genesys.com
image: genesys.png
category: 0
---

This example article will outline some of the markdown that is available.  

The developer blog uses [Kramdown](http://kramdown.gettalong.org/quickref.html) for markdown and is slightly different from git flavored markdown.

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum

## Images
![alt text](genesys.png "Logo Title Text 1")

## Inline code
Where git flavored markdown uses backticks \`\`\` kramdown uses ```

```{"language":"ruby"}
def what?
   42
end
```

You can also specify the language after the first ``` to help with syntax formatting.

## Tables

```
| Header One     | Header Two     |
| :------------- | :------------- |
| Item One       | Item Two       |
{: class="table table-striped"}
```

The {: class="table table-striped"} will apply the table and table-striped classes to the table.

## Inline HTML
It is preferred to stay away from inline HTML for most pages, but if you need to, just add it normally

<div class="well well-md"> This is in a bootstrap well</div>
