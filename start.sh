docker build -t nerdctl-loongarch64 .
docker run --rm -v $(pwd)/dist:/dist nerdctl-loongarch64
ls -al $(pwd)/dist