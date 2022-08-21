# Generate favicon.txt

Michael Lazar, with the motivation to make something joyful, has written a specification with which it is possible to have a favicon on a Gemini page.
For this a file with the name "favicon.txt" is created in the root directory of the Gemini page. In this file you write a unicode character, typically an emoji. Browsers, which support this extension, load the "favicon.txt" when the page is opened and show the favicon. In contrast to HTTP/HTML favicon, favicons in Geminispace do not consist of self-made images, but emojis. The specification can be found at gemini://mozz.us/files/rfc_gemini_favicon.gmi.

Because the creation of such a file might be difficult, I wrote a helper script for it:
```
ruby create_favicon.rb -e 😀 -o favicon.txt
```
or
```
ruby create_favicon.rb -u 1F600 -o favicon.txt
```
You can either copy-paste an emoji directly to the command line with the -e argument or specify the hexadecimal number with the -u option. The favicon will then be saved to the file at -o. This file can be moved to the root directory.
A list of emojis or their number can be found on the Internet, for example at https://unicode.org/emoji/charts/full-emoji-list.html.
