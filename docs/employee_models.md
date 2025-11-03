# Employee Models Documentation

This document provides comprehensive documentation for the employee data models used in the AttendanceApp. These models represent the core entities that store and manage all employee-related information in the application.

## Overview

The employee models are designed using the Freezed package to provide immutable data classes with built-in JSON serialization, copyWith methods, and equality checks. The models are organized to represent different aspects of an employee's information while maintaining data integrity and privacy.

## Core Models

### Employee
The central model representing a complete employee profile.

#### Properties
- `employeeId`: Unique identifier for the employee
- `status`: Current employment status (active, on leave, terminated, applicant)
- `legalName`: Official legal name (first, middle, last)
- `preferredName`: Preferred name for workplace use
- `displayName`: Display name for UI presentation
- `photoUrl`: URL to employee profile photo
- `dateOfBirth`: Employee's date of birth
- `gender`: Gender identity
- `pronouns`: Preferred pronouns
- `contactInfo`: Contact information (personal and work emails, phone numbers, addresses)
- `employmentDetails`: Employment-specific information (hire date, job role, organization, assignments)
- `attendanceSettings`: Attendance tracking preferences and restrictions
- `leaveSettings`: Leave balances and policies
- `payrollDetails`: Compensation and payroll information
- `workAuthorization`: Legal work authorization status
- `backgroundCheck`: Background verification information
- `trainingCertifications`: Professional training and certifications
- `securitySettings`: Security preferences and device registrations
- `emergencyContacts`: Emergency contact information
- `medicalInfo`: Medical information (restricted access)
- `documents`: Important documents (ID proofs, certificates)
- `personalPreferences`: Personal preferences and settings
- `privacySettings`: Privacy consents and preferences
- `systemInfo`: System metadata (creation/update timestamps, change history)

### Supporting Models

#### LegalName
Represents an employee's official legal name.

#### ContactInfo
Contains all contact information including personal and work emails, phone numbers, and physical addresses.

#### EmploymentDetails
Stores employment-specific information including organizational hierarchy, job role, compensation details, and assignment history.

#### AttendanceSettings
Manages attendance tracking preferences including allowed punch methods, geofencing settings, and biometric enrollment status.

#### LeaveSettings
Handles leave management including leave balances, policies, holiday calendars, and blackout periods.

#### PayrollDetails
Contains compensation and payroll information including salary details, tax information, and banking details for multiple jurisdictions.

#### WorkAuthorization
Tracks legal work authorization status including citizenship, visa information, and permit details.

#### SecuritySettings
Manages security preferences including registered devices, MFA methods, and access controls.

## Usage Examples

### Creating an Employee Instance
```dart
final employee = Employee(
  employeeId: 'EMP001',
  status: EmployeeStatus.active,
  legalName: LegalName(first: 'John', last: 'Doe'),
  contactInfo: ContactInfo(
    mobilePhone: '+1234567890',
    workEmail: 'john.doe@company.com',
  ),
  employmentDetails: EmploymentDetails(
    hireDate: DateTime(2023, 1, 15),
    employmentType: EmploymentType.fullTime,
    designation: 'Software Engineer',
    organization: Organization(
      companyId: 'COMP001',
      businessUnit: 'Engineering',
      department: 'Mobile Development',
      costCenter: 'CC1001',
    ),
    assignments: [],
    workMode: WorkMode.hybrid,
  ),
  attendanceSettings: AttendanceSettings(
    defaultSiteId: 'SITE001',
    defaultShiftTemplateId: 'SHIFT001',
    allowedPunchMethods: [PunchMethod.geo, PunchMethod.kioskPin],
    policyPackId: 'POLICY001',
  ),
  leaveSettings: LeaveSettings(
    leavePolicyId: 'LEAVEPOL001',
    leaveBalances: {
      'paid': LeaveBalance(balance: 20, accrualRate: 1.67, carryOverCap: 30),
      'sick': LeaveBalance(balance: 10, accrualRate: 1.0, carryOverCap: 15),
    },
    holidayCalendarId: 'HOLIDAYCAL001',
    weeklyOff: ['Saturday', 'Sunday'],
  ),
  payrollDetails: PayrollDetails(
    payType: PayType.salary,
    basePay: 75000,
    currency: 'USD',
    payCycle: PayCycle.monthly,
  ),
  workAuthorization: WorkAuthorization(
    citizenshipCountry: 'United States',
  ),
  securitySettings: SecuritySettings(
    registeredDevices: [],
    mfaMethods: [MfaMethod.totp],
  ),
  emergencyContacts: [],
  documents: [],
  personalPreferences: PersonalPreferences(
    skills: [
      Skill(name: 'Flutter', proficiency: 5),
      Skill(name: 'Dart', proficiency: 5),
    ],
  ),
  privacySettings: PrivacySettings(
    consents: [
      Consent(
        purpose: 'location',
        textVersion: 'v1.0',
        granted: true,
        timestamp: DateTime.now(),
        channel: 'mobile_app',
        locale: 'en_US',
      ),
    ],
  ),
  systemInfo: SystemInfo(
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
);
```

### Updating Employee Information
```dart
final updatedEmployee = employee.copyWith(
  employmentDetails: employee.employmentDetails.copyWith(
    designation: 'Senior Software Engineer',
  ),
  systemInfo: employee.systemInfo.copyWith(
    updatedAt: DateTime.now(),
  ),
);
```

## Data Privacy and Security

The employee models are designed with data privacy and security in mind:

1. **Sensitive Data Protection**: Certain fields are marked as sensitive and require special handling:
   - Personal identification numbers (SSN, PAN, etc.)
   - Financial information (bank accounts, salaries)
   - Medical information
   - Biometric data

2. **Access Controls**: The models support role-based access controls where certain fields can only be accessed by authorized personnel.

3. **Encryption**: Sensitive data should be encrypted before storage and decrypted only when necessary for display or processing.

4. **Audit Logging**: All changes to employee records are logged with detailed information about who made the change, when, and what was modified.

## Extensibility

The models are designed to be extensible to accommodate future requirements:

1. **Additional Properties**: New properties can be added to existing models without breaking existing code.

2. **Custom Extensions**: Domain-specific extensions can be added through extension methods.

3. **Hierarchical Structures**: Complex organizational hierarchies can be represented through nested model structures.

## Validation

The models include built-in validation to ensure data integrity:

1. **Required Fields**: Critical fields are marked as required to prevent incomplete records.

2. **Format Validation**: Email addresses, phone numbers, and other formatted data are validated for correctness.

3. **Business Logic Validation**: Domain-specific rules are enforced (e.g., employment dates, salary ranges).

## Serialization

All models support JSON serialization for easy storage and transmission:

1. **toJson()**: Converts model instances to JSON-compatible maps.

2. **fromJson()**: Creates model instances from JSON data.

3. **Custom Adapters**: For complex serialization scenarios, custom adapters can be implemented.

## Performance Considerations

1. **Immutable Instances**: Using immutable data structures reduces unexpected side effects and makes the code more predictable.

2. **CopyWith Pattern**: Efficient object updates through the copyWith pattern avoid unnecessary object recreation.

3. **Lazy Loading**: Large collections can be loaded on-demand to improve initial load times.

4. **Caching**: Frequently accessed data can be cached to reduce repeated computations.

## Versioning

The models support versioning to handle schema evolution:

1. **Backward Compatibility**: Older data formats can be read and converted to newer schemas.

2. **Migration Scripts**: Automated migration scripts can update legacy data to newer formats.

3. **Version Tracking**: Each record maintains version information for audit purposes.

## Testing

The models are designed to be easily testable:

1. **Mock Data Generation**: Factory methods for creating test instances with realistic data.

2. **Equality Checks**: Built-in equality checks simplify assertion writing in tests.

3. **Edge Case Handling**: Models gracefully handle edge cases and invalid data states.