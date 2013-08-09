# iHW Project Design Specifications

*In order to make the iHW project more coordinated, unified, and better overall, I think that it’s a good idea for us to write up exactly how we are going about creating the two phone apps and web app. If we use this document to communicate our goals and ideas for the project, we can more effectively create a unified experience for the app across platforms. Please add or edit anything you want in any of the sections below, or even add new sections—this is our space to share ideas. Thanks!*

## Required Features - View

### First-Run Screen

-   Ability to choose campus.

-   Ability to download course list from HW.com.

-   Ability to enter courses manually.

### Schedule View

-   Shows one day at a time, with the ability to swipe left and right to see different days.

-   Shows date, day of week, and day number (if applicable).

-   Shows a list of periods in the day.

-   For each period, shows course name (or "X"), start and end times, and period number (if applicable).

-   For each period, lists the notes the user has added to the period and always has an empty box to add an additional note.

-   Ability to show/hide a checkbox for any note or mark it as important (makes it bigger/bolder and moves it to the top) or unimportant (restores font and moves it to the bottom)

-   Shows a countdown timer next to the period title if the period will start soon.

-   Has a button to jump to the current day and a button to choose a date to show.

### Courses Editor

-   Lists course names.

-   Allows user to delete courses from the list.

-   Has a button to add a new course.

### Edit Course View

-   Has text boxes for course name and period.

-   Validates the period text box as you type (doesn't let you type anything besides valid period numbers)

-   Has a drop-down field to choose the term.

-   Has a grid of checkboxes with three rows (period before, this period, period after) to select class meetings.

-   Has buttons to delete this course or save it.

-   Rejects courses that do not have a name or at least one class meeting.

## Required Features - Model

-   Loads curriculum JSON when user selects a campus during first-run

-   Reloads curriculum JSON on app launch every time there's an internet connection available

-   Loads year JSON and cycle 0 on app launch

-   Loads cycle JSON files as needed (preloading at least one day before and after the currently selected day)

-   Loads the currently selected day, then preloads day(s) before and after it in the background

-   Saves notes when the user is done editing a note, when a note option is changed, and when the user leaves the day where the notes are written.

-   Saves courses whenever the user leaves the edit course view.

## User Interface Style

### Colors

-   Background Light: `rgb(235, 229, 207) / #EBE5CF`

-   Background Dark: `rgb(153, 0, 0) / #990000`

### Fonts

-   Headings: “Georgia Bold”

-   Body: Platform Default (sans-serif)

## Communications / JSON / Saving / etc.

-   Schedule JSON: contains all of the data (one year, one campus) that is not specific to any one particular user

    -   Format:

<!-- -->

    {
        “year”: 2012,
        “campus”: 5,
        “passingPeriodLength”: 5,
        “semesterEndDates”: [...],
        “trimesterEndDates”: [...],
        “normalDay”: {...},
        “normalMonday”: {...},
        “specialDays”: {...} //maps dates to day objects
    }

-   Year JSON (badly named): contains course information and other general information specific to the user

    -   Format:

<!-- -->

    {
        “year”: 2012,
        “campus”: 5,
        “courses”: [...]
    }

-   Week JSON: contains notes for a specific week

    -   Week numbers are as follows:

        -   The partial week between July 1 and the first Sunday after July 1 has week number 0.

        -   On and after the first Sunday after July 1, the week number is: (number of days since the first Sunday after July 1 / 7)+1.

    -   Format:

<!-- -->

    {
        “number”: 1,
        “notes”: {...} //maps "date.period" to arrays of notes
    }

-   Date Format for JSON: `“M/D/YYYY”` e.g. `“9/16/2012”`

-   Time Format for JSON: `“H:M”`  e.g. `“8:0”` or `“14:30”` (use 24 hour time)

-   Course Format for JSON:

<!-- -->

    {
        “term”: 0,
        “name”: “Spanish IV”,
        “period”: 3,
        “meetings”: [1,1,1,1,0]
    }

-   Note Format for JSON: (IMPORTANT: period is NOT the same as “periodNum” in the Period JSON! periodNum can be any number, but period is the index of the period within the day [-1 for additional notes at the bottom of every day])

<!-- -->

    {
        “text”: “Hello, World!”,
        “isChecked”: false,
        “isImportant”: false,
        “isToDo”: false
        "period": 1
    }

-   Normal Day (with break) Format for JSON (day number 0 for no day number):

<!-- -->

    {
        "periodLength": 45,
        "periodsAfterBreak": 6,
        "dayNumber": 2,
        "breakName": "Activities",
        "breakLength": 30,
        "numPeriods": 8,
        "periodsBeforeBreak": 2,
        "type": "normal",
        "date": "9/12/2012",
        "hasBreak": true
    }

-   Normal Day (without break) Format for JSON (day number 0 for no day number):

<!-- -->

    {
        "periodLength": 45,
        "dayNumber": 2,
        "numPeriods": 8,
        "type": "normal",
        "date": "9/12/2012",
        "hasBreak": false
    }

-   Test Day (i.e. Custom Day) Format for JSON:

<!-- -->

    {
        "date": "10/6/2012",
        "tests": [...],
        "type": "test"
    }

-   Holiday Format for JSON:

<!-- -->

    {
        "date": "10/22/2012",
        "name": "Mid-Semester Break",
        "type": "holiday"
    }

-   Period format for JSON: (IMPORTANT: periodNum is NOT the same as “period” in the Note JSON! periodNum can be any number, but period is the index of the period within the day.)

<!-- -->

    {  
        "periodNum": 0,  
        "startTime": "8:0",  
        "name": "Period Name",  
        "date": "11/3/2012",  
        "endTime": "14:30"  
    }

-   Constants:

<!-- -->

    int TERM_FULL_YEAR = 0
    int TERM_FIRST_SEMESTER = 1
    int TERM_SECOND_SEMESTER = 2
    int TERM_FIRST_TRIMESTER = 3
    int TERM_SECOND_TRIMESTER = 4
    int TERM_THIRD_TRIMESTER = 5
    int CAMPUS_MIDDLE = 6
    int CAMPUS_UPPER = 5
    int MEETING_X_DAY = 0
    int MEETING_SINGLE_PERIOD = 1
    int MEETING_DOUBLE_BEFORE = 2
    int MEETING_DOUBLE_AFTER = 3
