# API Contract Testing

This directory contains comprehensive contract testing for the World Bank Documents API, ensuring both .NET and Java implementations maintain perfect parity using our **dual testing approach**.

## 📋 Overview

Our testing strategy combines two complementary test suites to provide comprehensive API validation:

### 🔧 **Behavioral Contract Tests** (`test_api_contract.py`)
Tests runtime behavior, data quality, and business logic:
- **API Consistency**: Identical requests return identical results
- **Data Quality**: Document IDs are unique, fields contain meaningful content  
- **Business Logic**: Country/language filtering, date range queries work correctly
- **Content-Type Validation**: Headers match expected formats (JSON/XML)
- **Error Handling**: Invalid parameters are handled gracefully
- **Document Structure**: Real-world API response format compliance

### 📐 **OpenAPI Specification Tests** (`test_openapi_contract.py`) 
Tests structural compliance with the OpenAPI specification:
- **Schema Validation**: Response structure matches OpenAPI schemas exactly
- **Parameter Compliance**: All spec-defined parameters work correctly
- **Reference Resolution**: Complex schema references are properly resolved
- **Spec-Driven Testing**: Tests automatically generated from OpenAPI definition
- **Format Validation**: Date parameters, enums, and constraints work as specified

## 🚀 Quick Start

### Run All Tests (Recommended)
```bash
# Run comprehensive testing (both behavioral + OpenAPI compliance)
./run_contract_tests.sh --url http://localhost:8080/v3
```

### Run Specific Test Suite
```bash
# Only behavioral/business logic tests
./run_contract_tests.sh --suite behavioral --url http://localhost:8080/v3

# Only OpenAPI specification compliance
./run_contract_tests.sh --suite openapi --url http://localhost:8080/v3

# Test .NET implementation with both suites
./run_contract_tests.sh --url http://localhost:5000/v3

# Test deployed service
./run_contract_tests.sh --url https://api.yourservice.com/v3
```

## Test Categories

### Health Tests (`health`)
- API availability and health endpoint
- Basic service responsiveness

```bash
./run_contract_tests.sh --category health
```

### Basic Functionality Tests (`basic`)
- Core search endpoint behavior
- JSON response structure
- Document schema validation

```bash
./run_contract_tests.sh --category basic
```

### Parameter Handling Tests (`parameters`)
- Query parameter validation
- Format parameter (json/xml)
- Pagination parameters (rows, os)
- Field selection (fl parameter)

```bash
./run_contract_tests.sh --category parameters
```

### Filtering Tests (`filtering`)
- Country filtering (`count_exact`)
- Language filtering (`lang_exact`)
- Date range filtering (`strdate`/`enddate`)
- Search query (`qterm`)

```bash
./run_contract_tests.sh --category filtering
```

### Error Handling Tests (`errors`)
- Invalid parameter handling
- Error response format
- Graceful degradation

```bash
./run_contract_tests.sh --category errors
```

### Consistency Tests (`consistency`)
- Identical requests return identical results
- Pagination consistency
- Result ordering

```bash
./run_contract_tests.sh --category consistency
```

### Data Quality Tests (`quality`)
- Document ID uniqueness
- Required field validation
- Data completeness

```bash
./run_contract_tests.sh --category quality
```

## 🎯 Why Both Test Suites?

**Different APIs can fail in different ways:**

### ❌ **OpenAPI Tests Pass, Behavioral Tests Fail**
- API returns structurally valid responses
- But business logic is broken (wrong filtering, inconsistent results)  
- Data quality issues (empty fields, duplicate IDs)

### ❌ **Behavioral Tests Pass, OpenAPI Tests Fail**
- API works correctly in practice
- But response structure doesn't match specification exactly
- Schema references are malformed or missing

### ✅ **Both Pass = Production Ready**
- Structure matches specification exactly
- Business logic works correctly
- Data quality is high
- Ready for production deployment

## Setup

### Install Dependencies

```bash
pip3 install -r contract_test_requirements.txt
```

### Dependencies Include:
- `pytest` - Test framework
- `requests` - HTTP client for API calls
- `jsonschema` - JSON schema validation
- `pyyaml` - YAML parsing for OpenAPI spec
- `pytest-html` - HTML test reports
- `pytest-json-report` - JSON test reports
- `openapi-spec-validator` - OpenAPI validation (OpenAPI tests only)
- `openapi3-parser` - OpenAPI parsing (OpenAPI tests only)

## Running Tests

### Using the Test Runner (Recommended)

```bash
# Run all tests against local Java service
./run_contract_tests.sh

# Run specific categories
./run_contract_tests.sh --category health,basic,parameters

# Custom API URL
./run_contract_tests.sh --url http://localhost:9000/v3

# Custom report directory
./run_contract_tests.sh --report-dir ./test_results
```

### Using pytest Directly

```bash
# Set API URL environment variable
export API_BASE_URL=http://localhost:8080/v3

# Run all tests
pytest test_api_contract.py -v

# Run specific test classes
pytest test_api_contract.py::TestAPIHealth -v
pytest test_api_contract.py::TestAPIBasicFunctionality -v

# Generate HTML report
pytest test_api_contract.py --html=report.html --self-contained-html
```

## Test Reports

The test runner generates detailed reports:

- **HTML Report**: Visual test results with pass/fail status
- **JSON Report**: Machine-readable results for CI/CD integration

Example HTML report shows:
- Test execution summary
- Individual test results
- Failed test details with error messages
- Execution time and environment info

## Contract Validation

### OpenAPI Specification

The tests validate against the OpenAPI specification in `../docs/openapi.yaml`, ensuring:

- Correct endpoint paths and methods
- Proper request parameter handling
- Response schema compliance
- Error response formats

### Schema Validation

Each API response is validated against JSON schemas to ensure:
- Required fields are present
- Field types are correct
- Data structures match specification
- Optional fields are handled properly

## CI/CD Integration

### GitHub Actions Example

```yaml
- name: Test API Contract Compliance
  run: |
    cd tests
    ./run_contract_tests.sh --url ${{ env.API_URL }}
    
- name: Upload Test Reports
  uses: actions/upload-artifact@v3
  if: always()
  with:
    name: contract-test-reports
    path: tests/reports/
```

### JSON Report Integration

The JSON report format allows easy integration with CI/CD systems:

```bash
# Check if tests passed
if jq -e '.summary.failed == 0' reports/contract_test_results.json > /dev/null; then
    echo "All contract tests passed ✅"
else
    echo "Contract tests failed ❌"
    exit 1
fi
```

## Development Workflow

### Testing During Development

1. Start your API service (local .NET or Java implementation)
2. Run contract tests: `./run_contract_tests.sh`
3. Fix any contract violations
4. Re-run tests until all pass

### Before Deployment

1. Run full test suite against both implementations:
   ```bash
   # Test .NET implementation
   ./run_contract_tests.sh --url http://localhost:5000/v3
   
   # Test Java implementation  
   ./run_contract_tests.sh --url http://localhost:8080/v3
   ```

2. Ensure both implementations pass all tests
3. Compare results to verify true API parity

### Continuous Testing

Set up automated testing:
- Run tests on every commit
- Test against staging environments
- Validate before production deployment

## Troubleshooting

### API Not Available
```
❌ API not available at http://localhost:8080/v3
Make sure your API service is running
```
**Solution**: Start your API service and ensure it's listening on the correct port.

### Test Failures
Check the HTML report for detailed error messages and fix implementation issues.

### Schema Validation Errors
Update your API responses to match the OpenAPI specification schema.

### Missing Dependencies
```bash
pip3 install -r contract_test_requirements.txt
```

## Custom Test Development

### Adding New Tests

1. Add test methods to appropriate test classes in `test_api_contract.py`
2. Use descriptive test names and docstrings
3. Include proper assertions and error messages
4. Add appropriate pytest markers

### Test Categories

Add markers to new tests:
```python
@pytest.mark.health
def test_new_health_feature(self, api_tester):
    """Test new health check feature"""
    pass
```

### Extending Validation

Add custom schema validation:
```python
def _validate_custom_response(self, response_data):
    """Custom validation logic"""
    # Your validation code here
    pass
```

This contract test suite ensures that both .NET and Java implementations maintain perfect API parity and comply with the World Bank Documents API specification.