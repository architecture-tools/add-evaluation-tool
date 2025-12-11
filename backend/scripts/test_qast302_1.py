#!/usr/bin/env python3
"""
QAST302-1: Component Extraction Accuracy Test

Tests that component extraction achieves at least 95% accuracy.

Reference: docs/requirements/quality-requirements.md#qast302-1
"""

import sys
from pathlib import Path
from typing import Dict, List, Tuple

import requests

# Add parent directory to path to import app modules
sys.path.insert(0, str(Path(__file__).parent.parent))


# Test corpus with known component counts and relationships
TEST_CORPUS: List[Dict[str, any]] = [
    {
        "name": "Simple 3-component system",
        "content": """@startuml
[Frontend] as FE
[Backend] as BE
database "Database" as DB

FE --> BE
BE --> DB
@enduml""",
        "expected_components": 3,
        "expected_relationships": 2,
    },
    {
        "name": "Package with components",
        "content": """@startuml
package "E-commerce" {
  [Web Frontend] as Web
  [Mobile App] as Mobile
  [API Gateway] as Gateway
  [Payment Service] as Payment
  [Order Service] as Order
  database "PostgreSQL" as PG
  queue "RabbitMQ" as MQ
}

Web --> Gateway
Mobile --> Gateway
Gateway --> Payment
Gateway --> Order
Order --> PG
Order --> MQ
@enduml""",
        "expected_components": 7,
        "expected_relationships": 6,
    },
    {
        "name": "Mixed component types",
        "content": """@startuml
actor "User" as User
[Web Application] as Web
[Microservice] as Service
database "MySQL" as MySQL
queue "Kafka" as Kafka
[External API] as ExtAPI

User --> Web
Web --> Service
Service --> MySQL
Service --> Kafka
Service --> ExtAPI
@enduml""",
        "expected_components": 6,
        "expected_relationships": 5,
    },
    {
        "name": "Complex nested structure",
        "content": """@startuml
package "System" {
  package "Frontend" {
    [React App] as React
    [Vue App] as Vue
  }
  package "Backend" {
    [Auth Service] as Auth
    [User Service] as User
    [Product Service] as Product
  }
  database "Main DB" as MainDB
  database "Cache" as Cache
}

React --> Auth
Vue --> Auth
Auth --> User
User --> MainDB
Product --> MainDB
Product --> Cache
@enduml""",
        # Note: 7 components total: React App, Vue App, Auth Service, User Service, Product Service, Main DB, Cache
        "expected_components": 7,
        "expected_relationships": 6,
    },
    {
        "name": "Minimal diagram",
        "content": """@startuml
[Service] as S
database "DB" as D
S --> D
@enduml""",
        "expected_components": 2,
        "expected_relationships": 1,
    },
    {
        "name": "Multiple databases",
        "content": """@startuml
[API] as API
database "Users" as UsersDB
database "Products" as ProductsDB
database "Orders" as OrdersDB
queue "Events" as Events

API --> UsersDB
API --> ProductsDB
API --> OrdersDB
API --> Events
@enduml""",
        "expected_components": 5,
        "expected_relationships": 4,
    },
    {
        "name": "Bidirectional relationships",
        "content": """@startuml
[Client] as Client
[Server] as Server
[Database] as DB

Client <--> Server
Server --> DB
@enduml""",
        "expected_components": 3,
        "expected_relationships": 2,
    },
    {
        "name": "With labels",
        "content": """@startuml
[Frontend] as FE
[Backend] as BE
database "DB" as DB

FE --> BE : HTTP/REST
BE --> DB : SQL
@enduml""",
        "expected_components": 3,
        "expected_relationships": 2,
    },
    {
        "name": "Large system",
        "content": """@startuml
[Gateway] as GW
[Service1] as S1
[Service2] as S2
[Service3] as S3
[Service4] as S4
[Service5] as S5
database "DB1" as DB1
database "DB2" as DB2
queue "Queue1" as Q1
queue "Queue2" as Q2

GW --> S1
GW --> S2
GW --> S3
S1 --> DB1
S2 --> DB1
S3 --> DB2
S4 --> DB2
S5 --> DB1
S1 --> Q1
S2 --> Q2
@enduml""",
        "expected_components": 10,
        # 10 relationships: GW->S1, GW->S2, GW->S3, S1->DB1, S2->DB1, S3->DB2, S4->DB2, S5->DB1, S1->Q1, S2->Q2
        "expected_relationships": 10,
    },
    {
        "name": "Interfaces and actors",
        "content": """@startuml
actor "Admin" as Admin
actor "User" as User
[Web Interface] as Web
[Admin Panel] as AdminPanel
[API] as API
database "Database" as DB

Admin --> AdminPanel
User --> Web
Web --> API
AdminPanel --> API
API --> DB
@enduml""",
        "expected_components": 6,
        "expected_relationships": 5,
    },
    {
        "name": "System boundary",
        "content": """@startuml
system "External System" as Ext
[Our Service] as Service
database "Our DB" as DB

Ext --> Service
Service --> DB
@enduml""",
        "expected_components": 3,
        "expected_relationships": 2,
    },
    {
        "name": "Queue-based architecture",
        "content": """@startuml
[Producer] as Prod
queue "Message Queue" as MQ
[Consumer1] as Cons1
[Consumer2] as Cons2
database "State DB" as State

Prod --> MQ
MQ --> Cons1
MQ --> Cons2
Cons1 --> State
Cons2 --> State
@enduml""",
        "expected_components": 5,
        "expected_relationships": 5,
    },
    {
        "name": "Event-driven",
        "content": """@startuml
[Event Source] as Source
queue "Event Bus" as Bus
[Handler1] as H1
[Handler2] as H2
[Handler3] as H3

Source --> Bus
Bus --> H1
Bus --> H2
Bus --> H3
@enduml""",
        "expected_components": 5,
        "expected_relationships": 4,
    },
    {
        "name": "Microservices mesh",
        "content": """@startuml
[Service A] as SA
[Service B] as SB
[Service C] as SC
[Service D] as SD
database "Shared DB" as Shared

SA --> SB
SA --> SC
SB --> SC
SC --> SD
SA --> Shared
SB --> Shared
@enduml""",
        "expected_components": 5,
        "expected_relationships": 6,
    },
    {
        "name": "Layered architecture",
        "content": """@startuml
[Presentation] as Pres
[Business Logic] as Business
[Data Access] as Data
database "Database" as DB

Pres --> Business
Business --> Data
Data --> DB
@enduml""",
        "expected_components": 4,
        "expected_relationships": 3,
    },
]


def get_auth_token(base_url: str) -> str:
    """Register or login to get authentication token."""
    register_url = f"{base_url}/api/v1/auth/register"
    login_url = f"{base_url}/api/v1/auth/login"

    # Try to register a test user
    test_email = "qast302_test@example.com"
    test_password = "test_password_123"

    try:
        register_response = requests.post(
            register_url,
            json={"email": test_email, "password": test_password},
            timeout=5,
        )
        if register_response.status_code == 201:
            return register_response.json()["token"]["access_token"]
    except Exception:
        pass

    # If registration failed, try to login
    try:
        login_response = requests.post(
            login_url, json={"email": test_email, "password": test_password}, timeout=5
        )
        if login_response.status_code == 200:
            return login_response.json()["token"]["access_token"]
    except Exception:
        pass

    raise RuntimeError("Failed to authenticate for QAST302-1 test")


def test_extraction_accuracy(base_url: str) -> Tuple[int, int, int, List[Dict]]:
    """
    Test component extraction accuracy against API.

    Args:
        base_url: Base URL of API (e.g., "http://localhost:8000")

    Returns:
        Tuple of (total_files, successful_files, total_components_expected, results)
    """
    api_url = f"{base_url}/api/v1/diagrams"
    parse_url_template = f"{base_url}/api/v1/diagrams/{{diagram_id}}/parse"

    # Get authentication token
    try:
        auth_token = get_auth_token(base_url)
        headers = {"Authorization": f"Bearer {auth_token}"}
    except Exception as e:
        print(f"❌ Authentication failed: {e}")
        return 0, 0, 0, []

    results = []
    total_expected_components = 0
    total_expected_relationships = 0
    successful = 0

    print(f"Testing {len(TEST_CORPUS)} PlantUML files against {api_url}")
    print()

    for idx, test_case in enumerate(TEST_CORPUS, 1):
        name = test_case["name"]
        content = test_case["content"]
        expected_components = test_case["expected_components"]
        expected_relationships = test_case["expected_relationships"]

        total_expected_components += expected_components
        total_expected_relationships += expected_relationships

        try:
            # Upload diagram
            files = {
                "file": (
                    f"{name.replace(' ', '_')}.puml",
                    content.encode(),
                    "text/plain",
                )
            }
            data = {"name": name}

            upload_response = requests.post(
                api_url, files=files, data=data, headers=headers, timeout=10
            )

            if upload_response.status_code != 201:
                print(
                    f"  ✗ {idx}. {name}: Upload failed (status {upload_response.status_code})"
                )
                results.append(
                    {
                        "name": name,
                        "success": False,
                        "error": f"Upload failed: {upload_response.status_code}",
                    }
                )
                continue

            diagram_id = upload_response.json()["id"]

            # Parse diagram
            parse_response = requests.post(
                parse_url_template.format(diagram_id=diagram_id),
                headers=headers,
                timeout=10,
            )

            if parse_response.status_code != 200:
                print(
                    f"  ✗ {idx}. {name}: Parse failed (status {parse_response.status_code})"
                )
                results.append(
                    {
                        "name": name,
                        "success": False,
                        "error": f"Parse failed: {parse_response.status_code}",
                    }
                )
                continue

            parse_data = parse_response.json()
            actual_components = len(parse_data.get("components", []))
            actual_relationships = len(parse_data.get("relationships", []))

            # Calculate accuracy
            component_accuracy = (
                (actual_components / expected_components * 100)
                if expected_components > 0
                else 100.0
            )
            relationship_accuracy = (
                (actual_relationships / expected_relationships * 100)
                if expected_relationships > 0
                else 100.0
            )

            # Overall accuracy (average of components and relationships)
            accuracy = (component_accuracy + relationship_accuracy) / 2

            success = accuracy >= 95.0
            if success:
                successful += 1

            status = "✓" if success else "⚠"
            print(
                f"  {status} {idx}. {name}: "
                f"Components {actual_components}/{expected_components} ({component_accuracy:.1f}%), "
                f"Relationships {actual_relationships}/{expected_relationships} ({relationship_accuracy:.1f}%), "
                f"Overall: {accuracy:.1f}%"
            )

            results.append(
                {
                    "name": name,
                    "success": success,
                    "expected_components": expected_components,
                    "actual_components": actual_components,
                    "component_accuracy": component_accuracy,
                    "expected_relationships": expected_relationships,
                    "actual_relationships": actual_relationships,
                    "relationship_accuracy": relationship_accuracy,
                    "overall_accuracy": accuracy,
                }
            )

        except requests.exceptions.RequestException as e:
            print(f"  ✗ {idx}. {name}: Request failed - {e}")
            results.append(
                {
                    "name": name,
                    "success": False,
                    "error": str(e),
                }
            )
        except Exception as e:
            print(f"  ✗ {idx}. {name}: Error - {e}")
            results.append(
                {
                    "name": name,
                    "success": False,
                    "error": str(e),
                }
            )

    return len(TEST_CORPUS), successful, total_expected_components, results


def main() -> int:
    """Run QAST302-1 test and report results."""
    import os

    base_url = os.getenv("API_URL", "http://localhost:8000")

    print("=" * 60)
    print("QAST302-1: Component Extraction Accuracy Test")
    print("=" * 60)
    print(f"API URL: {base_url}")
    print()

    total, successful, total_expected, results = test_extraction_accuracy(base_url)

    if not results:
        print("\n❌ No files processed!")
        return 1

    # Calculate overall statistics
    successful_results = [r for r in results if r.get("success", False)]
    if successful_results:
        avg_accuracy = sum(r["overall_accuracy"] for r in successful_results) / len(
            successful_results
        )
        min_accuracy = min(r["overall_accuracy"] for r in successful_results)
        max_accuracy = max(r["overall_accuracy"] for r in successful_results)
    else:
        avg_accuracy = min_accuracy = max_accuracy = 0.0

    success_rate = (successful / total) * 100 if total > 0 else 0

    print()
    print("=" * 60)
    print("Results:")
    print("=" * 60)
    print(f"Total files tested: {total}")
    print(f"Files with ≥95% accuracy: {successful}/{total} ({success_rate:.1f}%)")
    if successful_results:
        print(f"Average accuracy: {avg_accuracy:.1f}%")
        print(f"Min accuracy: {min_accuracy:.1f}%")
        print(f"Max accuracy: {max_accuracy:.1f}%")
    print()

    # Success criteria: at least 95% accuracy for each file
    # We consider it passed if 95%+ of files achieve 95%+ accuracy
    success = success_rate >= 95.0

    if success:
        print("✅ QAST302-1 PASSED: 95%+ of files achieved ≥95% extraction accuracy")
    else:
        print(
            f"❌ QAST302-1 FAILED: Only {success_rate:.1f}% of files achieved ≥95% accuracy (required: 95%)"
        )

    # Print detailed failures
    failures = [r for r in results if not r.get("success", False)]
    if failures:
        print()
        print("Failed test cases:")
        for r in failures:
            if "error" in r:
                print(f"  - {r['name']}: {r['error']}")
            else:
                print(f"  - {r['name']}: {r.get('overall_accuracy', 0):.1f}% accuracy")

    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())
