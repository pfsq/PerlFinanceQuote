# PerlFinanceQuote
Modules for the Perl Finance::Quote module (used in particular by GnuCash). Currently available modules are:

- Bloomberg, get quotes from Bloomberg Market's web page.
- MorningstarES, get quotes from the Spanish Morningstar web page.

To make this work within GnuCash, you need to:

1. add the \<Module\>.pm file in the Finance/Quote/ folder within your perl modules directory

2. edit the main Quote.pm file within the Finance::Quote module. Around line 175, `@modules` is defined, just add \<Module\> in the list.

As an example the following should work at the command line if all is installed correctly:

    gnc-fq-dump bloomberg 1938:HK

## GnuCash

In order to use the modules in GnuCash it is necessary to add the proper `id` to the security's Symbol/abbreviation section:

- Bloomberg: https://www.bloomberg.com/quote/<b>1938:HK</b>
- MorningstarES: http://www.morningstar.es/es/funds/snapshot/snapshot.aspx?id=<b>F00000T7PZ</b>

![GnuCash security editor](https://i.imgur.com/XZNqSjD.png)

Within GnuCash, in the security editor, select Get Online Quotes and then Unknown, \<module\> should be an option.

Note that given both GnuCash and Bloomberg use the ":" character as a delimiter, it is advisable to change the default delimiter in GnuCash to some other character such as "/" (in the GnuCash preferences).
