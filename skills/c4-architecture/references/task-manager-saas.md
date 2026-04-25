---
title: "C4 Architecture Example - Task Manager SaaS"
description: "Context, Container and Component diagrams"
tags: [c4, architecture, mermaid]
---

# C4 Architecture - Task Manager SaaS

## System Context

```mermaid
C4Context
    title System Context
    Person(user, "User", "Manages tasks")
    System(tm, "Task Manager", "SaaS platform")
    Rel(user, tm, "Uses", "HTTPS")
```

## Containers

```mermaid
C4Container
    title Containers
    Container_Boundary(app, "App") {
        Container(web, "Web App", "React/Next.js", "UI")
        Container(api, "API Server", "Node.js/Fastify", "REST API")
        ContainerDb(db, "PostgreSQL", "RDBMS", "Data store")
        Cache(cache, "Redis", "Cache", "Sessions")
    }
    Ext(notif, "Notifications", "AWS SES/SNS", "Email/push")
    Ext(auth, "Auth", "Auth0/OAuth", "Login")
    Rel(web, api, "JSON", "HTTPS")
    Rel(api, db, "SQL", "")
    Rel(api, cache, "", "")
```

## Components

```mermaid
C4Component
    title API Components
    Boundary(api, "API") {
        Component(authMw, "Auth MW", "JWT validation")
        Component(taskCtrl, "Tasks Ctrl", "CRUD")
        Component(projCtrl, "Projects Ctrl", "CRUD")
        Component(taskSvc, "Task Service", "Logic")
        Component(repo, "Repository", "Prisma ORM")
    }
    Rel(authMw, taskCtrl, "JWT check")
    Rel(taskCtrl, taskSvc, "Delegate")
    Rel(taskSvc, repo, "DB ops")
```

## Decisions

| Choice | Why |
|-------|-----|
| Next.js | SSR + React |
| Fastify | Fast |
| PostgreSQL | ACID |
| Redis | Speed |
| Prisma | Typesafe |

Copy to skills/c4-architecture/references/ and customize.
