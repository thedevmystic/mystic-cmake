<div align="center">
  <table>
    <tr>
      <td valign="middle">
        <img
          src="https://res.cloudinary.com/dqpszz96x/image/upload/v1788529194/favicon_ry6wga.svg"
          width="100px"
          alt="Mystic Framework Logo"
        />
      </td>
      <td valign="middle">
        <h1>mystic framework</h1>
      </td>
    </tr>
  </table>
  <div>
    <h1>CMake</h1>
    <p>Essential CMake modules to configure project, maintain code quality, and streamline dependency management.</p>
  </div>
</div>

<p align="center">
 <img
    src="https://img.shields.io/badge/CMake-444444?style=flat&logo=cmake&logoColor=white"
    alt="CMake"
  />
 <img
    src="https://img.shields.io/badge/Apache%202.0-444444?style=flat&logo=apache&logoColor=white"
    alt="License: Apache 2.0"
  />
  <img
    src="https://img.shields.io/badge/Ver_1.0.0-007acc?style=flat"
    alt="Version: 1.0.0"
  />
</p>

<details>
<summary>Table of Contents (click to show)</summary>

- [About the Project](#about-the-project)
- [How to Use](#how-to-use)
  - [Via FetchContent](#via-fetchcontent)
  - [Via Git Submodules](#via-git-submodules)
  - [Just Copy-Paste](#just-copy-paste)
- [Contributing](#contributing)
- [License](#license)

</details>

# About the Project

`mystic-framework/cmake` is a collection of essential CMake modules to streamline many aspects of build system, such as:
- Project Configuration.
- Code Quality: Testing, Sanitizers, and others.
- Dependency Management.
- And others.

To view the in-depth documentation of this project, please refer to [MFW's CMake module documentation](https://mystic-framework.github.io/docs/modules/cmake).

# How to Use

## Via FetchContent

Add this to your root `CMakeLists.txt`:

```cmake
include(FetchContent)

FetchContent_Declare(
    mystic_cmake
    GIT_REPOSITORY https://github.com/mystic-framework/cmake.git
    GIT_TAG        main # or other tags
)
FetchContent_MakeAvailable(mystic_cmake)

list(APPEND CMAKE_MODULE_PATH "${mystic_cmake_SOURCE_DIR}/modules")

# Include desired modules
include(mystic_ascii_banner)
include(mystic_options)
```

## Via Git Submodules

Add CMake module as a submodule inside your project:

```bash
git submodule add https://github.com/mystic-framework/cmake.git third_party/mystic-cmake
```

Then append the path to `CMAKE_MODULE_PATH` in your `CMakeLists.txt`:

```cmake
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/third_party/mystic-cmake/modules")

include(mystic_ascii_banner)
include(mystic_coverage)
```

## Just Copy-Paste

1. Copy the `.cmake` files from the `modules/` directory directly into your project's `cmake/` folder.
2. In your `CMakeLists.txt`:

```cmake
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(mystic_options)
```

# Contributing

Thank you for your interest in contributing on this project! To streamline the review process and maintain a healthy community please follow:
- [Community Guidelines](https://mystic-framework.github.io/docs/contributing)
- [Code of Conduct](https://mystic-framework.github.io/docs/code-of-conduct)

# License

The project is licensed under the Apache 2.0 License. For more information regarding the licensing visit: [License](./LICENSE) or
[Framework Licnese](https://mystic-framework.github.io/docs/license).
