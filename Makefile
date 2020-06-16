build:
	@rm -rf ./out
	@mkdir -p ./out
	@dpkg-deb --build pkg ./out/srkbz-base-server.deb

.PHONY: build
