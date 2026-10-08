# [Module Name] — Living Documentation

> 📖 Master Module Documentation · Living Document
> 🔄 Last Updated: [YYYY-MM-DD] · Status: [Active / Production / In Progress]
> 📂 Scope: [Brief description of the domain, e.g. Gestión de Nómina, Deducciones de Ley y Dispersión Bancaria]

---

## 1. Executive Summary & Domain Scope

- **Business Domain**: [e.g. Recursos Humanos / Finanzas]
- **Target Users & Actors**: [e.g. Oficial de RRHH, Gerente de Finanzas, Empleado, Portal Bancario]
- **Core Value**: [What problem does this module solve?]
- **Primary Routes / Screens**:
  - `/[module]/[path1]`: [Description]
  - `/[module]/[path2]`: [Description]

---

## 2. Capabilities & Sub-Features Matrix

| # | Capability / Sub-module | Description | State | Spec Link |
|---|-------------------------|-------------|-------|-----------|
| 01 | [Sub-feature 1] | [Summary of functionality] | [✅ In Prod / ⏳ In Dev / 📝 In Spec] | [specs/[module]/01-...] |
| 02 | [Sub-feature 2] | [Summary of functionality] | [✅ In Prod / ⏳ In Dev / 📝 In Spec] | [specs/[module]/02-...] |

---

## 3. Consolidated Data Model (Module ERD)

```mermaid
erDiagram
    %% Master ERD consolidating all tables and entities belonging to this module
```

### Key Tables & Data Dictionary
- **`schema.table_1`**: [Purpose, primary key, critical foreign keys]
- **`schema.table_2`**: [Purpose, primary key, critical foreign keys]

---

## 4. Master API Catalog

| Method | Endpoint | Description | Auth / Roles | Request / Response |
|--------|----------|-------------|--------------|--------------------|
| GET | `/api/v1/[module]/...` | [Description] | [Required role] | Query params -> JSON |
| POST | `/api/v1/[module]/...` | [Description] | [Required role] | Body -> JSON |
| PATCH | `/api/v1/[module]/...` | [Description] | [Required role] | Body -> JSON |
| DELETE | `/api/v1/[module]/...` | [Description] | [Required role] | Query ID -> 200/204 |

---

## 5. Universal Business Rules & Regulations

- **Legal / Regulatory Framework**:
  - [e.g. Ley 87-01: Retención AFP 2.87%, SFS 3.04%]
  - [e.g. Código de Trabajo: Factor 23.83 días / 8 horas]
- **Mathematical / Financial Precision**:
  - [e.g. NUMERIC(12,2) with Half-Up Rounding]
- **Tenant Isolation**:
  - [100% of queries partitioned by tenant_id]

---

## 6. External Integrations & File Layouts

- **[Integration 1, e.g. Banking TXT / ACH]**:
  - [File specifications, headers, encodings, validations]

---

## 7. Change Log & Spec Lineage

| Date | Sub-feature / Spec | Change Summary | Base Commit | Author |
|------|--------------------|----------------|-------------|--------|
| [YYYY-MM-DD] | `specs/[module]/[sub-feature]` | [Milestone description] | `[hash]` | [Name] |
