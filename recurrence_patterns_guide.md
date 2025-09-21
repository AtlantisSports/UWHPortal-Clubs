# Practice Recurrence Patterns - Implementation Guide

## Overview

The practice pattern system now supports flexible recurrence patterns, allowing clubs to define practices that repeat on various schedules - from simple weekly practices to complex monthly patterns.

## Supported Recurrence Types

### 1. **Weekly Practices** (Most Common)
```dart
RecurrencePattern.weekly()        // Every week
RecurrencePattern(type: RecurrenceType.weekly, interval: 2)  // Every 2 weeks
```
**Examples:**
- Sunday morning practice every week
- Tuesday evening practice every 2 weeks
- Friday scrimmage every 3 weeks

### 2. **Monthly by Week Position**
```dart
RecurrencePattern.monthlyByWeek(2)   // 2nd occurrence of the day
RecurrencePattern.monthlyByWeek(-1)  // Last occurrence of the day
```
**Examples:**
- 2nd Tuesday of every month
- 4th Thursday of every month  
- Last Friday of every month

### 3. **Monthly by Date**
```dart
RecurrencePattern.monthlyByDate(15)  // 15th of every month
```
**Examples:**
- 15th of every month at 7 PM
- 1st of every month for monthly meeting
- 30th of every month (skips February)

### 4. **Custom Intervals**
```dart
RecurrencePattern.customDays(10)  // Every 10 days
RecurrencePattern.customDays(21)  // Every 3 weeks (21 days)
```
**Examples:**
- Special training cycle every 10 days
- Rotating schedule every 14 days
- Quarterly events every 90 days

### 5. **One-Time Events**
```dart
RecurrencePattern.none()  // No recurrence
```
**Examples:**
- Tournament on specific date
- Special workshop
- Holiday party

## Real-World Usage Examples

### Example 1: Standard Club Schedule
```dart
// Weekly Sunday morning practice
PracticePattern(
  id: 'club-sun-1100-pool-1',
  title: 'Sunday Morning',
  day: PatternDay.sunday,
  startTime: PatternTime(11, 0),
  recurrence: RecurrencePattern.weekly(),
);

// Monthly skills workshop (1st Saturday)
PracticePattern(
  id: 'club-sat-1400-pool-workshop',
  title: 'Monthly Skills Workshop',
  day: PatternDay.saturday,
  startTime: PatternTime(14, 0),
  recurrence: RecurrencePattern.monthlyByWeek(1), // 1st Saturday
);
```

### Example 2: Advanced Training Program
```dart
// High-intensity training every 2 weeks
PracticePattern(
  id: 'club-tue-2000-pool-intensity',
  title: 'Intensity Training',
  day: PatternDay.tuesday,
  startTime: PatternTime(20, 0),
  recurrence: RecurrencePattern.biweekly(),
);

// Tournament prep (last Friday of month)
PracticePattern(
  id: 'club-fri-1800-pool-tournament',
  title: 'Tournament Prep',
  day: PatternDay.friday,
  startTime: PatternTime(18, 0),
  recurrence: RecurrencePattern.monthlyByWeek(-1), // Last Friday
);
```

### Example 3: Special Events
```dart
// Mid-month social scrimmage
PracticePattern(
  id: 'club-sat-1500-pool-social',
  title: 'Social Scrimmage',
  day: PatternDay.saturday,
  startTime: PatternTime(15, 0),
  recurrence: RecurrencePattern.monthlyByDate(15), // 15th of month
);

// One-time tournament
PracticePattern(
  id: 'club-sat-0900-pool-halloween',
  title: 'Halloween Tournament',
  day: PatternDay.saturday,
  startTime: PatternTime(9, 0),
  recurrence: RecurrencePattern.none(), // One-time only
  patternStartDate: DateTime(2025, 10, 26), // Specific date
);
```

## Pattern Start and End Dates

### Pattern Lifecycle Control
```dart
PracticePattern(
  // ... other properties
  patternStartDate: DateTime(2025, 9, 1),    // When pattern begins
  patternEndDate: DateTime(2026, 5, 31),     // When pattern ends (optional)
  recurrence: RecurrencePattern.weekly(),
);
```

**Use Cases:**
- **Seasonal practices**: Start in September, end in May
- **Trial periods**: New practice for 3 months
- **Temporary changes**: Different schedule during summer
- **Event series**: Workshop series with defined start/end

## Integration with Bulk RSVP

### How It Works
1. **Pattern Selection**: User selects from practice patterns (no dates)
2. **Instance Matching**: System finds all practice instances with matching `patternId`
3. **Date Filtering**: Only includes practices within selected date range
4. **Recurrence Respect**: Automatically handles different recurrence patterns

### Benefits
- ✅ **Flexible Scheduling**: Supports any recurrence pattern
- ✅ **Accurate Matching**: Pattern ID ensures correct practice identification
- ✅ **Future-Proof**: New recurrence types can be added easily
- ✅ **Clear Separation**: Patterns vs instances clearly defined

## Technical Implementation

### Pattern Generation
```dart
// Check if pattern should generate practice on specific date
final shouldGenerate = pattern.shouldGeneratePracticeOn(DateTime(2025, 10, 15));

// Generate practice instance data
final practiceData = pattern.generatePracticeData(DateTime(2025, 10, 15));
```

### Practice Instance Creation
```dart
// Generated practice has patternId linking back to pattern
Practice(
  id: 'club_sun_1100_pool_1_2025_10_15',  // Unique instance ID
  patternId: 'club-sun-1100-pool-1',       // Links to pattern
  dateTime: DateTime(2025, 10, 15, 11, 0), // Actual date/time
  // ... other properties from pattern
);
```

This system provides the flexibility to handle any club's practice schedule while maintaining the clean separation between patterns and actual practice instances needed for reliable bulk RSVP functionality.