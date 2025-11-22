#!/usr/bin/env python3
"""
QAST202-1: PlantUML Processing Performance Test

Tests that 95% of PlantUML files complete processing within 3 seconds.

Reference: docs/requirements/quality-requirements.md#qast202-1
"""

import sys
import time
from pathlib import Path
from typing import List, Tuple

import requests

# Add parent directory to path to import app modules
sys.path.insert(0, str(Path(__file__).parent.parent))

from app.infrastructure.parsing.plantuml_parser import RegexPlantUMLParser


def generate_test_files() -> List[Tuple[str, int, int]]:
    """
    Generate test PlantUML files of varying complexity.
    Returns list of (content, expected_components, file_size_bytes).
    """
    parser = RegexPlantUMLParser()
    test_files = []

    # Small file: 5 components
    small = """@startuml
[Component1] as C1
[Component2] as C2
[Component3] as C3
database "DB1" as DB1
queue "Queue1" as Q1

C1 --> C2
C2 --> C3
C3 --> DB1
C1 --> Q1
@enduml"""
    test_files.append((small, 5, len(small.encode())))

    # Medium file: 15 components
    medium = """@startuml
package "System" {
  [Frontend] as FE
  [API Gateway] as AG
  [Auth Service] as Auth
  [User Service] as User
  [Order Service] as Order
  database "UserDB" as UDB
  database "OrderDB" as ODB
  queue "Events" as Events
}

FE --> AG
AG --> Auth
AG --> User
AG --> Order
Auth --> UDB
User --> UDB
Order --> ODB
Order --> Events
@enduml"""
    test_files.append((medium, 8, len(medium.encode())))

    # Large file: 30+ components
    large_components = []
    for i in range(1, 31):
        large_components.append(f'[Component{i}] as C{i}')
    
    relationships = []
    for i in range(1, 30):
        relationships.append(f'C{i} --> C{i+1}')
    
    large = "@startuml\n" + "\n".join(large_components) + "\n" + "\n".join(relationships) + "\n@enduml"
    test_files.append((large, 30, len(large.encode())))

    # Generate more files with varying sizes to reach ~100 files
    base_files = [(small, 5), (medium, 8), (large, 30)]
    for base_content, base_components in base_files:
        for variant in range(3):
            # Add comments and whitespace to vary file size
            variant_content = base_content + "\n" + ("' Comment line\n" * (variant * 10))
            test_files.append((variant_content, base_components, len(variant_content.encode())))
    
    # Duplicate and modify to reach 100 files total
    while len(test_files) < 100:
        # Take existing files and create variations
        existing = test_files[:min(10, len(test_files))]
        for content, comps, size in existing:
            if len(test_files) >= 100:
                break
            # Add random whitespace variations
            modified = content + "\n' Additional comment\n"
            test_files.append((modified, comps, len(modified.encode())))

    return test_files[:100]  # Limit to 100 files as per QAST202-1


def test_processing_performance(base_url: str) -> Tuple[int, int, List[float]]:
    """
    Test PlantUML processing performance against API.
    
    Args:
        base_url: Base URL of API (e.g., "http://localhost:8000")
    
    Returns:
        Tuple of (total_files, successful_files, list_of_processing_times)
    """
    api_url = f"{base_url}/api/v1/diagrams"
    parse_url_template = f"{base_url}/api/v1/diagrams/{{diagram_id}}/parse"
    
    test_files = generate_test_files()
    processing_times = []
    successful = 0
    total = len(test_files)
    
    print(f"Testing {total} PlantUML files against {api_url}")
    
    for idx, (content, expected_components, file_size) in enumerate(test_files, 1):
        try:
            # Upload diagram
            start_time = time.time()
            files = {"file": ("test.puml", content.encode(), "text/plain")}
            data = {"name": f"QAST202-1-Test-{idx}"}
            
            upload_response = requests.post(api_url, files=files, data=data, timeout=10)
            upload_time = time.time() - start_time
            
            if upload_response.status_code != 201:
                print(f"  File {idx}: Upload failed with status {upload_response.status_code}")
                continue
            
            diagram_id = upload_response.json()["id"]
            
            # Parse diagram
            parse_start = time.time()
            parse_response = requests.post(
                parse_url_template.format(diagram_id=diagram_id),
                timeout=10
            )
            parse_time = time.time() - parse_start
            
            total_time = upload_time + parse_time
            
            if parse_response.status_code == 200:
                processing_times.append(total_time)
                successful += 1
                status = "✓" if total_time <= 3.0 else "⚠"
                print(f"  {status} File {idx} ({file_size} bytes): {total_time:.3f}s")
            else:
                print(f"  ✗ File {idx}: Parse failed with status {parse_response.status_code}")
        
        except requests.exceptions.RequestException as e:
            print(f"  ✗ File {idx}: Request failed - {e}")
        except Exception as e:
            print(f"  ✗ File {idx}: Error - {e}")
    
    return total, successful, processing_times


def main() -> int:
    """Run QAST202-1 test and report results."""
    import os
    
    base_url = os.getenv("API_URL", "http://localhost:8000")
    
    print("=" * 60)
    print("QAST202-1: PlantUML Processing Performance Test")
    print("=" * 60)
    print(f"API URL: {base_url}")
    print()
    
    total, successful, processing_times = test_processing_performance(base_url)
    
    if not processing_times:
        print("\n❌ No files processed successfully!")
        return 1
    
    # Calculate success rate
    success_rate = (successful / total) * 100 if total > 0 else 0
    
    # Calculate percentage under 3 seconds
    under_3s = sum(1 for t in processing_times if t <= 3.0)
    pct_under_3s = (under_3s / len(processing_times)) * 100 if processing_times else 0
    
    # Statistics
    avg_time = sum(processing_times) / len(processing_times) if processing_times else 0
    max_time = max(processing_times) if processing_times else 0
    min_time = min(processing_times) if processing_times else 0
    
    print()
    print("=" * 60)
    print("Results:")
    print("=" * 60)
    print(f"Total files tested: {total}")
    print(f"Successfully processed: {successful} ({success_rate:.1f}%)")
    print(f"Processing times under 3s: {under_3s}/{len(processing_times)} ({pct_under_3s:.1f}%)")
    print(f"Average processing time: {avg_time:.3f}s")
    print(f"Min processing time: {min_time:.3f}s")
    print(f"Max processing time: {max_time:.3f}s")
    print()
    
    # Success criteria: 95% of files must complete within 3 seconds
    success = pct_under_3s >= 95.0
    
    if success:
        print("✅ QAST202-1 PASSED: 95%+ of files processed within 3 seconds")
    else:
        print(f"❌ QAST202-1 FAILED: Only {pct_under_3s:.1f}% processed within 3 seconds (required: 95%)")
    
    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())

