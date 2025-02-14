---
#
# Use the widgets beneath and the content will be
# inserted automagically in the webpage. To make
# this work, you have to use › layout: frontpage
#
layout: page
header:
    title: "<strong>DigiCARES</strong>"
    color: "#000"
    background: |
        linear-gradient(rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0.5)),
        top left repeat url(/assets/css/images/overlay.png),
        center center/cover no-repeat url(/images/banner/artificial-intelligence-3706562.jpg)
cta:
    link: /contact/
    text: "Contact us"

permalink: /index.html
homepage: true
---

{% subview section_one.md %}


