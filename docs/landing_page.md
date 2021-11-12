# Landing page, "http://localhost"

When we start composing services it may be useful to an _index_ page linking them.
For instance, Awstats page is provided by a cgi script, available at
`http://localhost/awstats/awstats.pl`, which is a Perl script for parsing Dachs logs
and generating the stats html.

Although we could edit Awstats page to point to Dachs (`http://localhost:8080`)
and vice-versa -- Dachs frontpage "-->" Awstats --, it would be better if we could
_avoid_ their _edition_ but still have them linked somehow.
Specially for Awstats, it would be nice to have the generated html (from `awstats.pl`)
inside a "frame" in services frontpage (`http://localhost`) for "Awstats" button.
