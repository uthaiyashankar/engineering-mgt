cat target/site/dependency-updates-report.html | sed -e "s/border=\"0\"/border=\"1\"/g" > temp.html
img="<img class=\"poweredBy\" alt=\"Built by Maven\" src=\".\/images\/logos\/maven-feather.png\" \/>"
cat temp.html | sed -e "s/$img//g" > temp2.html
cat temp2.html > target/site/dependency-updates-report.html