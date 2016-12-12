## Habitat Office Hours

### What is Habitat?
 Habitat is an open-source project that enables you to ship your application, to any platform, along with all the automation you'll need to manage it in production.
 
### Benefits
- Portability
  * Habitat packages can run anywhere that the supervisor can run.  Bare metal, VM, cloud, container, etc
  * Minimal OS requirements
  * You can run different environments on different platforms (dev on Docker, stage on Kubernetes, prod on EC2)
- 

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
  * Expose an HTTP API for diagnostic, metadata and stats.
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
