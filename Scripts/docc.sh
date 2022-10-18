#!/bin/bash
docker rm -f sundialkit-docc || true
xcodebuild docbuild -scheme SundialKit  -destination 'generic/platform=iOS Simulator' -derivedDataPath DerivedData
cp .htaccess DerivedData/Build/Products/Debug-iphonesimulator
docker run --name sundialkit-docc -d -p 8080:80 -v "$(pwd)/DerivedData/Build/Products/Debug-iphonesimulator:/usr/local/apache2/htdocs/"  --rm -it $(docker build -q .)
