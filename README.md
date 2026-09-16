# PBIP Base

Base repository for future Power BI Project (PBIP) work.

## Purpose

Use this repository as a clean starting point for Power BI solutions that need source control friendly structure for reports, semantic models, DAX, SQL, and supporting documentation.

## Suggested Structure

```text
project-name/
|-- project-name.Report/
|-- project-name.SemanticModel/
|-- sql/
|-- docs/
|-- project-name.pbip
|-- README.md
|-- .gitignore
|-- .gitattributes
```

## Notes

- Keep project-specific data, credentials, local settings, and generated cache files out of source control.
- Rename folders and files for each new project.
- Update this README with the project objective, model overview, refresh notes, and publishing details.
