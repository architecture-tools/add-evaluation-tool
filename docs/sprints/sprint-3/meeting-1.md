# Sprint 3 - Meeting 1

- Meeting Date: Friday, November 21st, 2025 at 18.20
- Duration: 10 minutes
- [recording](https://drive.google.com/file/d/1lxsI_cFDHJgDbYPKFM-mM2nrsjtZJb4R/view?usp=sharing)

## List of Speakers

- Denis Nikolskiy
- Ilya Pechersky
- Timur Harin
- Roukaya Mohammed

[Transcript](https://docs.google.com/document/d/1o_chbiuuTz5yxNQx1igjGxmjVpxAPoC2/edit?usp=sharing&ouid=105164135305639429559&rtpof=true&sd=true)

## Summary

We successfully implemented unit testing for both backend (100% coverage) and frontend (55% line coverage excluding
generated code), along with comprehensive static analysis tools. We applied Test-Driven Development
for the NFR feature implementation successfully. While we faced challenges with external deployment platforms due to
 restrictions in Russia and resource limitations, we received client's approval to use Docker Compose as our deployment solution.
  The application is fully containerized and operational locally via ```docker-compose up --build```

## Action Points

- Update documentation to reflect deployment approach change
- Complete frontend integration for NFR CRUD operations
- Document Docker Compose deployment instructions in README
- Implement basic analytics for MVP
- Decide on metrics to support product hypothesis validation and try HDD
