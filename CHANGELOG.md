# CHANGELOG.md

All the notable changes in the project `mystic-framework/cmake` will be documented here.

## [1.0.0] - 2026-09-26

### Added

- `MysticProject`: Configures the project.
- `MysticCompileOptions`: Configures compiler options.
- `MysticInstall`: Configures installation options.
- `MysticSetupOptions`: Sets up project options.
- `MysticTest`: Configures testing options.
- `MysticCoverage`: Configures code coverage options.
- `MysticLint`: Configures linting options (`clang-format` and `clang-tidy`).
- `MysticSanitizers`: Configures sanitizers options (`AddressSanitizer`, `ThreadSanitizer`, etc).
- `MysticImportModule`: Imports a first party (from MFW) module.
- `MysticIncludeModules`: Includes every module from `modules/` directory.
- `MysticThirdPartyConfig`: Configures third party dependencies.
- `MysticIncludeThirdParty`: Includes third party dependencies from `third_party/` directory.
- `MysticAsciiBanner`: Displays an ASCII banner (makes boring CI interesting!).
- `MysticMessage`: Wraps `message()` function to control the output verbosity and prefixing.
