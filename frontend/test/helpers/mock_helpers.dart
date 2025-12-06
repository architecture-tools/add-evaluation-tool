import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:architecture_evaluation_tool/services/diagram_repository.dart';
import 'package:architecture_evaluation_tool/services/nfr_repository.dart';
import 'package:architecture_evaluation_tool/services/matrix_repository.dart';
import 'package:architecture_evaluation_tool/services/dashboard_service.dart';
import 'package:architecture_evaluation_tool/network/src/api.dart';

@GenerateMocks([
  DiagramRepository,
  NFRRepository,
  MatrixRepository,
  DiagramsApi,
  NfrApi,
])
void main() {}

