# GitHub 首页与技术仓库实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 从零到一建立 `sirius-coding` 的 GitHub 首页内容，并准备 3 个统一前缀的技术仓库骨架，便于后续独立发布到 GitHub。

**Architecture:** 以仓库根目录作为个人主页入口，`README.md` 负责展示定位、技术栈和项目矩阵；`projects/` 目录下的每个子目录作为未来独立仓库的本地样板，彼此通过约定的命名与文档风格保持一致。

**Tech Stack:** Java 21, Spring Boot 3.5.13, Spring Cloud 2025.0.1, Spring Cloud Alibaba 2025.0.0.0, Maven

---

### Task 1: Build the profile homepage

**Files:**
- Create: `README.md`
- Modify: `.gitignore`

- [ ] **Step 1: Write the homepage copy**

```md
# Sirius Coding

> Java / Spring / Spring Cloud / Spring Cloud Alibaba / Spring AI / Spring AI Alibaba / RAG / Vibe Coding
```

- [ ] **Step 2: Keep the homepage focused on the target audience**

The README must explain who this account is for, what technologies it covers, and which projects are worth opening first.

- [ ] **Step 3: Verify the file renders as a GitHub profile README**

Open `README.md` and confirm it contains no repository-specific build instructions that would confuse profile visitors.

### Task 2: Create the `sirius-xz-agent` project skeleton

**Files:**
- Create: `projects/sirius-xz-agent/pom.xml`
- Create: `projects/sirius-xz-agent/src/main/java/com/sirius/xz/agent/SiriusXzAgentApplication.java`
- Create: `projects/sirius-xz-agent/src/main/java/com/sirius/xz/agent/web/AgentController.java`
- Create: `projects/sirius-xz-agent/src/main/java/com/sirius/xz/agent/service/AgentSummaryService.java`
- Create: `projects/sirius-xz-agent/src/main/resources/application.yml`
- Create: `projects/sirius-xz-agent/README.md`

- [ ] **Step 1: Add a minimal Spring Boot application**

```java
package com.sirius.xz.agent;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class SiriusXzAgentApplication {
    public static void main(String[] args) {
        SpringApplication.run(SiriusXzAgentApplication.class, args);
    }
}
```

- [ ] **Step 2: Add a simple controller and service boundary**

```java
package com.sirius.xz.agent.web;

import com.sirius.xz.agent.service.AgentSummaryService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class AgentController {
    private final AgentSummaryService service;

    public AgentController(AgentSummaryService service) {
        this.service = service;
    }

    @GetMapping("/api/agent/summary")
    public String summary(@RequestParam(defaultValue = "Sirius") String name) {
        return service.buildSummary(name);
    }
}
```

- [ ] **Step 3: Document the AI roadmap in the project README**

Describe that the repository is the runway for Spring AI, Spring AI Alibaba, and RAG integration, even if the first version stays locally runnable without external credentials.

- [ ] **Step 4: Verify the package layout matches the repo naming convention**

The code package must stay under `com.sirius.xz.agent` so future GitHub repository separation does not force package renaming.

### Task 3: Create the `sirius-cloud-starter` project skeleton

**Files:**
- Create: `projects/sirius-cloud-starter/pom.xml`
- Create: `projects/sirius-cloud-starter/src/main/java/com/sirius/cloud/starter/SiriusCloudStarterApplication.java`
- Create: `projects/sirius-cloud-starter/src/main/java/com/sirius/cloud/starter/web/HealthController.java`
- Create: `projects/sirius-cloud-starter/src/main/resources/application.yml`
- Create: `projects/sirius-cloud-starter/README.md`

- [ ] **Step 1: Add a Spring Boot entry point for the cloud starter**

```java
package com.sirius.cloud.starter;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class SiriusCloudStarterApplication {
    public static void main(String[] args) {
        SpringApplication.run(SiriusCloudStarterApplication.class, args);
    }
}
```

- [ ] **Step 2: Add a minimal web endpoint for local verification**

```java
package com.sirius.cloud.starter.web;

import java.time.OffsetDateTime;
import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthController {
    @GetMapping("/api/health")
    public Map<String, Object> health() {
        return Map.of(
            "service", "sirius-cloud-starter",
            "status", "UP",
            "time", OffsetDateTime.now().toString()
        );
    }
}
```

- [ ] **Step 3: Record Spring Cloud Alibaba as the target integration layer**

Call out that this repo will evolve toward discovery, configuration, and Feign-based service calls.

- [ ] **Step 4: Keep runtime safe by default**

Default configuration must not require Nacos or any external infrastructure to start locally.

### Task 4: Create the `sirius-web-toolkit` project skeleton

**Files:**
- Create: `projects/sirius-web-toolkit/pom.xml`
- Create: `projects/sirius-web-toolkit/src/main/java/com/sirius/web/toolkit/ApiResponse.java`
- Create: `projects/sirius-web-toolkit/src/main/java/com/sirius/web/toolkit/GlobalExceptionHandler.java`
- Create: `projects/sirius-web-toolkit/src/main/java/com/sirius/web/toolkit/WebToolkitApplication.java`
- Create: `projects/sirius-web-toolkit/src/main/resources/application.yml`
- Create: `projects/sirius-web-toolkit/README.md`

- [ ] **Step 1: Define reusable response and exception handling types**

```java
package com.sirius.web.toolkit;

public record ApiResponse<T>(int code, String message, T data) {
    public static <T> ApiResponse<T> ok(T data) {
        return new ApiResponse<>(0, "ok", data);
    }
}
```

- [ ] **Step 2: Add a global exception handler**

Use a simple `@RestControllerAdvice` that turns unhandled exceptions into a consistent JSON response.

- [ ] **Step 3: Explain the extraction strategy in the README**

The README must say which reusable pieces belong here and which project-level concerns should stay outside this toolkit.

- [ ] **Step 4: Verify the toolkit stays utility-focused**

This project should expose reusable conventions and helper types, not business logic.

### Task 5: Prepare for GitHub publishing

**Files:**
- Modify: `README.md`
- Modify: `docs/superpowers/plans/2026-04-17-github-homepage-tech-projects.md`

- [ ] **Step 1: Add the remote publishing checklist**

```bash
git add README.md docs/superpowers/plans/2026-04-17-github-homepage-tech-projects.md
git commit -m "docs: add github homepage and project plan"
```

- [ ] **Step 2: Capture the auth requirement clearly**

State that GitHub push and repository creation will require either a PAT or SSH key with repo permissions.

- [ ] **Step 3: Review the plan for completion**

Make sure every project has a matching README, entry point, and local verification path.

