# Attributions

> **Community Bridge** This project incorporates code from several outstanding libraries and resources, all licensed under GPLv3. We're grateful to the talented developers who made their work available to the community.

---

## Libraries & Resources

### r\_bridge

**Purpose:** Code for codem-inventory bridging, and initial targeting
**Repository:** [r\_bridge](https://github.com/rumaier/r_bridge)

<details>
<summary>Implementation Details</summary>

**Code we use:**

* Inventory bridging code for codem-inventory integration
* Targeting system foundation

**Modifications made:**

* Adapted inventory bridge for codem compatibility in alternative structure

</details>

---

### dirk\_lib

**Purpose:** Vehicle fuel and vehicle key bridging systems
**Repository:** [dirk\_lib](https://github.com/DirkDigglerz/dirk_lib)

<details>
<summary>Implementation Details</summary>

**Code we use:**

* Client-side vehicle fuel management
* Vehicle key bridging functionality

**Modifications made:**

* None - code used as-is with full credit to original author

</details>

---

### ox\_lib

**Purpose:** External compatibility and architectural inspiration
**Repository:** [ox\_lib](https://github.com/overextended/ox_lib)

<details>
<summary>Implementation Details</summary>

**Compatibility features:**

* External resource integration for raycasting utilities
* Shared conventions

**Implementation approach:**

* No direct code usage - maintains compatibility as external resource
* Follows ox\_lib conventions for seamless integration
* Provides bridge compatibility for servers using ox\_lib ecosystem

</details>

---

### renewed\_lib

**Purpose:** Object placer functionality
**Repository:** [renewed\_lib](https://github.com/Renewed-Scripts/Renewed-Lib)

<details>
<summary>Implementation Details</summary>

**Code we use:**

* Object placement system

**Modifications made:**

* Updated variable naming for consistency
* Added missing parameters for native functions
* Updated deprecated ox\_lib raycast camera export
* Enhanced showtext UI to work with multiple systems
* Moved placement text to locales for internationalization
* Replaced ox\_lib model request exports with our bridge functions

</details>

---

### duff

**Purpose:** Version checker system and update notifications
**Repository:** [duff](https://github.com/DonHulieo/duff/blob/d89ed3b0051194babf5711114a0c437d4e41f433/server/init.lua#L10C1-L28C4)

<details>
<summary>Implementation Details</summary>

**Code we use:**

* Version checker formatting patterns
* Repository information handling

**Modifications made:**

* Removed unnecessary variables
* Enhanced to pull repository information from passed strings
* Adapted print formatting for our use case

</details>

---

## Special Thanks

A heartfelt thank you to all the creators and maintainers of these libraries, bridges, and resources. Your dedication to open-source development and the FiveM community makes projects like Community Bridge possible.

Your willingness to share knowledge and code under GPLv3 licensing enables the entire community to build better, more compatible systems together.

---

## License Compliance

All incorporated code maintains its original GPLv3 licensing. Community Bridge inherits this license to ensure continued open-source availability and community collaboration.

For detailed license information, see the [LICENSE](LICENSE) file in the project root.

---

> *"If I have seen further it is by standing on the shoulders of Giants."* - Isaac Newton
