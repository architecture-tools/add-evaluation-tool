---
title: Architecture Evaluation Tool - Sprint 0 Deliverable
author: Team Crackers
date: November 1, 2025
geometry: margin=1in
fontsize: 11pt
header-includes:
  - \usepackage{tabularx}
  - \usepackage{xcolor}
  - \usepackage[hyphens]{url}
  - \usepackage[breaklinks=true,colorlinks=true,linkcolor=blue,urlcolor=blue,citecolor=blue]{hyperref}
  - \def\UrlBreaks{\do\/\do-\do\#}
  - \newcommand{\bluelink}[1]{\href{#1}{\color{blue}\url{#1}}}
  - \setlength{\leftmargini}{2em}
---

# Title Page

## Architecture Evaluation Tool
### Sprint 0 Deliverable

**Team:** Crackers

\begin{table}[h]
\centering
\footnotesize
\setlength{\tabcolsep}{3pt}
\begin{tabular}{|p{2.8cm}|p{5.2cm}|p{3.0cm}|p{3.8cm}|}
\hline
\textbf{Team Member} & \textbf{Email} & \textbf{GitHub Username} & \textbf{Role} \\
\hline
Roukaya Mabrouk & r.mohammed@innopolis.university & RoukayaZaki & Documentation \& Delivery Manager \\
\hline
Timur Kharin & t.kharin@innopolis.university & timur-harin & Front-end Development \\
\hline
Ilya Pechersky & i.pechersky@innopolis.university & IlyaPechersky & Core Logic Development \\
\hline
\end{tabular}
\end{table}
\normalsize

**GitHub Repository:** \bluelink{https://github.com/architecture-tools/add-evaluation-tool}

\newpage

# Team Members and Contributions

## Roukaya Mabrouk
**Role:** Documentation & Delivery Manager

**Contributions:**

1. Created interview script
2. Documented meeting output
3. Finished requirements elicitation and Quality Attributes Scenarios
4. Wrote sprint 1 report
5. Reviewed NameSoon A1's submission for interview and script part

## Timur Kharin
**Role:** Front-end Development

**Contributions:**

1. Created figma design for MVP
2. Finished Strategic plan
3. Initial commit and setup for frontend
4. Reviewed NameSoon A1's submission for Repo, MVP vision, and final report.
5. Conducted customer meeting to get customer review of current architecture, and tasks for next sprint.


## Ilya Pechersky
**Role:** Core Logic Development

**Contributions:**

1. Done project Architecture
2. Setup Github project
3. Created backlog with tasks for the current and next sprint
4. Finished Tech Stack part
5. Initial commit and setup for backend
6. Conducted customer meeting to get customer review of current architecture, and tasks for next sprint.

# What We've Learned


## Overview
Sprint 1 focused on establishing the foundation for the Architecture Evaluation Tool, with particular emphasis on requirement clarification, architectural planning, and MVP scope definition through direct customer collaboration.

## Key Accomplishments

### 1. Requirement Clarification & Validation
- Conducted detailed customer meeting to refine evolution matrix concept
- Validated Figma prototypes with stakeholders
- Validated Architecture diagrams with stakeholders
- Defined scoring methodology (-1/0/+1 system for NFR impact)
- Confirmed PlantUML integration as primary input method

### 2. Architectural Foundation
- Established repository structure 
- Defined core components: PlantUML parser, evolution matrix engine, visualization layer
- Selected technology stack aligned with educational deployment needs
- Created initial architecture diagrams for team alignment

### 3. Project Planning
- Developed strategic implementation roadmap
- Developed tactical plan for development
- Created detailed backlog with prioritized user stories
- Established Docker-based deployment strategy


## Future work for Sprint 2

- Follow Backlog tasks for development
- Core parsing functionality as foundation for all features
- Incremental matrix implementation starting with basic scoring


## Conclusion

Sprint 1 successfully transformed initial concepts into a validated, actionable plan. The key learning was that effective customer collaboration, architecture, and early prototyping are more valuable than comprehensive technical planning. By focusing on understanding the educational context and establishing clear MVP boundaries, we've created a solid foundation for delivering a tool that meets both immediate practical needs and long-term research objectives.
