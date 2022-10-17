#!/bin/bash
xcodebuild docbuild -scheme SundialKit  -destination 'generic/platform=iOS Simulator' -derivedDataPath DerivedData
cp .htaccess DerivedData/Build/Products/Debug
docker run -d -p 8080:80 -v "$(pwd)/DerivedData/Build/Products/Debug:/usr/local/apache2/htdocs/"  --rm -it $(docker build -q .)
