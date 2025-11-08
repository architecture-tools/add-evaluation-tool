# Sprint 1 - Meeting 1

# Meeting 1 - Initial Customer Interview

- Meeting Date: Friday, November 7th, 2025 at 17.00
- Duration: 1 hour
- [recording]()


## List of Speakers
- Denis Nikolskiy
- Ilya Pechersky
- Timur Harin
- Members of Nachos team

[Transcript](https://docs.google.com/document/d/1_xJwR5CLDzGxGkAUk9kkVZc_wqRIiv9N/edit?usp=sharing&ouid=105164135305639429559&rtpof=true&sd=true)


## Action Points
   - Customer to provide calculation formulas via Telegram
   - Team to begin implementation focusing on PlantUML parsing and basic UI matrix
   - Prepare early Docker deployment for client testing
   - Implement linear versioning system for PlantUML uploads
   - Build configurable evolution matrix with -1/0/+1 scoring
   - Create visual diff interface showing component changes
   - Set up Docker Compose deployment


## Meeting Summary

We presented the initial prototype and clarified the MVP scope for the architecture evolution analysis tool. Key decisions included:

### Core Functionality Approved:
- **PlantUML Parsing:** Extract components and relationships from diagrams
- **Evolution Matrix:** Configurable matrix comparing versions with simple scoring (-1, 0, +1)
- **Web Interface:** Manual PlantUML upload with linear versioning
- **Visualization:** Highlight component changes (added/green, removed/red)

### Technical Decisions:
- **No Git integration in MVP** - manual file uploads only
- **Linear versioning** without major/minor version complexity
- **Docker Compose deployment** for easy client testing
- **Single-user focus** initially, with potential for multi-project support

### UI/UX Direction:
- Combined layout from second and fourth Figma mockups
- Focus on version timeline, component matrix, and visual diff
- Dropdown selection for -1/0/+1 scoring in matrix

The customer emphasized the importance of early deployment and frequent demos to ensure alignment. The tool will be used in educational contexts, including potential diploma projects.
