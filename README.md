## Habitat Office Hours

### What is Habitat?
 Habitat is an open-source project that enables you to ship your application, to any platform, along with all the automation you'll need to manage it in production.
 
### Benefits
- Portability
  * Habitat packages can run anywhere that the supervisor can run.  Bare metal, VM, cloud, container, etc
  * Minimal OS requirements
  * You can run different environments on different platforms (dev on Docker, stage on Kubernetes, prod on EC2)
- Rub a little cloud on your legacy apps
  * Add things like service discovery, easy configuration updates, and clustering/update strategies without doing a "cloud-native" rewrite.
- Standardize application management
  * Using Habitat's built in management features, you can deploy/monitor/update/configure all your apps in a standard way.

### What are the pieces?
- Primary components
  * Package
  * Supervisor
- Supporting components
  * Studio
  * Depot
  * Build service

#### Package
- The Habitat package contains your application and configuration information, as well as dependency references.
- It has a .hart extension, and is a signed tarball.
- Identifier:  `<origin>/<package>/<version>/<release>`
  * The first two pieces, origin and package are the minimum needed to reference a package.
  * The version and release parts are optional.
- Examples:
  * `core/rust` - Assumes latest release of the latest version of the Rust package in the core origin
  * `core/rust/1.11.0` - Assumes the latest release of Rust 1.11.0 in the core origin
  * `core/rust/1.11.0/20160926152927` - Refers to a specific package
  * `rust` - Not a valid package identifier
- Note that even vague identifiers like `core/rust` will be tied to a specific version of the `core/rust` package at build time.  

#### Supervisor
- Habitat packages run under the supervisor.
- There is currently a 1:1 mapping of supervisor to service.
- Roles of the supervisor:
  * Start and monitor the service in the specified package
  * Exchange information with other supervisors and act upon changes.
  * Expose an HTTP API for diagnostic info, metadata and stats.
- Currently the supervisor requires a modern 64 bit Linux kernel to run.  Windows support is in the works.

#### Studio
- Clean-room environment for building packages.
- Uses Docker on OS X, and chroot on Linux.
- Can be entered into for an interactive session, or used to do a build by the `hab pkg build` command for non-interactive builds.

#### Depot
- A service hosting Habitat packages.
- The public depot is at https://app.habitat.sh
- Private depot instances can be self hosted (docs to come).
- The depot software supports channels for CI/CD purposes.

#### Build service
- Soon to be released/launched.
- Watches source control for changes and kicks off package builds as needed.
- There will be a publicly hosted service, as well as an option to run privately.

### Demo
***Note***: To work through this locally, you will need to change the origin in the plan.sh file to one that you have the keys for.

Review plan.sh

Enter the studio interactively:
```
$ cd my_app
$ hab studio -k <origin_name> enter
0.13.1: Pulling from studio
Digest: sha256:7584882a621ff81b3faa99a4ada54915298b39613a4a7e6b0f6bc1b7a793536a
Status: Image is up to date for habitat-docker-registry.bintray.io/studio:0.13.1
hab-studio: Creating Studio at /hab/studios/src (default)
hab-studio: Importing nsdavidson secret origin key
» Importing origin key from standard input
★ Imported secret origin key nsdavidson-20160902123213.
hab-studio: Entering Studio at /hab/studios/src (default)
hab-studio: Exported: HAB_ORIGIN=nsdavidson
hab-studio: Exported: HAB_DEPOT_URL=https://willem.habitat.sh/v1/depot
```

Build:
```
[1][default:/src:0]# build
: Loading /src/habitat/plan.sh
my_app: Plan loaded
my_app: Validating plan metadata
my_app: hab-plan-build setup
my_app: Using HAB_BIN=/hab/pkgs/core/hab/0.13.1/20161114235527/bin/hab for installs, signing, and hashing
my_app: Resolving dependencies
...
<output snipped>
...
★ Signed artifact /hab/cache/artifacts/nsdavidson-my_app-0.1.0-20161212190104-x86_64-linux.hart.
'/hab/cache/artifacts/nsdavidson-my_app-0.1.0-20161212190104-x86_64-linux.hart' -> '/src/results/nsdavidson-my_app-0.1.0-20161212190104-x86_64-linux.hart'
my_app: hab-plan-build cleanup
my_app:
my_app: Source Cache: /hab/cache/src/my_app-0.1.0 
my_app: Installed Path: /hab/pkgs/nsdavidson/my_app/0.1.0/20161212190104
my_app: Artifact: /src/results/nsdavidson-my_app-0.1.0-20161212190104-x86_64-linux.hart
my_app: Build Report: /src/results/last_build.env
my_app: SHA256 Checksum: 59d4c3727598ab66afe44b0b1df621127aa022369b538b55f074201106f422d2
my_app: Blake2b Checksum: bd53fdf150ceb47193f19371ec265c9b19cc878bbeb94783ab5eb07f7197f547
my_app:
my_app: I love it when a plan.sh comes together.
my_app:
my_app: Build time: 3m12s
```

Run:
```
# hab start nsdavidson/my_app
hab-sup(MN): Starting nsdavidson/my_app
hab-sup(TP): Child process will run as user=hab, group=hab
hab-sup(GS): Supervisor 172.17.0.2: 4b64fbeb-f01b-4d01-8e4a-ee59ed9eb924                                                                                                                                                                                                                                    hab-sup(GS): Census my_app.default: 5cbc1932-06cb-4da0-b65e-dcd221a1bed8
hab-sup(GS): Starting inbound gossip listenerhab-sup(GS): Starting outbound gossip distributor
hab-sup(GS): Starting gossip failure detector
hab-sup(CN): Starting census health adjuster
hab-sup(SC): Updated my_app.json
hab-sup(TP): Restarting because the service config was updated via the census
my_app(SV): Starting
my_app(O): Listening on http://0.0.0.0:8080
```

Package:

Docker
```
# hab pkg export docker nsdavidson/my_app
hab-studio: Creating Studio at /tmp/hab-pkg-dockerize-uNwF/rootfs (baseimage)
Using local package for nsdavidson/my_app
Using local package for core/acl/2.2.52/20161208223311 via nsdavidson/my_app
> Using local package for core/attr/2.4.47/20161208223238 via nsdavidson/my_app
> Using local package for core/coreutils/8.25/20161208223423 via nsdavidson/my_app
> Using local package for core/gcc-libs/5.2.0/20161208223920 via nsdavidson/my_app                                                               > Using local package for core/glibc/2.22/20160612063629 via nsdavidson/my_app
> Using local package for core/gmp/6.1.0/20161208212521 via nsdavidson/my_app
> Using local package for core/libcap/2.24/20161208223353 via nsdavidson/my_app
> Using local package for core/linux-headers/4.3/20160612063537 via nsdavidson/my_app
» Installing core/hab
↓ Downloading core/hab/0.13.1/20161114235527
    2.39 MB / 2.39 MB - [============================================================================================================================================================================================================================================================================================================================] 100.00 % 1.69 MB/s
↓ Downloading core-20160810182414 public origin key
75 B / 75 B | [==================================================================================================================================================================================================================================================================================================================================] 100.00 % 1.48 MB/s
☑ Cached core-20160810182414 public origin key
✓ Installed core/hab/0.13.1/20161114235527
★ Install of core/hab/0.13.1/20161114235527 complete with 1 new packages installed.
» Installing core/hab-sup
↓ Downloading core/hab-sup/0.13.1/20161115003952
...
<output snipped>
...
Sending build context to Docker daemon 198.1 MB
Step 1/8 : FROM scratch
 --->
Step 2/8 : ENV PATH :/hab/pkgs/core/acl/2.2.52/20161208223311/bin:/hab/pkgs/core/attr/2.4.47/20161208223238/bin:/hab/pkgs/core/coreutils/8.25/20161208223423/bin:/hab/pkgs/core/glibc/2.22/20160612063629/bin:/hab/pkgs/core/libcap/2.24/20161208223353/bin:/hab/pkgs/core/hab-sup/0.13.1/20161115003952/bin:/hab/pkgs/core/busybox-static/1.24.2/20161102170221/bin:/hab/pkgs/core/bzip2/1.0.6/20161031042910/bin:/hab/pkgs/core/glibc/2.22/20160612063629/bin:/hab/pkgs/core/openssl/1.0.2j/20161102155324/bin:/hab/pkgs/core/xz/5.2.2/20161031043427/bin:/hab/pkgs/core/busybox-static/1.24.2/20161102170221/bin:/hab/bin
 ---> Running in 1af5c897766f
 ---> 10bcf57f1e69
Removing intermediate container 1af5c897766f
Step 3/8 : WORKDIR /
 ---> Running in 24a2a8ab73c5
 ---> 0d267ed15acf
Removing intermediate container 24a2a8ab73c5
Step 4/8 : ADD rootfs /
 ---> 6cf480406b94
Removing intermediate container 7862105cb42a
Step 5/8 : VOLUME /hab/svc/my_app/data /hab/svc/my_app/config
 ---> Running in 601e69ba699d
 ---> 6331c2fa87c4
Removing intermediate container 601e69ba699d
Step 6/8 : EXPOSE 9631 8080 9634
 ---> Running in 24263849a41a
 ---> 1331fbe6373c
Removing intermediate container 24263849a41a
Step 7/8 : ENTRYPOINT /init.sh
 ---> Running in 4ec2c8e8d419
 ---> 92db9c486fbf
Removing intermediate container 4ec2c8e8d419
Step 8/8 : CMD start nsdavidson/my_app
 ---> Running in a878a4449dff
 ---> e767b35b51bd
Removing intermediate container a878a4449dff
Successfully built e767b35b51bd
```

Tarball
```
# hab pkg export tar nsdavidson/my_app
   hab-studio: Creating Studio at /tmp/hab-pkg-tarize-58LR (bare)
> Using local package for nsdavidson/my_app
> Using local package for core/acl/2.2.52/20161208223311 via nsdavidson/my_app
> Using local package for core/attr/2.4.47/20161208223238 via nsdavidson/my_app
> Using local package for core/coreutils/8.25/20161208223423 via nsdavidson/my_app
> Using local package for core/gcc-libs/5.2.0/20161208223920 via nsdavidson/my_app
> Using local package for core/glibc/2.22/20160612063629 via nsdavidson/my_app
> Using local package for core/gmp/6.1.0/20161208212521 via nsdavidson/my_app
> Using local package for core/libcap/2.24/20161208223353 via nsdavidson/my_app
> Using local package for core/linux-headers/4.3/20160612063537 via nsdavidson/my_app
» Installing core/hab
↓ Downloading core/hab/0.13.1/20161114235527
    2.39 MB / 2.39 MB \ [============================================================================================================================================================================================================================================================================================================================] 100.00 % 2.12 MB/s
↓ Downloading core-20160810182414 public origin key
    75 B / 75 B | [==================================================================================================================================================================================================================================================================================================================================] 100.00 % 2.47 MB/s
☑ Cached core-20160810182414 public origin key
✓ Installed core/hab/0.13.1/20161114235527
★ Install of core/hab/0.13.1/20161114235527 complete with 1 new packages installed.
» Installing core/hab-sup
↓ Downloading core/hab-sup/0.13.1/20161115003952
    1.46 MB / 1.46 MB \ [============================================================================================================================================================================================================================================================================================================================] 100.00 % 1.62 MB/s
↓ Downloading core/busybox-static/1.24.2/20161102170221
    510.61 KB / 510.61 KB | [========================================================================================================================================================================================================================================================================================================================] 100.00 % 2.23 MB/s
↓ Downloading core/bzip2/1.0.6/20161031042910
    57.98 KB / 57.98 KB | [==========================================================================================================================================================================================================================================================================================================================] 100.00 % 1.01 MB/s
↓ Downloading core/cacerts/2016.09.14/20161031044952
    138.04 KB / 138.04 KB - [========================================================================================================================================================================================================================================================================================================================] 100.00 % 1.29 MB/s
↓ Downloading core/gcc-libs/5.2.0/20161031042519
    1.77 MB / 1.77 MB \ [============================================================================================================================================================================================================================================================================================================================] 100.00 % 2.16 MB/s
→ Using core/glibc/2.22/20160612063629
↓ Downloading core/libarchive/3.2.0/20161102160602
    543.97 KB / 543.97 KB / [========================================================================================================================================================================================================================================================================================================================] 100.00 % 2.42 MB/s
↓ Downloading core/libsodium/1.0.8/20161102180731
    183.24 KB / 183.24 KB | [========================================================================================================================================================================================================================================================================================================================] 100.00 % 2.44 MB/s
→ Using core/linux-headers/4.3/20160612063537
↓ Downloading core/openssl/1.0.2j/20161102155324
    2.10 MB / 2.10 MB - [============================================================================================================================================================================================================================================================================================================================] 100.00 % 2.49 MB/s
↓ Downloading core/xz/5.2.2/20161031043427
    237.00 KB / 237.00 KB - [========================================================================================================================================================================================================================================================================================================================] 100.00 % 2.25 MB/s
↓ Downloading core/zlib/1.2.8/20161015000012
    71.00 KB / 71.00 KB - [==========================================================================================================================================================================================================================================================================================================================] 100.00 % 3.68 MB/s
✓ Installed core/busybox-static/1.24.2/20161102170221
✓ Installed core/bzip2/1.0.6/20161031042910
✓ Installed core/cacerts/2016.09.14/20161031044952
✓ Installed core/gcc-libs/5.2.0/20161031042519
✓ Installed core/libarchive/3.2.0/20161102160602
✓ Installed core/libsodium/1.0.8/20161102180731
✓ Installed core/openssl/1.0.2j/20161102155324
✓ Installed core/xz/5.2.2/20161031043427
✓ Installed core/zlib/1.2.8/20161015000012
✓ Installed core/hab-sup/0.13.1/20161115003952
★ Install of core/hab-sup/0.13.1/20161115003952 complete with 10 new packages installed.
» Symlinking hab from core/hab into /tmp/hab-pkg-tarize-58LR/hab/bin
★ Binary hab from core/hab/0.13.1/20161114235527 symlinked to /tmp/hab-pkg-tarize-58LR/hab/bin/hab
» Symlinking bash from core/busybox-static into /tmp/hab-pkg-tarize-58LR/bin
★ Binary bash from core/busybox-static/1.24.2/20161102170221 symlinked to /tmp/hab-pkg-tarize-58LR/bin/bash
» Symlinking sh from core/busybox-static into /tmp/hab-pkg-tarize-58LR/bin
★ Binary sh from core/busybox-static/1.24.2/20161102170221 symlinked to /tmp/hab-pkg-tarize-58LR/bin/sh

# ls -alh nsdavidson-my_app-0.1.0-20161212203900.tar.gz
-rw-r--r-- 1 root root 58M Dec 12 20:46 nsdavidson-my_app-0.1.0-20161212203900.tar.gz
```

Run:
```
docker run -it -p 8080:8080 nsdavidson/my_app
hab-sup(MN): Starting nsdavidson/my_app
hab-sup(TP): Child process will run as user=hab, group=hab
hab-sup(GS): Supervisor 172.17.0.2: 8824194a-6fc9-4142-91ba-5029216eafbd
hab-sup(GS): Census my_app.default: e30c1ad2-34af-40cb-abd6-313d183d09ab
hab-sup(GS): Starting inbound gossip listener
hab-sup(GS): Starting outbound gossip distributor
hab-sup(GS): Starting gossip failure detector
hab-sup(CN): Starting census health adjuster
hab-sup(SC): Updated my_app.json
hab-sup(TP): Restarting because the service config was updated via the census
my_app(SV): Starting
my_app(O): Listening on http://0.0.0.0:8080
my_app(O): Ctrl-C to shutdown server
```