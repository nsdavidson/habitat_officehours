pkg_origin=nsdavidson
pkg_name=my_app
pkg_version=0.1.0
pkg_maintainer="Nolan Davidson <ndavidson@chef.io>"
pkg_license=()
pkg_source=empty
pkg_shasum=empty
pkg_deps=(core/coreutils core/gcc-libs core/glibc)
pkg_build_deps=(core/openssl core/rust core/cacerts core/gcc core/gcc-libs core/glibc)
pkg_expose=(8080 9634)
#pkg_svc_run='./my_app'

do_download() {
	return 0
}

do_unpack() {
	cp -a ../ ${HAB_CACHE_SRC_PATH}
}

do_verify() {
	return 0
}

do_build() {
	cargo clean
	env SSL_CERT_FILE=$(pkg_path_for cacerts)/ssl/cert.pem cargo build --release
}

do_install() {
	cp ../target/release/my_app ${pkg_prefix}
}
